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
     permission system. -->
Branch commits (vs main): !`git log origin/main..HEAD --oneline`

Changed files: !`git diff origin/main...HEAD --stat`

Existing ADRs: !`ls docs/adrs/ 2>/dev/null || echo "(none)"`

## Your job

Identify architectural decisions made on this branch that are worth preserving as ADRs, draft each one, get approval, then write the files. Commit after each approved file.

---

## Phase 1 — Identify candidates

**Step 1 — Read the branch**

Read the full diff and all changed files. Also read the review tracking file if one exists (typically `*-review.md` alongside the branch's plan in `docs/plans/`) — use a Read tool call, not ambient context from a calling skill. Review resolutions often contain architectural decisions — a bug fix that required choosing between approaches, or a verification item whose resolution established a convention. These are easy to miss in the diff alone.

You are looking for decisions, not bugs or improvements — things that required a deliberate choice between real alternatives.

Strong ADR signals:
- A layout or naming convention was established
- One approach was chosen over another and the reason is non-obvious
- Behaviour looks surprising without context (looks like an omission but is intentional)
- A constraint or tradeoff that future work on the same area needs to understand
- An alternative was explicitly rejected (comment, commit message, plan doc)

Strong OPEN signals:
- A question came up during the work but was deferred or left unresolved
- Two or more real approaches exist with genuine trade-offs and no clear winner
- A decision was made but the team expressed uncertainty or flagged it for revisiting
- An implementation path is non-obvious and the options haven't been fully explored

Weak signals — do not propose for these alone:
- Bug fixes with no architectural dimension
- Routine additions that follow an already-documented pattern
- Config changes whose rationale is self-evident from the values
- Questions with an obvious answer that just hasn't been written down
- Conventions or patterns that are clearly better than not having them — where there was no real trade-off between alternatives. These belong in README or CLAUDE.md, not an ADR. The test: would a reasonable person have chosen differently? If not, there was no decision worth preserving.

**Step 2 — Read existing ADRs**

List all files in `docs/adrs/` and identify the correct next number for both ADRs and OPENs. Gaps can exist — check `git log --all --oneline -- docs/adrs/` if you suspect in-flight additions on other branches. Fill the lowest free slot rather than assuming max+1 is safe.

Read in full only the ADRs topically related to the branch's changed files — title and number alone are sufficient for unrelated ADRs.

If there are no existing ADRs, the next number is 001.

**Step 3 — Identify gaps**

For each candidate, check whether it is already covered by an existing ADR. Plans are ephemeral — if a candidate's rationale is documented only in the plan, treat it as undocumented.

For candidates closely related to an existing ADR, extending is only safe when both conditions hold: (1) the addition is purely additive — nothing in existing text is modified, qualified, or contradicted; (2) existing references are unaffected — scan plans, other ADRs, and docs for references to the target ADR; if any reference describes the ADR's scope in a way the extension would undermine, or sits near content the extension touches, a new ADR is safer. If either condition fails, propose a new ADR that cross-references the related one.

When both conditions hold, prefer extension over a new ADR if the candidate is a direct consequence of the existing ADR's chosen mechanism — a decision that only makes sense in the context of that mechanism. A satellite ADR whose rationale begins "because ADR-NNN chose X…" is a weaker home for the reasoning than the parent document itself.

**Non-ADR work surfaced during this skill**

While reading ADRs or discussing candidates, you may surface work that is not an ADR or OPEN — errors in branch-introduced ADRs (wrong attributions, missing cases, factual mistakes), documentation placement improvements, other follow-up. None of these are extract-adr's job to fix. When any such work surfaces:

1. Find the review tracking file (`*-review.md` alongside the plan in `docs/plans/`). If none exists, create one: `<plan-name>-review.md`.
2. Add each item as an open item.
3. Tell the user which file the items were added to and wait for acknowledgement before continuing.
4. Do not fix the issues inline — continue with extract-adr's own work.

> This acknowledgement is the STOP for the no-candidates path — do not proceed to Phase 2 until the user responds, even if both candidate lists are empty.

If this skill was invoked by the review skill, open items added here will be picked up in Phase 4 and routed back through Phase 2.

**Step 4 — Present the candidate lists**

Write a brief scan summary — one or two sentences covering what files were read, how many commits were on the branch, how many existing ADRs are topically related, and whether the review tracking file was checked (note how many items it contained and how many had architectural dimension). Example:

> "Scanned 12 commits, 4 changed files, and read ADR-007 and ADR-011 in full (the topically relevant ones). Review tracking file had 3 items, none with architectural dimension. No new decisions surfaced that aren't already captured."

Then output two lists — ADR candidates and OPEN candidates — one line each:

```
ADR candidates:
1. <Short description of settled decision>
2. Extend ADR-NNN: <short description of the addendum>

OPEN candidates:
1. <Short description of unresolved question>

No candidates found.  ← if neither list has entries
```

Either or both lists may be empty. Present both regardless.

For OPEN candidates that closely parallel a file intentionally deleted on the same branch, lead the description with that tension — state it before the trade-off analysis.

If neither list has entries, say so and ask the user if there is anything they would like to add or capture before finishing. If there is anything that might need consideration, ask explicitly about it.

> **STOP — do not proceed to Phase 2 until the user has responded explicitly.**

Otherwise ask: "Shall I draft all of these, or pick specific numbers?" — then wait.

---

## Phase 2 — Draft and write

**Before drafting, read `~/.claude/skills/extract-adr/adr-format.md` and `~/.claude/skills/extract-adr/open-format.md` — do not skip this step.**

Work through approved candidates one at a time. If the user said "draft all", write all files first, then present them to the user. Then go through each for approval and commit **one at a time** — ask "ADR-NNN looks good?" for each, wait for the response, commit that one, then move to the next. Do not batch commits. A single "ready" signal after seeing multiple ADRs is approval for review, not a commit signal for all of them.

When drafting, verify that enumerated sets meant to be complete (options considered, failure modes, required steps) are exhaustive. Illustrative examples in generic decisions should be marked with "e.g." or "in the current implementation" rather than expanded to a complete enumeration.

Before writing the Options section, verify each option is executable within the actual deployment model. Confirm the artifacts each option claims to act on exist at the point it claims to act — e.g., in a GitOps pipeline, distinguish between what is present in the source tree at packaging time vs what is rendered by controllers at runtime. An option that cannot act on what it claims to act on is not a real option; describe what it would actually require instead.

Before writing the Rationale, check each failure mode attributed to a rejected option: does the chosen option also exhibit that failure mode, even partially? If so, acknowledge it in the Rationale rather than stating the chosen option avoids the problem entirely.

**For each ADR candidate:**

1. Draft following the ADR format in `adr-format.md`.
2. Write the file immediately to `docs/adrs/ADR-NNN-kebab-case-title.md`. Do not wait for approval.
3. Wait for user response:
   - **Approval** ("yes", "looks good", no comment) → commit, then go to step 4
   - **Edit request** → revise in place, wait for approval again
   - **Rejection** ("skip", "no", "not this one") → delete the file. Check whether the source content in the plan fits better in a Future Directions section; propose the move proactively.
4. After committing, replace extracted content in the source document with a reference to the new ADR. Commit this alongside or immediately after the ADR commit. Do not skip this step for any individual ADR.

**For each OPEN candidate:**

1. Draft following the OPEN format in `open-format.md`.
2. Write the file immediately to `docs/adrs/OPEN-NNN-kebab-case-title.md`.
3. Wait for user response: Approval → commit; Edit request → revise; Rejection → delete.

Use commit messages in the style already used on this branch.

After the last candidate, report how many ADRs were written and their filenames. Confirm all plan edits (relocations, removals, reference additions) are committed before proceeding.

---

## Phase 3 — Retrospective (mandatory)

This phase must always run — even when no candidates were found, even when invoked as part of another skill.

Move directly into `/retro extract-adr`. Do not ask for permission.

After the retrospective completes, if this skill was invoked by another skill with remaining phases, explicitly tell the user which skill invoked it and that control is returning. Do not assume the invoking skill continues automatically — make the handoff visible so remaining phases are not silently skipped.
