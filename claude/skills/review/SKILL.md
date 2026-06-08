---
name: review
description: >
  Review the current branch and populate a tracking plan with found issues,
  then work through open issues one at a time. Use when the user asks to
  review a branch, review a plan, add review findings to a plan, or work
  through issues in a plan.
argument-hint: "[plan-file-path]"
user-invocable: true
---

# Review skill

Current branch: !`git branch --show-current`

<!-- git log origin/main..HEAD shows commits reachable from HEAD but not from origin/main,
     equivalent to using an explicit merge-base with `..`. git diff origin/main...HEAD
     (three dots) diffs from the merge-base to HEAD, equivalent to the two-dot form with
     an explicit merge-base. Both avoid command substitution which is blocked by the
     permission system. -->
Branch commits (vs main): !`git log origin/main..HEAD --oneline`

Changed files: !`git diff origin/main...HEAD --stat`

## Your job

Complete the phases below in order.

---

## Phase 0 — Register on skill stack

Determine the resume from the calling context visible in the conversation — identify where the calling skill continues after this skill completes. Then run:

```bash
skill-stack push review "<resume>"
```

Set `<resume>` to the single address — a phase name, step label, or other marker — where the calling skill should pick up once this skill completes. Derive this from the calling context visible in the conversation; if context is thin, read ahead in the calling skill's file as a fallback. If invoked standalone with no calling skill, omit the resume argument.

---

## Phase 1 — Review & populate the plan

**Step 1 — Find the plan**

If `$ARGUMENTS` is provided, use that path as the plan file. Confirm the file contains a status table and detailed sections. If it doesn't look right, ask the user. Also look through the branch's changes for any added or modified plan files that might be relevant; if multiple candidates exist, ask the user which plan found issues should go into.

Otherwise search for a tracking plan in `.github/`, `docs/plans/`, and the repo root — look for files named `*readiness*.md`, `*review*.md`, `*plan*.md`, `*tracker*.md`.

If no plan exists, create a review tracking file. Preferred pattern: `<plan-name>-review.md` alongside the plan (e.g. `helm-chart-migration-review.md`). This file is ephemeral — deleted when all items are resolved. Derive the name from the branch's plan file (present or recently deleted in git history). If the right location is genuinely unclear, ask before creating.

**Step 2 — Read the plan**

Understand: the status table format (columns, emoji conventions, item numbering), the format of detailed sections (how each item is written below the table), and all existing work items and their content.

**Step 3 — Review the branch**

Read the full diff and all changed files. Identify issues in these categories:

- **Bug** — code that is incorrect or could fail; for CI and test scripts specifically, check for fixed paths used as temporary state (two concurrent runs on the same runner will collide); for PromQL expressions, check that both sides of a vector join using `on(...)` are aggregated to the same label set as the join key — extra labels on either side not named in `on()` cause silent fan-out (left) or silently dropped series (right); when code collects items from a non-deterministic source (any unordered collection) and serializes or compares the result for idempotency, verify the items are sorted or otherwise canonicalized before serialization — without this, the same logical state can produce different bytes across calls; when a branch replaces X with Y (migrating frameworks, converting tests, swapping libraries, rewriting a component), read the deleted content alongside the additions and verify every behaviour or capability of X is covered by Y — migration gaps are silent by definition
- **Security** — credentials, injection risk, over-permissive access
- **Gap** — unspecified mechanism or missing prerequisite that forces an undocumented design decision on the implementer
- **Suggestion** — correct but improvable patterns or inconsistencies; for CI and test scripts specifically, flag package installs into global environments (prefer isolated venvs or temp dirs to avoid runner pollution and ensure reproducibility). When a filter, label selector, or guard is present on some items in a file, read the **full file** and verify it is applied to all analogous items — not just those in the diff. This applies equally to new files and modified files. When the same component is described in more than one place (different config profiles, deployment paths, packaging formats), verify that identity and configuration fields are consistent across all representations — not just the one touched by the diff. When a test assertion is tightened or a guard is added, scan the full test file for other assertions of the same form and apply the same tightening consistently — don't stop at the diff boundary.
- **Verification** — things that must be confirmed before merge
- **Cleanup** — dead code, stale comments, misleading names. When a diff changes the default value or activation condition of an input (e.g. empty string → real value, opt-in → always-active), check that the input's description doesn't use conditional framing that has become stale — phrases like "when provided", "if set", "callers adopting X", or "callers on the Y path" that imply the feature is optional when it is no longer so.
- **Overlap** — unwarranted duplication between plans, ADRs, and OPENs (e.g. a plan section restating rationale that an ADR now captures, or an OPEN repeating context already settled elsewhere)
- **Premature design** — detailed design content for work that is explicitly deferred, out of scope, or multiple stages removed from the current work. Look for: design notes for components marked as future or optional, detailed requirements or options for infrastructure that depends on unresolved prerequisites, work items that describe deferred steps at the same level of detail as immediate ones
- **Minor** — low-impact observations worth recording

