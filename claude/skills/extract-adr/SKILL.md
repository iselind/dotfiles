---
name: extract-adr
description: >
  Scan the current branch for architectural decisions worth preserving as ADRs,
  then draft and write approved ADR files. Use when finishing a branch, after a
  review, or any time you want to check whether a decision made on a branch
  deserves documentation.
user-invocable: true
---

# Extract-ADR skill

Current branch: !`git branch --show-current`

<!-- git log origin/main..HEAD shows commits reachable from HEAD but not from origin/main,
     equivalent to using an explicit merge-base with `..`. git diff origin/main...HEAD
     (three dots) diffs from the merge-base to HEAD, equivalent to the two-dot form with
     an explicit merge-base. Both avoid command substitution which is blocked by the
     permission system. The fetch ensures origin/main is current. -->
Branch commits (vs main): !`git fetch origin main -q 2>/dev/null; git log origin/main..HEAD --oneline`

Changed files: !`git diff origin/main...HEAD --stat`

Existing ADRs: !`ls docs/adrs/ 2>/dev/null || echo "(none)"`

## Your job

Identify architectural decisions made on this branch that are worth preserving
as ADRs, draft each one, get approval, then write the files. We commit the
changes after the user has reviewed the diffs and approved the changes.

---

## ADR format

```markdown

# ADR-NNN: Title in sentence case

## Context

What situation or forces led to this decision? Include:
- The problem or need being addressed
- Constraints that ruled out other approaches
- Any alternatives that were seriously considered and why they were rejected

Keep this factual and specific to what actually happened on this branch.

## Options considered

For each option, present a pro/con analysis (table or list) so the reader can
follow the reasoning that led to the decision. Name the options clearly
(e.g. "Option A: …", "Option B: …") so the Decision section can refer back.

## Decision

What was decided. One or two paragraphs, stated directly.
If the decision has multiple parts, use sub-headings or a list.

## Rationale

Why this decision is correct given the context above. Focus on the reasoning
that a future reader could not reconstruct from the code alone. If an
alternative was rejected, explain why here rather than in Context.
```

**Format rules:**
- Title uses sentence case (not title case): `ADR-003: Foo bar baz`, not
  `ADR-003: Foo Bar Baz`
- No status field — the branch/PR workflow provides status
- Sub-headings within Rationale are fine when the reasoning has distinct parts
- Code blocks and tables are fine where they clarify
- Do not reference specific tickets (Jira, GitHub issues, etc.) by ID in ADR
  content. Tickets are ephemeral and add context-dependency — describe the
  problem or constraint directly instead. Ticket IDs may appear in filenames
  (e.g. a hook script named after its ticket) when quoting that filename as an
  example, but never as a reference to follow for context.

---

## OPEN format

```markdown
# OPEN-NNN: Title in sentence case

## Question

What is the unresolved question?

## Context

What situation or forces surfaced this question? What work on this branch
made it relevant? Include what is already known or settled so the reader
starts with a clear baseline.

## Options considered

For each option, present a pro/con analysis (table or list). Name options
clearly so they can be referenced in discussion.

## Open questions

What needs to be resolved, learned, or decided before a conclusion can
be reached?
```

Before listing something as an open question, test it: could it be answered
from the context already established in the document or the branch? If yes,
move it to Context as a settled fact rather than listing it as open.

**Format rules:**
- OPEN documents use a separate number sequence from ADRs: OPEN-001, OPEN-002, …
- No Decision or Rationale sections — those do not exist yet
- When the question is decided, the OPEN becomes the foundation for an ADR:
  Context transfers directly, Decision and Rationale are added, OPEN is deleted
- OPEN documents are never referenced by ADRs (the reference would outlive the file)

---

## What makes a good ADR

Test every ADR candidate against this question before drafting:

> *Would a new team member benefit from reading this in a year?*

If the answer is "they'd figure it out from the code", skip it.
If the answer is "they'd wonder why we did it this way", write it.

## What makes a good OPEN

Test every OPEN candidate against this question before drafting:

> *Would future work in this area need to rediscover these trade-offs without this document?*

If the answer is "the trade-offs are obvious or already captured", skip it.
If the answer is "someone will need to decide this and the analysis is worth preserving", write it.

An OPEN is not a failed ADR — it is a different artifact. Something can clearly
not merit an ADR (the decision is obvious) but still merit an OPEN (how to
implement it has real unresolved trade-offs). Evaluate both independently.

---

## Phase 1 — Identify candidates

**Step 1 — Read the branch**

