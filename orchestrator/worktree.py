import subprocess
from pathlib import Path
from orchestrator.issue import Issue

WORKTREE_BASE = Path("/tmp/worktrees")


def branch_exists(branch_name: str, repo_root: Path) -> bool:
    result = subprocess.run(
        ["git", "branch", "--list", branch_name],
        capture_output=True, text=True, cwd=repo_root,
    )
    return bool(result.stdout.strip())


def worktree_path(issue: Issue) -> Path:
    return WORKTREE_BASE / issue.id


def create(issue: Issue, repo_root: Path) -> Path:
    path = worktree_path(issue)
    branch = issue.branch_name()
    path_exists = path.exists()
    branch_exists_ = branch_exists(branch, repo_root)

    if path_exists and branch_exists_:
        pass  # existing worktree — reuse as-is
    elif branch_exists_:
        subprocess.run(
            ["git", "worktree", "add", str(path), branch],
            cwd=repo_root, check=True,
        )
    else:
        subprocess.run(
            ["git", "worktree", "add", "-b", branch, str(path)],
            cwd=repo_root, check=True,
        )
    return path


def remove(issue: Issue, repo_root: Path) -> None:
    path = worktree_path(issue)
    subprocess.run(
        ["git", "worktree", "remove", "--force", str(path)],
        cwd=repo_root,
        check=True,
    )
    subprocess.run(
        ["git", "worktree", "prune"],
        cwd=repo_root,
        check=True,
    )


def delete_branch(branch: str, repo_root: Path) -> None:
    subprocess.run(["git", "branch", "-d", branch], cwd=repo_root, check=True)
    result = subprocess.run(
        ["git", "push", "origin", "--delete", branch],
        cwd=repo_root, capture_output=True,
    )
    if result.returncode != 0 and b"remote ref does not exist" not in result.stderr:
        raise subprocess.CalledProcessError(result.returncode, result.args)


def create_merge_worktree(name: str, branch: str, repo_root: Path) -> Path:
    path = WORKTREE_BASE / name
    subprocess.run(
        ["git", "worktree", "add", str(path), branch],
        cwd=repo_root,
        check=True,
    )
    return path


def remove_merge_worktree(name: str, repo_root: Path) -> None:
    path = WORKTREE_BASE / name
    subprocess.run(
        ["git", "worktree", "remove", "--force", str(path)],
        cwd=repo_root,
        check=True,
    )
    subprocess.run(
        ["git", "worktree", "prune"],
        cwd=repo_root,
        check=True,
    )