**ADR and OPEN scrutiny:**

Branch-introduced ADRs/OPENs — full quality review:
- *Classification*: An ADR whose rationale depends on an unresolved question is premature — propose an OPEN instead. An OPEN whose question is already answerable from context should be promoted.
- *Cross-reference discipline*: ADRs must not reference documents with shorter expected lifespans (OPENs, plans). Such references become dangling when the shorter-lived document is deleted. If an ADR's rationale depends on an unresolved OPEN or an in-flight plan, the ADR itself is likely premature.
- *Section discipline*: Context must not preview or argue for options; Options must be complete with no missing failure modes or language that pre-empts the decision, and must describe approaches at the conceptual level (CRD names, API names, implementation artifacts belong in Design, not Options); Rationale must not repeat Options content.
- *Framing* (OPENs): Is the question well-posed? Is context factually accurate — no false implementation claims, no assertions about what "currently" exists unless verified? Are all options at comparable depth? Are analogies grounded by properties established in the document? An analogy that imports an assumption never stated in the document should be flagged regardless of whether it seems plausible.

Topically related ADRs/OPENs not on the branch — coherence check:
- Do new additions conflict with, duplicate, or leave gaps relative to existing documents? Does the whole set tell a coherent story now that new documents have been added? Flag tensions and inconsistencies. Do not propose rewriting settled documents — surface the issue and let the user decide.

**Plan work items:**
- For each work item: what would a developer need to know or decide that is not documented? If implementation would force an undocumented design decision, that is a Gap.
- Check dependencies on open questions. An unresolved OPEN affecting a work item without a stated dependency is a Gap — implicit dependencies are decided under implementation pressure, not deliberately.
- Flag descriptions that name an outcome without a mechanism ("scoped by label selector", "X is injected", "configured with the correct Y"). If the how is unspecified and the implementer would have to invent it, that is a Gap.
- Distinguish plan-level contract from implementation detail. A plan should state *what* contract must hold (e.g. "the tenant ID must be readable by the sync operator") without prescribing *how* it is satisfied (label, field, annotation). Flag items that over-specify implementation detail or under-specify the contract to the point the implementer cannot know what is required.
- Verify work items are consistent with relevant ADRs — both pre-existing and branch-introduced. A contradiction is a Bug, not a wording issue.


**Review scope:**

When a finding exceeds review scope, stop accumulating review items. Signs:
- It questions a core design decision the branch depends on, not just a consequence
- Resolving it would require changes significant enough to invalidate already-resolved review items
- It is iteration work on the architecture, not a bounded quality issue

The review tracking file is for bounded quality findings. Iteration work that reshapes the architecture belongs in the plan.

Present the finding to the user and ask how to proceed. Typical handling:
- Move the finding to the plan's Issues section (create one if needed)
- Mark related review items as postponed in the review file, pointing to the Issues section
- Continue with independent items that do not depend on the scope-exceeding issue

**Step 4 — Add new items to the plan**

In one edit: append a table row `| N | Short description | Type | ⬜ Open |` and append a detailed section following the exact heading, paragraph, and code-block style already used in the document.

If no new issues were found, say so. If there are existing open items, skip to Phase 2. If there are no open items at all, skip to Phase 3.

Commit the tracking file (or the updated plan) before waiting for the user's confirmation. This ensures findings survive a context reset between Phase 1 and Phase 2.

Tell the user: "Added items N–M to the plan. Ready to start with the next open issue?" — then wait for confirmation.

---

## Phase 2 — Work through open issues one at a time

**Before starting Phase 2, read `~/.claude/skills/review/conventions.md` — do not skip this step.**

Work through open (⬜) items in ascending order, one at a time.

**For each item:**

1. State the item number and describe the problem: what is wrong, where it is, and why it matters. Do not propose a fix yet — let the user engage with the problem first. Wait for the user to respond.

2. Once the user has engaged, propose a fix (and alternatives if they exist). Prefer structural fixes over scattered per-instance changes — if a single change point (e.g. a shared function, a global redirect, a convention) can replace many individual changes, propose that first. If there are alternatives, confirm which to implement before proceeding.

For collision or uniqueness bugs (two items competing for the same key, filename, or slot), consider both the disambiguation approach (make the key more specific) and the consolidation approach (merge into a shared container with a separator or composite) before proposing. One is not always better than the other.