Read the full diff and all changed files. Also check for a review tracking file
(typically `*-review.md` alongside the branch's plan). Review resolutions often
contain architectural decisions — a bug fix that required choosing between
approaches, or a verification item whose resolution established a convention.
These are easy to miss in the diff alone.

You are looking for decisions, not bugs or improvements — things that required
a deliberate choice between real alternatives.

Strong ADR signals:
- A layout or naming convention was established (directory structure, file
  naming, resource naming)
- One approach was chosen over another, and the reason is non-obvious
- A behaviour looks surprising without context (e.g. something that looks like
  an omission but is intentional)
- A constraint or tradeoff that future work on the same area needs to understand
- An alternative was explicitly rejected somewhere (comment, commit message,
  plan doc)

Strong OPEN signals:
- A question came up during the work but was deferred or left unresolved
- Two or more real approaches exist with genuine trade-offs and no clear winner
- A decision was made but the team expressed uncertainty or flagged it for revisiting
- An implementation path is non-obvious and the options haven't been fully explored

Weak signals — do not propose an ADR or OPEN for these alone:
- Bug fixes with no architectural dimension
- Routine additions that follow an already-documented pattern
- Config changes whose rationale is self-evident from the values
- Questions with an obvious answer that just hasn't been written down yet

**Step 2 — Read existing ADRs**

List all files in `docs/adrs/` to identify the highest existing number and
avoid duplication. Read in full only the ADRs that are topically related to
the branch's changed files — title and number alone are sufficient for
unrelated ADRs.

If there are no existing ADRs, the next number is 001.

**Step 3 — Identify gaps**

For each candidate decision, check whether it is already covered (fully or
partially) by an existing ADR. Skip anything already documented.

For candidates that are closely related to an existing ADR, consider whether
extending that ADR is more appropriate than writing a new one. Extending is
only safe when both conditions hold:

1. **The addition is purely additive** — a new section appended to the existing
   ADR. Nothing in the existing text is modified, qualified, or contradicted.
2. **Existing references are unaffected** — scan plans, other ADRs, and docs for
   references to the target ADR. If any reference describes the ADR's scope in a
   way the extension would undermine, or sits near content the extension touches,
   a new ADR is safer.

If either condition fails, propose a new ADR that cross-references the related
one instead.

**Step 4 — Present the candidate lists**

Output two lists — ADR candidates and OPEN candidates — one line each. For each
ADR candidate that should extend an existing ADR rather than create a new one,
note the target ADR explicitly:

```
ADR candidates:
1. <Short description of settled decision>
2. Extend ADR-NNN: <short description of the addendum>
...

OPEN candidates:
1. <Short description of unresolved question>
...

No candidates found.  ← if neither list has entries
```

Either or both lists may be empty. Present both regardless.

If neither list has entries, say so and ask the user if there is anything they
would like to add or capture before finishing. If there is anything that might
need consideration, ask explicitly about those. **STOP. Do not proceed to
Phase 3 until the user has responded — wait for an explicit reply.**

Otherwise ask: "Shall I draft all of these, or pick specific numbers?" — then
wait for the user's response before proceeding to Phase 2.

---

## Phase 2 — Draft and write

Work through the approved candidates one at a time. ADR and OPEN candidates
follow the same write-immediately flow — write first, refine through targeted
edits using line numbers, then commit.

**For each ADR candidate:**

1. Draft the ADR following the ADR format above.

2. Write the file immediately — do not wait for approval before writing:
   - Assign the next sequential ADR number (ADR-NNN)
   - Filename: `docs/adrs/ADR-NNN-kebab-case-title.md`

3. The user reviews the file via the diff. Wait for one of:
   - **Approval** ("yes", "looks good", no comment) → commit the file, then
     move to step 4
   - **Edit request** → revise the file in place, then wait for approval again
   - **Rejection** ("skip", "no", "not this one") → delete the file and move on

**For each OPEN candidate:**

1. Draft the OPEN document following the OPEN format above.

2. Write the file immediately — do not wait for approval before writing:
   - Assign the next sequential OPEN number (OPEN-NNN), separate from ADR numbers
   - Filename: `docs/adrs/OPEN-NNN-kebab-case-title.md`

3. The user reviews the file via the diff. Wait for one of:
   - **Approval** → commit the file, then move to step 4
   - **Edit request** → revise the file in place, then wait for approval again
   - **Rejection** → delete the file and move on

4. After committing the ADR, check whether the decision material was sourced
   from a plan or other document on the branch. If so, replace the extracted
   content in the source document with a reference to the new ADR — the source
   should not duplicate what the ADR now captures. Commit this update alongside
   or immediately after the ADR commit.

Use a commit message in the style already used on this branch.

After the last candidate, report how many ADRs were written and their filenames.
Then proceed to Phase 3 — the skill is not complete until the retrospective runs.

---

## Phase 3 — Retrospective (mandatory)

This phase must always run — even when no candidates were found, even when the
skill is invoked as part of another skill.

Move directly into `/retro extract-adr`. Do not ask for permission.

After the retrospective completes, if this skill was invoked by another skill
that has remaining phases to execute, explicitly tell the user which skill
invoked it and that control is returning to that skill. Do not assume the
invoking skill will continue automatically — make the handoff visible so
remaining phases are not silently skipped.
