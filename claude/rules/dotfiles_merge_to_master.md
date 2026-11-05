---
name: Dotfiles changes merge to master directly
description: In the dotfiles repo, land changes by merging to master directly, not by opening a pull request
type: feedback
---

For the dotfiles repo (`~/code/dotfiles`), do not open a pull request. Merge to `master` directly and push it.

**Why:** Direct merges are allowed in dotfiles, and a PR adds a step with no benefit there. Pushing to `master` is the normal flow for this repo. This rule lives here and not in the repo's own memory because changes to dotfiles are often made from sessions started in other projects.

**How to apply:** When a change in dotfiles is ready, commit on a local branch, fast-forward `master` to it, push `origin master`, and delete the local branch. There is no need to push the branch itself. Don't run `gh pr create`. The no-test-plan rule still applies to any PR that is opened elsewhere.