3. Fix the issue. Read the relevant files first. Make the minimal, focused change. Apply the guidance in `conventions.md` throughout.

4. Update the plan: change `⬜ Open` to `✅ Done — <one-line resolution>`.

5. Stop for review: "Ready for review — let me know when you're ready to commit." Wait.

6. When the user's response clearly signals intent to commit — not just closes a side discussion — commit in the branch's style (look at recent commits for the pattern). If the response raises a new concern, addresses wording, or asks a question, treat it as continued review, not confirmation. **An affirmation that confirms a wording proposal ("yes", "looks good", "do that") is not a commit signal — it means implement the change. The step 5 review checkpoint must still be held after implementing it.** Then ask: "Ready for item N+1?" and wait.

   Do not add a "would `/review` have caught this?" reflection after each item — you are already running the review skill; the question is circular.

**Do not work on the next item until the user confirms the current one.**

If you reach the last open item and complete it, follow the normal confirmation flow for that item (step 4 → step 5 review → user confirms → step 6 commit).

**After all items — second pass**

Re-read every document edited during Phase 2. Check whether fixes introduced new issues. If found, present the list and ask: "These new issues surfaced from the edits — work through them, or skip?"

- **Work through them**: add to tracking file, continue Phase 2 loop, repeat pass after each round until clean or user skips.
- **Skip**: add as `⏭ Skipped — <reason>` then proceed to Phase 3.

If no new issues: "Second pass complete — no new issues. Ready to move to Phase 3 (extract-adr)?" Wait for confirmation.

> **STOP — do not enter Phase 3 until the user confirms the second pass is done.**

---

## Phase 3 — Extract architectural decisions

Move directly into `/extract-adr`. Do not ask for permission — this is a natural continuation of the review.

**Important:** Phase 3 runs before Phase 4 deliberately. Both the review tracking file and the plan may contain ADR-worthy material — the review file for its resolutions, the plan for its design rationale and work items. Do not delete either before extract-adr runs.

extract-adr runs its own mandatory retrospective before returning.

---

## Phase 4 — Delete completed documents

**Before deleting the tracking file**, read it and note internally:
- How many findings fall into each category: Bug, Security, Gap (heavyweight) vs Suggestion, Cleanup, Overlap, Premature design, Minor, Verification (lightweight).
- For each heavyweight finding, whether its fix was self-contained or disturbed shared infrastructure, a convention, or a load-bearing abstraction.

You will need both in Phase 6.

**Review tracking file:** If open items remain (extract-adr may have added new ones), return to Phase 2 and work through them using the normal review workflow. There is no need to re-run extract-adr afterward. Once all items are resolved, check for deletion.

**Plan file:** If all work items are complete and no open questions remain, the plan is ready to delete. Any "plan ready for deletion" cleanup item identified in Phase 1 belongs here; if it was deferred, handle it now.

The two checks are independent. Report each file's readiness separately. Ask for confirmation on each, then delete and commit. Do not bundle deletions of unrelated files.

---

## Phase 5 — Retrospective

Move directly into `/retro review`. Do not ask for permission — this is a natural continuation of the review.

---

## Phase 6 — Round assessment

Using the finding counts noted in Phase 4, assess whether another review round is warranted.

Present the heavyweight findings (Bug, Security, Gap) by number and one-line description. State your preliminary assessment: whether those findings were substantial enough — affecting correctness, requiring an undocumented design decision, or exposing a security issue — to warrant another round, or whether they were isolated and contained. If this is the second or later round and findings were markedly less substantial than the previous round, note that.

The more useful framing is not just "were findings substantial?" but "do these findings suggest there is another meaningful layer to discover — something a fresh context would likely find?" Iterative discovery, structural churn, and fixes that touched many locations are indicators that more may remain. Contained, well-bounded fixes with systematic coverage are indicators that the layer is clean.

A useful test: did any fix disturb shared infrastructure, a convention, or a load-bearing abstraction in a way that could propagate to adjacent code? If yes, that's a ripple-effect signal. If every fix was local and self-contained, that's a clean-convergence signal regardless of severity.

Wait for the user to confirm, correct, or add context.

After the user responds, state the verdict:

- **Warranted:** "Another round is warranted — [one sentence on what drove it]. Run `/clear` to reset context, then `/review` to start the next round."
- **Not warranted:** "No further rounds needed — [one sentence on why]."

---

## Final step — Pop skill stack

Phase 0 pushed exactly once; this pop fires exactly once to match it. Do not pop earlier in the skill — even if a phase feels "complete" mid-session.

```bash
skill-stack pop
```
