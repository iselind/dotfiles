---
name: git-branch-from-origin-main
description: New branches must be created from origin/main, never from a local branch or other remote
metadata:
  type: feedback
---

Always create new branches from `origin/main`:
```bash
git fetch origin
git checkout -b <branch-name> origin/main
```

The branch tracks itself (same name locally and remotely), not `origin/main`.

**Why:** Ensures branches start from the latest upstream state. A common mistake is branching from a local `main` that may be stale, or accidentally setting the upstream to `origin/main` instead of the branch's own remote counterpart.
**How to apply:** Any time a new branch is being created, use this pattern. Flag it if a branch appears to have been created from a stale base or has `origin/main` as its upstream.
