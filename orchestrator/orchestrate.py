#!/usr/bin/env python3
"""
Orchestrator for the agentic development workflow.

Runs on the PRD branch. Reads issues/, computes phases from the DAG, and dispatches
claude agents to solve issues in parallel within each phase.

Usage:
    python -m orchestrator.orchestrate --prd docs/prds/my-prd.md
    python -m orchestrator.orchestrate --prd docs/prds/my-prd.md --repo /path/to/other/repo
"""
import argparse
import signal
import subprocess
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime
from pathlib import Path

from orchestrator.dag import compute_phases
from orchestrator.issue import find_issues, parse_prd_slug, read_status_from_branch, write_issue
from orchestrator import prompts, worktree

# --- Signal handling --------------------------------------------------------

_active_processes: list = []
_active_processes_lock = threading.Lock()
_active_worktrees: list = []   # list of (Issue, repo_root)
_active_worktrees_lock = threading.Lock()


def _abort_handler(signum, frame):
    print("\nAborted. Cleaning up in-progress worktrees...")
    with _active_processes_lock:
        for proc in _active_processes:
            try:
                proc.kill()
            except Exception:
                pass
    with _active_worktrees_lock:
        for issue, repo_root in list(_active_worktrees):
            try:
                worktree.remove(issue, repo_root)
                print(f"  removed worktree for {issue.id}")
            except Exception:
                pass
    sys.exit(1)


signal.signal(signal.SIGINT, _abort_handler)
signal.signal(signal.SIGTERM, _abort_handler)

# --- Helpers ----------------------------------------------------------------


def get_repo_root() -> Path:
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        capture_output=True, text=True, check=True,
    )
    return Path(result.stdout.strip())


def get_current_branch(repo_root: Path) -> str:
    result = subprocess.run(
        ["git", "branch", "--show-current"],
        capture_output=True, text=True, check=True, cwd=repo_root,
    )
    return result.stdout.strip()


def create_pre_run_tag(prd_slug: str, repo_root: Path) -> str:
    tag = f"pre-run-{prd_slug}-{int(time.time())}"
    subprocess.run(["git", "tag", tag], cwd=repo_root, check=True)
    print(f"Tagged current state as {tag}")
    return tag


def preflight(repo_root: Path, prd_slug: str) -> list:
    issues_dir = repo_root / "issues"
    return find_issues(issues_dir, prd_slug=prd_slug) if issues_dir.exists() else []


def log_path(name: str) -> Path:
    return Path(f"/tmp/worktrees/{name}.log")


def run_agent(prompt: str, worktree_path: Path, repo_root: Path, name: str) -> int:
    lp = log_path(name)
    lp.parent.mkdir(parents=True, exist_ok=True)
    print(f"  logging to {lp}")
    with open(lp, "w") as log:
        proc = subprocess.Popen(
            [
                "claude",
                "--dangerously-skip-permissions",
                "--add-dir", str(repo_root),
                "--add-dir", str(worktree_path),
                "-p", prompt,
            ],
            cwd=worktree_path,
            stdout=log,
            stderr=log,
        )
        with _active_processes_lock:
            _active_processes.append(proc)
        try:
            proc.wait()
        finally:
            with _active_processes_lock:
                if proc in _active_processes:
                    _active_processes.remove(proc)
    return proc.returncode


def run_issue_agent(issue, prd_path_relative: str, issue_path_relative: str, wt_path: Path, repo_root: Path) -> None:
    prompt = prompts.issue_prompt(prd_path_relative, issue_path_relative, wt_path)
    returncode = run_agent(prompt, wt_path, repo_root, issue.id)
    ts = datetime.now().strftime("%H:%M:%S")
    if returncode != 0:
        print(f"[{issue.id}] agent exited with code {returncode} [{ts}]; checking issue status")
    else:
        print(f"[{issue.id}] agent completed [{ts}]")


def run_merge_agent(phase_num: int, branches, target_branch: str, repo_root: Path) -> None:
    prompt = prompts.merge_prompt(repo_root, branches, target_branch)
    run_agent(prompt, repo_root, repo_root, f"merge-phase-{phase_num}")


