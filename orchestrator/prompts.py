from pathlib import Path
from typing import List


def issue_prompt(prd_path: str, issue_path: str, worktree_path: Path) -> str:
    return f"""\
You are working on a git worktree at {worktree_path}.

Your task is defined by the issue file at {issue_path} (relative to the worktree root).
The PRD for this body of work is at {prd_path} (relative to the worktree root).

Read both files before starting. Then follow the TDD cycle:
1. Write a failing test that captures the acceptance criteria (red)
2. Write the minimum implementation to make the test pass (green)
3. Refactor without breaking the test (refactor)

Operational requirements:
- Update the issue `status` field to `in-progress` as your first action
- Commit and push work to the issue branch as you progress
- When done, update the issue `status` to `done`
- If you cannot complete the work, update `status` to `failed` and populate
  `failure-reason` with a clear description of what went wrong and what was attempted
"""


def merge_prompt(worktree_path: Path, branches: List[str], target_branch: str) -> str:
    branch_list = "\n".join(f"  - {b}" for b in branches)
    return f"""\
You are working on a git worktree at {worktree_path} on branch {target_branch}.

Merge the following branches into {target_branch}:
{branch_list}

Merge each branch in order. Resolve any conflicts that arise. After all merges are
complete, push {target_branch} to the remote.
"""
