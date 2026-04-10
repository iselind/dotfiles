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

Branch commits (vs main): !`git log main...HEAD --oneline`

Changed files: !`git diff main...HEAD --stat`

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

---

## What makes a good ADR

Test every candidate against this question before drafting:

> *Would a new team member benefit from reading this in a year?*

If the answer is "they'd figure it out from the code", skip it.
If the answer is "they'd wonder why we did it this way", write it.

---

## Phase 1 — Identify candidates

**Step 1 — Read the branch**

Read the full diff and all changed files. You are looking for decisions, not
bugs or improvements — things that required a deliberate choice between real
alternatives.

Strong ADR signals:
- A layout or naming convention was established (directory structure, file
  naming, resource naming)
- One approach was chosen over another, and the reason is non-obvious
- A behaviour looks surprising without context (e.g. something that looks like
  an omission but is intentional)
- A constraint or tradeoff that future work on the same area needs to understand
- An alternative was explicitly rejected somewhere (comment, commit message,
  plan doc)

Weak signals — do not propose an ADR for these alone:
- Bug fixes with no architectural dimension
- Routine additions that follow an already-documented pattern
- Config changes whose rationale is self-evident from the values

**Step 2 — Read existing ADRs**

Read each file in `docs/adrs/`. For each existing ADR, note:
- Its number and topic (to avoid duplication)
- The highest number (to continue the sequence)

If there are no existing ADRs, the next number is 001.

**Step 3 — Identify gaps**

For each candidate decision, check whether it is already covered (fully or
partially) by an existing ADR. Skip anything already documented.

**Step 4 — Present the candidate list**

Output a numbered list of candidate decisions, one line each:

```
Candidates:
1. <Short description of decision>
2. <Short description of decision>
...

No candidates found.  ← if none
```

If there are no candidates, say so and ask the user if there is anything they
would like to add or capture before finishing — then wait for the response.
If there is anything that might need consideration, ask explicitly about those.

Otherwise ask: "Shall I draft all of these, or pick specific numbers?" — then
wait for the user's response before proceeding to Phase 2.

---

## Phase 2 — Draft and write

Work through the approved candidates one at a time.

**For each candidate:**

1. Draft the ADR following the format below.

2. Write the file immediately — do not wait for approval before writing:
   - Assign the next sequential number (ADR-NNN)
   - Filename: `docs/adrs/ADR-NNN-kebab-case-title.md`

3. The user reviews the file via the diff. Wait for one of:
   - **Approval** ("yes", "looks good", no comment) → commit the file, then
     move to step 4
   - **Edit request** → revise the file in place, then wait for approval again
   - **Rejection** ("skip", "no", "not this one") → delete the file and move on

4. After committing the ADR, check whether the decision material was sourced
   from a plan or other document on the branch. If so, replace the extracted
   content in the source document with a reference to the new ADR — the source
   should not duplicate what the ADR now captures. Commit this update alongside
   or immediately after the ADR commit.

5. After resolving any candidate (written, rejected, or accepted as already
   covered), consider whether the code that triggered the candidate is still
   ambiguous enough that a future reviewer would raise the same question. If so,
   propose a clarifying change (e.g. a better comment, a more explicit name).
   The candidate resolution addresses the *decision*; the clarifying change
   addresses the *trigger*. This applies equally when no candidates are found —
   if something looked like it might need an ADR but doesn't, the trigger is
   worth fixing.

Use a commit message in the style already used on this branch.

After the last candidate, report how many ADRs were written and their filenames.
Then proceed to Phase 3 — the skill is not complete until the retrospective runs.

---

## Phase 3 — Retrospective (mandatory)

This phase must always run — even when no candidates were found, even when the
skill is invoked as part of another skill. The skill is not finished until the
retrospective question has been asked and answered.

After Phase 2 is complete (or if no candidates were found and the user has
nothing to add), ask:

> "How did the **extract-adr** skill perform? Anything to do differently next
> time — steps to add, remove, or change?"

If the user has no feedback, end here.

If the user provides feedback:

1. Read the current skill file at
   `/home/patrik/.claude/skills/extract-adr/SKILL.md`
2. Make targeted edits that address the feedback — do not rewrite the file from
   scratch
3. The user reviews the changes via the IDE diff
4. Resolve the symlink `~/.claude/skills` to find the dotfiles repo, then
   commit and push the skill file change from that repo
5. Changes take effect on the next invocation of this skill