def find_remaining_issue_branches(prd_slug: str, repo_root: Path) -> list:
    """Find any issue/iss-* branches whose issue file declares the given prd-slug."""
    result = subprocess.run(
        ["git", "branch", "--list", "issue/iss-*"],
        capture_output=True, text=True, cwd=repo_root,
    )
    branches = [b.strip().lstrip("* ") for b in result.stdout.splitlines() if b.strip()]

    matching = []
    for branch in branches:
        ls = subprocess.run(
            ["git", "ls-tree", "--name-only", branch, "issues/"],
            capture_output=True, text=True, cwd=repo_root,
        )
        for filename in ls.stdout.splitlines():
            if not (filename.startswith("issues/ISS-") and filename.endswith(".md")):
                continue
            show = subprocess.run(
                ["git", "show", f"{branch}:{filename}"],
                capture_output=True, text=True, cwd=repo_root,
            )
            if show.returncode != 0:
                continue
            parts = show.stdout.split("---", 2)
            if len(parts) >= 3:
                import yaml as _yaml
                front = _yaml.safe_load(parts[1])
                if front.get("prd-slug") == prd_slug:
                    matching.append(branch)
            break
    return matching


def git_push(repo_root: Path) -> None:
    branch = get_current_branch(repo_root)
    subprocess.run(
        ["git", "push", "--set-upstream", "origin", branch],
        cwd=repo_root, check=True,
    )


def cleanup_phase(phase_issues: list, repo_root: Path) -> None:
    """Delete issue files, local branches, and remote branches for a completed phase."""
    issues_dir = repo_root / "issues"
    deleted_files = []
    for issue in phase_issues:
        if issue.path.exists():
            issue.path.unlink()
            deleted_files.append(str(issue.path.relative_to(repo_root)))

    if deleted_files:
        subprocess.run(["git", "add"] + deleted_files, cwd=repo_root, check=True)
        ids = ", ".join(i.id for i in phase_issues)
        subprocess.run(
            ["git", "commit", "-m", f"Clean up issue files after phase merge ({ids})"],
            cwd=repo_root, check=True,
        )
        git_push(repo_root)

    for issue in phase_issues:
        branch = issue.branch
        if branch and worktree.branch_exists(branch, repo_root):
            print(f"  deleting branch {branch}")
            worktree.delete_branch(branch, repo_root)


