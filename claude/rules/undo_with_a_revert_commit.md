To undo committed work on a branch, add a revert commit, or commits that restore the old state, and say in the commit message why it is undone. Do not rewrite history, split the branch or cherry-pick it into new branches for the purpose.

**Why:** User said, after the agent proposed rebuilding a branch with cherry-picks to get back to an earlier state: "I see no reason why we should rewrite history, just make it clear in the commit message why we undo those changes." A plain revert with a clear message keeps the record of what was tried and why it was dropped, and avoids the risk of rewriting.

**How to apply:** Use `git revert` (or restore the files and commit) with a message that names the commit being undone and the reason, and keep what should stay, such as an unrelated note in the same commit, by restoring it in the same change. Rewriting history still needs the user's approval, as in [[task_dir_stays_out_of_prs]].
