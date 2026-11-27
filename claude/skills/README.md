# Skills

How skills are written here, and which ones exist. The way of working they serve
is described in [../README.md](../README.md). Design thinking that is not yet a
rule lives in [notes.md](notes.md), and what is known about skills triggering in
[triggering.md](triggering.md).

Anthropic documents how to create a skill
[here](https://claude.com/docs/skills/how-to). A skill should fix something the
model gets wrong. Their best skills began as a few lines and a single gotcha,
so a skill here is a list of things Claude actually got wrong, not a manual for
the whole process. Leave Claude alone doing its thing until it makes mistakes,
then add the support. The first step in creating a skill is to complete the task
without one, and notice the information that has to be given repeatedly.

A valid skill conforms to [the specification](https://agentskills.io/specification).

## What a skill is for

Skills hold procedures that need judgment at a specific moment: understanding a
task, scoping a branch, reviewing a diff, consolidating what a task taught.
Stances that hold in every task are rules. What must happen every time, or can
be checked mechanically, is a hook or a script, because a validator beats an
instruction. See the table in [../README.md](../README.md) for where a change goes.

| Where the error lives | Where the fix goes |
|---|---|
| Happens during one recurring task | A gotcha in that task's skill. With no such skill, that is a reason to create one. |
| Happens in any task (naming, commit format, don't touch X) | `rules/` or a CLAUDE.md. |
| Mechanically checkable (formatting, a forbidden file, a failing test) | A hook, a linter or a test. |
| About reasoning quality (jumped to a conclusion, didn't check the repo) | Probably not a skill. Put task, guardrails and a definition of done in the prompt. |

The last row is where `act`, `choose` and `reconcile` lived. They never got
invoked and were retired; recording corrections moved to the
[knowledge-extraction plugin](../plugins/knowledge-extraction/README.md).

## Rules for writing one

- **Description** (front matter) names the task the user asks for and the
  specific context it applies in (system, repo, tool). Shape: "Use when [task]
  in [context]". Use the words a request for that task would use, and be pushy
  about the contexts it covers. It says when, never how to use the skill. The
  stricter "pure when" is my choice and is untested.
- **Body** explains what happens in that situation: steps, conventions, tools,
  endpoints, file paths, shell commands in back-ticks.
- **Reusing another skill's procedure:** cite its `SKILL.md` path, as in
  `~/.claude/skills/shape-ticket/SKILL.md`, and name the steps to follow. Do not
  tell the model to run or invoke a skill by name. A skill that depends on
  another must still work when the other does not load: the failure rule in
  [../rules/skill_launch_failure.md](../rules/skill_launch_failure.md) is to
  stop and say so, never to replace it with inline work. (This loosens an earlier
  rule against any reference to another skill. The docs endorse procedures and
  checklists inside a skill; I had not tested the stricter form either.)
- **Gotchas first.** A gotcha is a concrete fact that defies reasonable
  assumptions. "Be careful with the Jira custom field" is advice.
  "`customfield_10032` takes `{"value": "CORE", "child": {"value": "Platform"}}`"
  is a gotcha.
- **Procedure only where a failure demands it.** Add steps, a template or a
  checklist where a failure has been observed. Gotchas alone work when the model
  knows how to do the task and misses only specifics. They will not carry a task
  the model does not know how to approach.
- **The error is never the trigger.** The agent does not know it is about to
  err, so there is nothing to match on. The task during which the error happens
  is the trigger, and the error becomes a line in that skill's body.
- **Intent belongs in the ticket.** A skill that needs the why, the what or the
  fence reads it from the ticket, and does not create a plan file for it.
- **Writes to Jira need approval each time.** Show the change, wait, then write.

The confidence paradox: a gotchas-only skill covers tasks the model thinks it can
do alone, which are the tasks where it is least likely to consult a skill. The
counter is a specific description, naming the system, repo or tool where the
gotchas apply. "Use when creating or updating Jira tickets in the CORE project"
is a signal that "Use when creating tickets" is not.

## Models

One set of skills, written with Haiku as the floor and checked on Sonnet for
regressions. Split by model only with a recorded measurement of a skill failing
on Haiku and a fix that measurably hurts Sonnet. Findings are labelled with the
model they were observed on and a date, since behaviour changes between releases.
Anything not measured is called a hypothesis.

## Triggering

The docs describe matching on the user's task. Skills for things the model does
unaided are expected to trigger rarely, and my experience that skills do not fire
at the right time is an unmeasured, mostly-Haiku hypothesis. An explicitly
invoked skill (`/skill-name`) does not depend on triggering. Details and a hook
idea are in [triggering.md](triggering.md).

## The skills

| Skill | Step of the way of working |
|---|---|
| `shape-ticket` | Understand: verifies and fixes the why, what, fence and sources in a ticket |
| `task-master` | Understand, confirm, iterate: builds context, confirms the understanding, finds the gap, scopes the branch |
| `refine` | Understand, ahead of time: gap analysis, reshape through `shape-ticket`, place under an epic |
| `consolidate-docs` | Consolidate: promotes `.task/` into repo docs, then deletes it |
| `extract-adr` | Consolidate: records a decision a new team member would benefit from reading |
| `review` | Review: reviews a branch against its confirmed purpose |
| `fix-pr-comments` | Review: works through PR review comments one at a time |
| `first-principles` | Rethinking a design before committing to it |
| `retro` | Retrospective after a skill session; slated for deprecation in [notes.md](notes.md) |

`review` still takes the branch's purpose from free text in the ticket. It could
read the ticket's `## Why` section once `shape-ticket` is in use.
