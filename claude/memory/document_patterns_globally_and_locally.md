---
name: document-patterns-globally-and-locally
description: When a coding pattern disagreement surfaces, document it as both a global memory and in the appropriate repo CLAUDE.md
metadata:
  type: feedback
---

When the user objects to how a problem was solved or disagrees with an approach during active work:

1. **Identify the pattern** — what principle or practice is at stake?
2. **Save as global memory** — add to `~/.claude/memory/` so it guides future conversations across all projects
3. **Add to repo CLAUDE.md** — locate or create a CLAUDE.md at the appropriate level in the hierarchy (repo root, subsystem, service, etc.) to guide future developers and future AI work in that repo

**Why:** Global memory helps Claude work consistently across projects. Repo-level CLAUDE.md helps developers on the team and future AI collaborators working in that specific codebase. Both matter.

**How to apply:** This is not a one-time setup — it's a standing pattern for how we refine the way of working. Either of us can flag moments that deserve documentation. Don't assume the other will catch it.
