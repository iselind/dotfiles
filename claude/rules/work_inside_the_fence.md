Work autonomously inside the fence of the task, and stop to ask only when a decision falls outside it or was not covered before. When there are several findings to resolve (review findings, verification problems, PR comments), resolve them all inside the fence without stopping between them, and report together at the end.

The fence is the task's scope, what it must have, what it must avoid, what is good to have and its task-specific conventions, as confirmed with the user. Where no fence has been confirmed, it is what the user asked for.

**Why:** User said, replacing an earlier request to resolve findings one by one so they could review each: "I've recently started to ask Claude to not honor the 'keep me in the loop with one concern at a time' approach and let go of that control while still allowing Claude to ask for clarifications and have me make the choices when going outside the fence or what has previously been covered." Reviewing every change keeps the user attached to the work, and the aim is to work at a higher level and stay in the loop only where their judgment is needed.

**How to apply:**
- Inside the fence, decide, note the decision where the user will find it (the report, the ticket, the commit message), and continue. Do not ask "Ready for the next?".
- Stop and ask when the next step goes outside the fence, contradicts something already settled, or needs a fact only the user has. Ask the one question that unblocks the work, with the options you see.
- A skill or agent whose procedure names its own approval step, such as a Jira write or an `extract-adr` commit, keeps it. Outward-facing or hard-to-reverse actions (pushing to a branch with an open PR, creating a PR, deleting remote state) still need the user's approval; this rule does not widen what is authorised.
- Committing at a stable point still applies (see [[commit_at_stable_points]]).
