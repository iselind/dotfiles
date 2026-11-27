---
name: task-master
description: >
  Use when starting or continuing work on a Jira ticket: understanding the task, confirming that understanding, and finding how much of the remaining gap can be done on the next branch before it reaches a PR boundary.
argument-hint: "[CORE-NNN]"
user-invocable: true
---

# Start or continue work on a ticket

Nothing is built until the user has confirmed the understanding of the task. The ticket holds the why, the what and the fence, so each branch starts by finding the gap between the ticket and the repos as they are now, and ends at a PR boundary. `refine` may or may not have touched the ticket; this skill does not assume it did.

State lives in three places. The ticket holds durable intent and progress across branches. `.task/` holds disposable corrections and clarifications until consolidation. The repo's docs hold what survives, in the PR. Do not write the understanding or the gap to `.task/`.

---

## 1. Build context

Use the ticket key from the argument, the conversation, or the branch name (`{feature,fix}/CORE-NNN-*`). Read the ticket in full with its comments, the epic if one is attached, and any earlier gap-analysis comment.

Name the repos the ticket concerns, from its text and the Jira development info, and ask if the choice is unclear. For each, `git fetch origin`, then read at `origin/main` (`git show origin/main:<path>`, `git log origin/main -- <paths>`), never the working tree. Look at the open PRs and ongoing workflows that touch the same paths: part of the ticket may already be on its way in.

Work happens in the ticket's worktrees under `~/code/worktrees/<ticket>/<repo>/`. If the session is not in one, say so before going further and ask whether to create them; a start script for this does not exist yet.

## 2. Shape the ticket

Verify the ticket against its shape, and fix what is missing, as `~/.claude/skills/shape-ticket/SKILL.md` describes in steps 2 and 3. A ticket already in shape is left as it is. Convert any how in the ticket into conventions, and mark assumptions as assumptions.

Answer what the repos can answer before asking the user. Ask only where an assumption still needs resolving, or where the answer cannot be found in the repos and different answers would change the scope.

## 3. Confirm the understanding

Present, briefly: the why, the what, the fence, the assumptions still standing, and the open questions. Wait for the user to confirm, correct or clarify. If the user does not confirm, rework the understanding and present it again.

Do not edit files or create branches before this confirmation. Reading is fine.

## 4. Find the gap

The gap is the difference between today and the goal. When it is empty, the task is done: say so and stop.

Compare what the ticket asks for with what the repos contain at the fetched `origin/main`, and with the open PRs found in step 1. An earlier analysis comment is stale if `git log <sha>..origin/main -- <paths>` is non-empty for any path it recorded. Do not use the Jira `updated` field, since our own writes change it.

## 5. Scope the branch

Find the PR boundary in each repo: the earliest point where changes have to be deployed before work can continue, or where the implementation is complete. A repo may document where its boundary falls; follow that. The branch covers the gap up to that boundary and no further.

Say what the branch will do, what is left for later branches and what they wait for. Ask the user to confirm the scope. Then propose a comment for the ticket that says what this branch contributes and what remains, and post it after approval.

Show the proposed change and wait for approval before every Jira write. Jira descriptions and comments are Markdown, not wiki markup. Do not put branch names in the ticket; the GitHub integration links them.

## 6. Stop

Report the confirmed scope of the branch and where the work will happen. Implementation, review and the PR are separate steps. When the branch is merged and deployed, running this skill again starts the next one from the updated ticket.
