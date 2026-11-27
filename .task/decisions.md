
## 2026-11-27 — Worktree layout `~/code/worktrees/<ticket>/<repo>/`
Decided: the doc's layout, replacing the rule's sibling `<repo>-<ticket>` suggestion in `claude/rules/worktrees_outside_repos.md` (merged to master, 15c8823). Rejected: keeping sibling directories, because a ticket folder groups a ticket's repositories and is where Claude starts. Easy to undo: one rule line and the doc text.

## 2026-11-27 — "Round" renamed "branch" in the doc, edited in place
Decided: replace "round" with "branch" across the doc text, glossary and three diagrams, as plain edits and not suggestions, since the user asked for exactly this wording change. Easy to undo through the doc's history.

## 2026-11-27 — Proposed: shared ticket-shape reference used by refine and the work-start skill
Proposed, awaiting the user's answer on where the file lives: one reference file defining the ticket shape (why, what, fence, authoritative sources), read by both `refine` (step 4.2 extended) and the revived `task-master`, which checks the shape first and reshapes only if missing. Rejected: one skill invoking the other, because of the skill-launch-failure rule. `.task/understanding.md` and `.task/gap.md` of the old `task-master` would go away. Easy to undo: nothing is written yet.

## 2026-11-27 — Proposed: a `shape-ticket` skill owns the ticket shape, replacing the shared-file idea
Proposed, awaiting the user's go-ahead and name: `shape-ticket` verifies and fixes why, what, fence and sources, writing to Jira only with approval. `refine` 4.2 and the revived `task-master` call it. The gap analysis stays outside it, since it is tied to a commit and goes stale. Rejected: a shared reference file (the shape would have no owner), and reshaping `refine` itself into this skill (it would drag epic placement and ticket picking along). Easy to undo: nothing is written yet.
