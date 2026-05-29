import re
import subprocess
import yaml
from dataclasses import dataclass, field
from pathlib import Path
from typing import List


@dataclass
class BlockedBy:
    id: str
    reason: str


@dataclass
class Issue:
    id: str
    title: str
    status: str
    prd_slug: str
    branch: str
    failure_reason: str
    blocked_by: List[BlockedBy]
    body: str
    path: Path

    def branch_name(self) -> str:
        if self.branch:
            return self.branch
        slug = re.sub(r"[^a-z0-9]+", "-", self.title.lower()).strip("-")
        return f"issue/{self.id.lower()}-{slug}"


def parse_issue(path: Path) -> Issue:
    text = path.read_text()
    parts = text.split("---", 2)
    if len(parts) < 3:
        raise ValueError(f"No valid frontmatter in {path}")
    front = yaml.safe_load(parts[1])
    body = parts[2].strip()

    blocked_by = [
        BlockedBy(id=b["id"], reason=b["reason"])
        for b in (front.get("blocked-by") or [])
    ]

    return Issue(
        id=front["id"],
        title=front["title"],
        status=front["status"],
        prd_slug=front.get("prd-slug") or "",
        branch=front.get("branch") or "",
        failure_reason=front.get("failure-reason") or "",
        blocked_by=blocked_by,
        body=body,
        path=path,
    )


def write_issue(issue: Issue) -> None:
    blocked_by = [{"id": b.id, "reason": b.reason} for b in issue.blocked_by]
    front = {
        "id": issue.id,
        "title": issue.title,
        "status": issue.status,
        "prd-slug": issue.prd_slug,
        "branch": issue.branch,
        "failure-reason": issue.failure_reason,
        "blocked-by": blocked_by,
    }
    text = f"---\n{yaml.dump(front, default_flow_style=False, sort_keys=False)}---\n\n{issue.body}\n"
    issue.path.write_text(text)


def find_issues(issues_dir: Path, prd_slug: str = "") -> List[Issue]:
    issues = [parse_issue(p) for p in sorted(issues_dir.glob("ISS-*.md"))]
    if prd_slug:
        issues = [i for i in issues if i.prd_slug == prd_slug]
    return issues


def read_status_from_branch(issue: "Issue", repo_root: Path) -> str:
    """Read the issue status from its branch without checking it out."""
    branch = issue.branch or issue.branch_name()
    result = subprocess.run(
        ["git", "show", f"{branch}:issues/{issue.path.name}"],
        capture_output=True, text=True, cwd=repo_root,
    )
    if result.returncode != 0:
        return issue.status
    parts = result.stdout.split("---", 2)
    if len(parts) < 3:
        return issue.status
    front = yaml.safe_load(parts[1])
    return front.get("status", issue.status)


def parse_prd_slug(prd_path: Path) -> str:
    text = prd_path.read_text()
    parts = text.split("---", 2)
    if len(parts) < 3:
        raise ValueError(f"No frontmatter in PRD: {prd_path}")
    front = yaml.safe_load(parts[1])
    slug = front.get("slug")
    if not slug:
        raise ValueError(f"PRD has no slug field: {prd_path}")
    return slug
