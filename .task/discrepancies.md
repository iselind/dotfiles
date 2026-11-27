
## 2026-11-27 — Doc vs repo rules: "Round" and worktree layout
Expected: the doc "Ways of Working with AI" and the rules in `claude/rules/` to agree. Observed: the doc's glossary and Iterate section still say "Round" while `claude/rules/branch_never_crosses_the_pr_boundary.md` says to call it the branch. The doc puts worktrees at `~/code/worktrees/<ticket>/<repo>`, while `claude/rules/worktrees_outside_repos.md` suggests sibling `<repo>-<ticket>` directories; `~/code/worktrees` does not exist. Depends on: which wording and layout the new rules and start script adopt. Unresolved; raised with the user.

## 2026-11-27 — task-master location and its output target
Expected: the `task-master` skill to be absent from main, as the user said. Observed: absent on master; it exists as one commit (63ae144) on `origin/feature/task-master`, and an older version was deleted from master in history. It writes `.task/understanding.md` and `.task/gap.md`, while the doc says intent belongs in the ticket, so reviving it means changing its output target. Unresolved; raised with the user.
