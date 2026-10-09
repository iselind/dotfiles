When a pull request is open, update the PR description and post any reply comments before pushing new commits to its branch, never after.

**Why:** A push triggers the automated review. The description and the explanation of the change have to be in place when it reads the PR, otherwise it reviews against stale text.

**How to apply:** Order the steps: edit the description (`gh pr edit`), post comments (`gh pr comment`), then `git push`. This does not replace asking before pushing to a branch with an open PR; it only fixes the order once the push is approved.
