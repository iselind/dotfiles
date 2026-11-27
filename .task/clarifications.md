
## 2026-11-12 — Stop hook output: "error" label and full prompt in the UI are unwanted
The user reported two concerns with the knowledge-extraction Stop hook: "the hook having executed and found stuff in .task/ would show up as a stop hook error. Calling it an error seem strange to me" and "the prompt produced on that 'error' is displayed in full in the CLI UI, which kind of obscures the UI's 'useful' output forcing me to scroll to see it."
Preference: hook output should not flood the CLI UI; the extraction prompt (currently sent whole as `reason` in `scripts/extract-on-stop.sh`) should be short or hidden. Claude Code labels any Stop block "Stop hook error", which the hook cannot change. A short `reason` pointing at `prompts/extract.md` was proposed; not yet decided or implemented.

## 2026-11-27 — Aim is to move toward the "Ways of Working with AI" doc; task-master is not on main
User: "let's move closer to the way of working described in the artifact 'Ways of Working with AI'. I've already added the definition of a PR boundary to the rules. the task-master skill mentioned is not on main today, it was on main a while back though". The doc (a Claude Docs artifact) is the target description; the PR-boundary rule is already done, and `task-master` has to be recovered from history, not read from main.

## 2026-11-27 — Worktree location does not matter, but it must show the Jira ticket
User: "I cannot say I care much in particular where exactly the worktrees end up, but it would be great if it was somehow clear which Jira ticket they belong to." Also on the glossary: "I agree that 'round' should be consistently called 'branch' instead as that's far more accurate."

## 2026-11-27 — Settle inconsistencies first; a concern comes before the rules work
User, after the layout and wording were fixed: "before we work on the rules and onward, I have a concern we should cover first". The concern itself has not been stated yet.

## 2026-11-27 — The ticket is the contract: why, what and fence live there; refine cannot be assumed to have run
User: "The concern is the intersection between separating the why, what, and how and where those are stored compared to the refine and task-master skills. What we want, I think, is the ticket reshaped - unless already in that shape - to make the why, what, and the fence clear so the ticket can be revisited to continue work by finding the new gap and how much of it we can do before we hit a PR boundary." And: "`refine` is something I use to improve tickets that are yet to be worked on ... If that were to get the ticket into the desired shape with regard to the what, why, and the fence as well, then that would be wonderful. We cannot assume that `refine` has touched a ticket before we start working on it though."

## 2026-11-27 — Work-start skill next, and the skills README is to be rewritten
User: "go straight to the work-start skill. We should also rewrite claude/skills/README.md as that's also a work in progress". The direction of the README rewrite has not been given yet.
