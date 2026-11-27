# Claude configuration

The rules, skills and plugins that steer how Claude works for me. `setup.sh`
symlinks them into `~/.claude/`, so they are version-controlled and follow me
between machines. Skills have their own guide: [skills/README.md](skills/README.md).

## The way of working

The problem this answers: I focus too much on the how and too little on the
why and the what, which derails Claude and keeps me attached to it while it
works. The aim is to work at a higher level and stay in the loop at one point
only: confirming that Claude has understood the task.

The full description is the doc "Ways of Working with AI" in my Claude Docs. The
short form:

1. **Start.** A ticket gets its own worktrees under
   `~/code/worktrees/<Jira ticket>/<repo>/`, and Claude starts in that folder.
2. **Understand.** Claude reads the ticket, the epic, the repos and their open
   PRs. It separates the why, the what and the how, turns the how into
   conventions, marks assumptions as assumptions, and writes the why, what and
   fence into the ticket.
3. **Confirm.** Nothing is built until I confirm the understanding. This is the
   one gate.
4. **Iterate.** Each branch closes part of the gap between today and the goal,
   and stops at a PR boundary. When the gap is empty, the task is done.
5. **Consolidate.** Corrections and clarifications from the work are promoted
   into the repo's docs, and `.task/` is deleted before the PR is created.
6. **Open the PR.** It never contains `.task/`.

Four stances run through all of it:

- The ticket holds the why, the what and the fence, not a `docs/plans/*.md`
  file. Each branch finds the gap fresh against the ticket.
- A branch never crosses a PR boundary, the point where changes have to be
  deployed before work can continue.
- A change is supported by a test or by authoritative documentation findable
  through the repo's docs, even if that is just a URL.
- `.task/` is disposable scratch. What survives goes to the ticket or the repo.

## What supports each step

| Step | In place | Not built yet |
|---|---|---|
| Start | rule: [worktrees_outside_repos](rules/worktrees_outside_repos.md) | the script that creates worktrees and launches Claude |
| Understand | skills `task-master`, `shape-ticket`, `refine` | |
| Confirm | step 3 of `task-master` | the rule that nothing is built before confirmation; a hook that enforces it, if a rule proves too weak |
| Iterate | `task-master` (finds the gap, scopes the branch), rule: [branch_never_crosses_the_pr_boundary](rules/branch_never_crosses_the_pr_boundary.md) | rules for why/what/how and for tests-or-docs |
| Consolidate | skill `consolidate-docs`, plugin [knowledge-extraction](plugins/knowledge-extraction/README.md) | consolidation at `SessionEnd` |
| Open the PR | the plugin's push guard, rule: [task_dir_stays_out_of_prs](rules/task_dir_stays_out_of_prs.md) | the `gh` shim and the required CI check |
| Review | skills `review`, `fix-pr-comments` | |

The split follows one idea. Rules hold stances that are always true, skills hold
procedures that need judgment, and hooks and scripts hold what must happen every
time. Rules are advisory, so a rule alone is a weak guarantee for anything that
must not be skipped. A plugin bundling the parts comes later, once they stop
changing.

## Where a change goes

| It is | It goes in |
|---|---|
| A stance that holds in every task | `rules/` |
| A procedure with judgment, tied to one recurring task | a skill (see [skills/README.md](skills/README.md)) |
| Something that must happen every time, or can be checked mechanically | a hook or a script |
| Knowledge about one repo | that repo's docs |
| A worry not yet a rule, skill or plan | [concerns.md](concerns.md) |

A correction from me means the repo's docs did not guide toward the right
choice. Fix the docs first. Add a rule here only when the pattern cannot live in
any one repo (see [rules/document_patterns_globally_and_locally.md](rules/document_patterns_globally_and_locally.md)).

## Layout

```
rules/      always-on stances, one per file, each with a Why and a How to apply
skills/     procedures; see skills/README.md
plugins/    hooks and scripts, e.g. knowledge-extraction
concerns.md open concerns about how Claude is set up to work
```

## Still open

The open questions of the way of working are kept at the end of the doc, not
repeated here: checking that parallel tickets don't touch the same areas, how
consolidation chooses which doc in which repo receives an entry, how the
knowledge extraction plugin works with per-ticket worktrees, whether the
confirmation gate needs a hook, and whether the ticket can fully replace plan
files.
