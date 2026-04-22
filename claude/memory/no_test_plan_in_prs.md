---
name: No test plan section in PRs
description: Do not include a test plan section when creating pull requests
type: feedback
---

Do not include a "Test plan" section in pull request descriptions.

**Why:** User explicitly asked to drop it — they don't want that section in PRs.

**How to apply:** When creating PRs with `gh pr create`, omit any test plan / checklist section from the body.
