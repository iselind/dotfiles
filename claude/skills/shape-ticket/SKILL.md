---
name: shape-ticket
description: >
  Use when a Jira ticket's why, what and fence need to be checked or written before work starts or continues on it: whether the ticket says what it is for, what it must deliver, what is in scope, what it must have and avoid, and where the authoritative sources are.
argument-hint: "[CORE-NNN]"
user-invocable: true
---

# Shape a ticket

A ticket is ready to work from when it holds its shape: the why, the what, the fence and the sources. The ticket is where this lives, so work can stop after any branch and be picked up later by finding the new gap against it. This skill checks a ticket against that shape and fixes what is missing. A ticket that already has the shape is left untouched, and the skill says so.

The shape is about the ticket as it stands, not about the repos at a commit. The gap between the ticket and the repos goes stale and is found again for every branch, so it is not part of the shape.

---

## 1. Read the ticket

Use the ticket key from the argument or the conversation. Read the ticket in full, including comments, and the epic if one is attached. Tickets were often written before this shape existed, so the shape may be present under other words, or spread over comments.

Name the repos the ticket concerns from its text and the Jira development info. `git fetch origin` in each, and read them at `origin/main` (`git show origin/main:<path>`), never the working tree.

## 2. Verify

Check each part and give a verdict of present, vague or missing, with the ticket text that backs it.

| Part | Present when |
|---|---|
| Why | States what the work is for, and what would be wrong if it were done in a way that defeats that. |
| What | States the outcome the work must deliver, so it can be told apart from a way of getting there. |
| Scope | Bounds the work, so it is clear what is not part of it. |
| Must have | Lists what the result requires, each item checkable. |
| Must avoid | Lists what the result must not do, each item checkable. |
| Good to have | Lists what is welcome but optional, or says there is none. |
| Task-specific conventions | States the shape any valid solution must follow, beyond the repo's own conventions. |
| Sources | Links the documentation the work rests on and names the related repositories. |

Two checks cut across the table:

- **How as conventions.** A how in the ticket (a named file, a chosen mechanism, a step list) is one way of meeting the what. Keep it as a convention only if every valid solution must follow it. Otherwise it is an example, and is marked as one.
- **Facts and assumptions.** A statement that is known to be true is a fact. One that is not may be an artificial or unwarranted constraint. Assumptions are marked as assumptions in the ticket.

If every part is present, report that and stop. Do not rewrite a ticket that is already in shape.

## 3. Fix

Draft only the parts that are vague or missing, from the ticket, its comments and the repos. Do not invent requirements. Ask one question at a time for what the ticket and repos cannot answer, and when a part cannot be drafted without guessing.

Write the result into the description under these headings, and keep any text that already holds a part:

```
## Why
## What
## Fence
### Scope
### Must have
### Must avoid
### Good to have
### Conventions
## Sources
```

Show the proposed description change and wait for approval before each Jira write. Jira descriptions and comments are Markdown, not wiki markup. Do not put branch names in the ticket; the GitHub integration links them.

Intent belongs in the ticket and not in a `docs/plans/*.md` file. If a plan file already holds the why, what or fence for this ticket, say so, and offer to move it into the ticket.

## 4. Stop

Report which parts were present, which were fixed, and which are still open, with the open questions. Do not start the gap analysis or any implementation; those are separate steps.