# --- Main -------------------------------------------------------------------


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--prd", required=True, help="Path to the PRD file (relative to repo root)")
    parser.add_argument("--repo", help="Path to the target repository (defaults to current repo)")
    args = parser.parse_args()

    repo_root = Path(args.repo).resolve() if args.repo else get_repo_root()
    prd_path = repo_root / args.prd
    prd_path_relative = args.prd

    try:
        prd_slug = parse_prd_slug(prd_path)
    except FileNotFoundError:
        prd_slug = prd_path.stem

    issues = preflight(repo_root, prd_slug)

    if not issues:
        print(f"No issues remaining for PRD '{prd_slug}' — running final cleanup.")
        _cleanup_run(prd_path, prd_slug, repo_root, pre_run_tag=None)
        sys.exit(0)

    pre_run_tag = create_pre_run_tag(prd_slug, repo_root)

    prd_branch = get_current_branch(repo_root)
    print(f"PRD branch: {prd_branch}")

    phases = compute_phases(issues)
    print(f"Found {len(issues)} issues across {len(phases)} phase(s)")

    issues_dir = repo_root / "issues"

    for phase_num, phase_issues in enumerate(phases, start=1):
        ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"\n--- Phase {phase_num}: {[i.id for i in phase_issues]} [{ts}] ---")

        def effective_status(issue):
            if worktree.branch_exists(issue.branch_name(), repo_root):
                return read_status_from_branch(issue, repo_root)
            return issue.status

        pending = [i for i in phase_issues if effective_status(i) != "done"]
        if not pending:
            print(f"All issues in phase {phase_num} already done, skipping to merge")
        else:
            for issue in pending:
                issue.branch = issue.branch_name()
                write_issue(issue)
                worktree.create(issue, repo_root)
                with _active_worktrees_lock:
                    _active_worktrees.append((issue, repo_root))

            with ThreadPoolExecutor(max_workers=len(pending)) as executor:
                futures = {}
                for issue in pending:
                    wt_path = worktree.worktree_path(issue)
                    issue_path_relative = f"issues/{issue.path.name}"
                    future = executor.submit(
                        run_issue_agent,
                        issue,
                        prd_path_relative,
                        issue_path_relative,
                        wt_path,
                        repo_root,
                    )
                    futures[future] = issue

                for future in as_completed(futures):
                    issue = futures[future]
                    exc = future.exception()
                    if exc:
                        print(f"[{issue.id}] unexpected error: {exc}")

            for issue in pending:
                worktree.remove(issue, repo_root)
                with _active_worktrees_lock:
                    _active_worktrees.remove((issue, repo_root))

        failed = [i for i in phase_issues if effective_status(i) == "failed"]
        if failed:
            for i in failed:
                print(f"[{i.id}] FAILED: {read_status_from_branch(i, repo_root)}")
            print("\nPhase failed — stopping orchestration.")
            sys.exit(1)

        branches = [issue.branch for issue in phase_issues]
        print(f"Merging {branches} into {prd_branch}")
        run_merge_agent(phase_num, branches, prd_branch, repo_root)

        print(f"Cleaning up phase {phase_num} issue files and branches")
        # Re-read issues to get updated branch names after potential resume
        current_issues = {i.id: i for i in find_issues(issues_dir, prd_slug=prd_slug)}
        phase_issues_current = [current_issues.get(i.id, i) for i in phase_issues]
        cleanup_phase(phase_issues_current, repo_root)

    print("\nAll phases complete.")
    _cleanup_run(prd_path, prd_slug, repo_root, pre_run_tag)


def squash_since_tag(tag: str, prd_slug: str, repo_root: Path) -> None:
    """Squash all commits since the pre-run tag into one commit."""
    result = subprocess.run(
        ["git", "rev-parse", "--verify", tag],
        capture_output=True, text=True, cwd=repo_root,
    )
    if result.returncode != 0:
        print(f"  pre-run tag {tag} not found, skipping squash")
        return
    log = subprocess.run(
        ["git", "log", "--reverse", "--format=%s%n%b", f"{tag}..HEAD"],
        capture_output=True, text=True, cwd=repo_root, check=True,
    ).stdout.strip()

    subprocess.run(["git", "reset", "--soft", tag], cwd=repo_root, check=True)

    status = subprocess.run(
        ["git", "diff", "--cached", "--quiet"], cwd=repo_root,
    )
    if status.returncode != 0:
        message = f"Implement {prd_slug}\n\n{log}" if log else f"Implement {prd_slug}"
        subprocess.run(
            ["git", "commit", "-m", message],
            cwd=repo_root, check=True,
        )
        print(f"Squashed orchestrator commits into one (base: {tag})")
    else:
        print("Nothing to squash")


def _cleanup_run(prd_path: Path, prd_slug: str, repo_root: Path, pre_run_tag: str | None) -> None:
    """Squash, delete PRD, clean up orphaned branches and log files."""
    if pre_run_tag:
        squash_since_tag(pre_run_tag, prd_slug, repo_root)

    if prd_path.exists():
        rel = str(prd_path.relative_to(repo_root))
        subprocess.run(["git", "rm", rel], cwd=repo_root, check=True)
        subprocess.run(
            ["git", "commit", "--amend", "--no-edit"],
            cwd=repo_root, check=True,
        )
        git_push(repo_root)
        print(f"Deleted PRD {rel}")

    remaining = find_remaining_issue_branches(prd_slug, repo_root)
    for branch in remaining:
        print(f"  deleting orphaned branch {branch}")
        worktree.delete_branch(branch, repo_root)

    for lf in Path("/tmp/worktrees").glob("*.log"):
        lf.unlink()
    print("Cleaned up /tmp/worktrees logs")


if __name__ == "__main__":
    main()
