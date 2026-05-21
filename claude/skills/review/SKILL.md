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
     permission system. The fetch ensures origin/main is current. -->
Branch commits (vs main): !`git fetch origin main -q 2>/dev/null; git log origin/main..HEAD --oneline`

Changed files: !`git diff origin/main...HEAD --stat`

## Your job

You have multiple phases. Complete them in order.

---

## Phase 1 — Review & populate the plan

**Step 1 — Find the plan**

If `$ARGUMENTS` is provided, use that path as the plan file. The provided file
might not be the right one, so check the file contents to confirm it is a
tracking plan with a status table and detailed sections. If it doesn't look like
a plan, tell the user and ask for clarification. Look through the branch's
changes for any added or modified plan files that might be relevant and ask the
user which plan found issues should go into.

Otherwise, search the repository for a tracking plan. Look for markdown files
whose names suggest a readiness checklist, review tracker, or issue list
(e.g. `*readiness*.md`, `*review*.md`, `*plan*.md`, `*tracker*.md`) in
`.github/`, `docs/plans/`, and the repo root.

If no plan exists, create a review tracking file and proceed. The preferred pattern
is a separate `<plan-name>-review.md` file alongside the plan (e.g.
`helm-chart-migration-review.md` for `helm-chart-migration.md`). This keeps the plan
itself clean — it records what to do, not what reviewers found. The review file is
ephemeral: deleted when all items are resolved; it never outlives the plan it accompanies.

Derive the name from the branch's plan file (present or recently deleted in git history).
If the right location is genuinely unclear — multiple candidate plans, no obvious
sibling — tell the user and ask before proceeding.

**Step 2 — Read the plan**

Read the plan file. Understand:
- The format of the status table (columns, status emoji conventions, item numbering)
- The format of detailed sections (how each item is written below the table)
- The highest existing item number (so you can continue the sequence)
- Which items are already open (⬜) vs resolved (✅)

**Step 3 — Review the branch**

Read the full diff and all changed files. Identify issues across these categories:
- **Bug** — code that is incorrect or could fail
- **Security** — credentials, injection risk, over-permissive access
- **Gap** — an unspecified mechanism or missing prerequisite that would force an
  undocumented design decision on the implementer
- **Suggestion** — correct but improvable patterns or inconsistencies
- **Verification** — things that must be confirmed before merge
- **Cleanup** — dead code, stale comments, misleading names
- **Overlap** — unwarranted duplication between plans, ADRs, and OPENs (e.g. a plan
  section restating rationale that an ADR now captures, or an OPEN repeating context
  already settled elsewhere)
- **Premature design** — detailed design content for work that is explicitly deferred,
  out of scope, or multiple stages removed from the current work. Such content adds noise
  and distraction without benefiting immediate implementers; it will likely be stale by
  the time it becomes relevant. Look for: design notes for components that are marked as
  future or optional, detailed requirements or options for infrastructure that depends on
  unresolved prerequisites, and work items that describe deferred steps at the same level
  of detail as immediate ones.
- **Minor** — low-impact observations worth recording

When reviewing ADRs and OPENs specifically, apply two levels of scrutiny:

**Branch-introduced ADRs and OPENs — full quality review:**
- *Classification*: Is it correctly an ADR or OPEN? An ADR whose rationale depends
  on an unresolved question is premature and should be an OPEN. An OPEN whose
  question is already answerable from context in the document should be promoted.
- *Cross-reference discipline*: ADRs must not reference documents with a shorter
  expected lifespan — this includes OPENs (ephemeral, deleted when resolved) and plans
  (deleted when work completes). Such references become dangling when the shorter-lived
  document is deleted. If an ADR's rationale depends on an unresolved OPEN or an
  in-flight plan, the ADR itself is likely premature.
- *Section discipline*: Context should not preview or argue for options; Options
  should be complete with no missing failure modes or language that pre-empts the
  decision; Options describe approaches at the conceptual level — specific CRD names,
  API names, and implementation artifacts belong in the Design section, not Options;
  Rationale should not repeat Options content.
- *Framing* (OPENs): Is the question well-posed? Is context factually accurate —
  no false implementation claims, no assertions about what "currently" exists unless
  verified? Are all options presented at comparable levels of depth? Are analogies
  in options sections grounded — is the property they rely on established in the
  document for the things being compared? An analogy that imports an assumption
  never stated in the document should be flagged regardless of whether it seems
  plausible.

**Topically related ADRs and OPENs not introduced on the branch — coherence check:**
- Do the new additions conflict with, duplicate, or leave gaps relative to existing
  documents? Does the whole set tell a coherent story now that new documents have
  been added?
- Flag tensions or inconsistencies as review items. Do not propose rewriting
  existing settled documents — surface the issue and let the user decide.

**Plan work items — implementability review:**
- For each work item, ask: what would a developer need to know or decide before they
  could implement it that is not currently documented or resolved? If the
  implementation would force an undocumented design decision, that is a Gap.
- Check each work item's dependencies on open questions. An unresolved OPEN that
  affects how a work item is implemented should have that dependency stated in the
  plan. If it doesn't, flag it — an implicit dependency is a Gap, because the
  decision will be made under implementation pressure rather than deliberately.
- Look for descriptions that name an outcome without specifying a mechanism: phrases
  like "scoped by label selector", "X is injected", "configured with the correct Y",
  "synced to Z". Ask whether the mechanism is actually defined somewhere in the plan
  or its ADRs. If the how is unspecified and the implementer would have to invent it,
  that is a Gap.
- Distinguish plan-level contract from implementation detail. A plan should state
  *what* contract must hold (e.g. "the tenant ID must be readable by the sync
  operator") without prescribing *how* it is satisfied (label, field, annotation).
  Flag items where the plan conflates the two — either over-specifying implementation
  detail that belongs in the code, or under-specifying the contract to the point
  where the implementer cannot know what is required.
- Verify that work items are consistent with thematically relevant ADRs — both
  pre-existing and branch-introduced. A work item that contradicts or is
  incompatible with a settled ADR decision is a Bug, not a wording ambiguity.

For each issue, check the existing plan items — skip anything already tracked
(open or resolved).

**Review scope — recognising when a finding exceeds the review**

A review finds bounded quality issues within the scope of the branch as proposed.
When a finding is architectural enough to undermine the branch's foundational
decisions, it exceeds review scope. Signs:

- It questions a core design decision the branch depends on, not just a
  consequence of that decision
- Resolving it would require changes significant enough to invalidate already-resolved
  review items
- It is iteration work on the architecture, not a bounded quality issue

When this happens, stop accumulating review items. Present the finding to the user
and ask how to proceed. The typical handling:

- **Move the finding to the plan's Issues section** (create one if needed) — this
  preserves it as tracked work without polluting the review file with iteration concerns
- **Mark related review items as postponed** in the review file, pointing to the
  Issues section
- **Continue with independent review items** that do not depend on the scope-exceeding
  issue being resolved first

The review tracking file is for bounded quality findings. Iteration work that
reshapes the architecture belongs in the plan.

**Step 4 — Add new items to the plan**

For each new issue, in one edit:
1. Append a row to the status table: `| N | Short description | Type | ⬜ Open |`
2. Append a detailed section at the bottom of the file, following the exact
   heading, paragraph, and code-block style already used in the document.

If no new issues were found, say so clearly. If there are existing open (⬜)
items in the plan, skip to Phase 2. If there are no open items at all, skip to
Phase 3.

After editing, tell the user: "Added items N–M to the plan. Ready to start
with the next open issue?" — then wait for confirmation before beginning Phase 2.

---

## Phase 2 — Work through open issues one at a time

Work through open (⬜) items in ascending order, one at a time.

**For each item:**

1. State the item number and describe the problem: what is wrong, where it is,
   and why it matters. Do not propose a fix yet — let the user engage with the
   problem first. Wait for the user to respond.

2. Once the user has engaged, propose a fix (and alternatives if they exist).
   Prefer structural fixes over scattered per-instance changes — if a single
   change point (e.g. a shared function, a global redirect, a convention) can
   replace many individual changes, propose that first.
   If there are alternatives, ask the user to confirm which one to implement
   before proceeding.

3. Fix the issue. Read the relevant files first. Make the minimal, focused
   change that resolves the item. When the fix touches a sentence within a
   larger paragraph, re-read the full paragraph afterward — a local edit
   often reveals adjacent issues (wrong names, unclear pronouns, stale
   phrasing) that were masked by the original problem. Before declaring the
   fix complete, check whether the fix should apply consistently to all
   sibling or parallel instances of the same pattern (e.g. if fixing one of four symmetric steps,
   verify the other three are correct too). When the fix involves terminology,
   naming, or references, search across all documents in scope — a symptom in
   one file often has counterparts in others. When the fix involves writing new
   content — new descriptions, new sentences, new sections — verify the new
   content against the relevant ADRs and design documents. A fix that resolves
   the tracked issue while re-introducing a different class of error in the new
   text is not complete. When fixing a **Premature design** item by replacing
   removed content, this check matters most: the replacement text can silently
   reintroduce the same class of error under a different surface form. Watch for
   readiness claims about unimplemented work ("already designed to accommodate
   this", "already stubs X"), pre-commitments to a specific approach, or
   assumptions about interfaces that have not yet been defined. When in doubt,
   drop the forward reference entirely rather than rephrase it.

4. Update the plan: change `⬜ Open` to `✅ Done — <one-line resolution>` in
   the status table row for that item.

5. Stop for review. End with: "Ready for review — let me know when you're
   ready to commit." Then wait.

6. When the user's response clearly signals intent to commit — not just closes
   a side discussion or answers a question about the fix — commit with a message
   in the style already used on this branch (look at recent commits for the
   pattern). If the response raises a new concern, addresses wording, or asks a
   question, treat it as continued review, not confirmation. Then ask: "Ready
   for item N+1?" and wait.

**Do not work on the next item until the user confirms the current one.**

If you reach the last open item and complete it, follow the normal confirmation
flow for that item (step 4 → step 5 review → user confirms → step 6 commit).

**After all items are done — second pass**

Re-read every document that was edited during Phase 2. Check whether the fixes
introduced new issues that were not present before. If new issues are found,
present the list to the user and ask: "These new issues surfaced from the
edits — work through them, or skip?" Do not proceed to Phase 3 until the user
answers.

- If the user says **work through them**: add them to the tracking file and
  continue the Phase 2 loop. After that round completes, do another pass over
  the newly edited documents. Repeat until either no new issues are found or
  the user chooses to skip.
- If the user says **skip**: add them to the tracking file as
  `⏭ Skipped — <reason>` so they are visible to later phases and not silently
  lost, then proceed to Phase 3.

If no new issues are found, tell the user: "Second pass complete — no new issues. Ready to move to Phase 3 (extract-adr)?" and wait for confirmation before proceeding.

> **STOP — do not enter Phase 3 until the user confirms the second pass is done.**

---

## Phase 3 — Extract architectural decisions

Move directly into `/extract-adr`. Do not ask for permission — this is a
natural continuation of the review.

**Important:** Phase 3 runs before Phase 4 deliberately. Both the review
tracking file and the plan may contain material worth preserving as ADRs —
the review file for its resolutions, the plan for its design rationale and
work items. Do not delete either before extract-adr runs.

extract-adr runs its own mandatory retrospective before returning. When it
does, proceed directly to Phase 4 — do not treat extract-adr's completion as
the end of the review skill.

## Phase 4 — Delete completed documents

After the ADR extraction commit(s), check both the review tracking file and
the plan for deletion readiness.

**Review tracking file:** Check whether all items are resolved (no ⬜ Open
rows remain). If open items remain — extract-adr may have added new ones —
return to Phase 2 and work through them using the normal review workflow.
There is no need to re-run extract-adr afterward. Once all items are resolved,
return here.

**Plan file:** Check whether all work items in the plan are complete. If the
plan is fully done — all tasks implemented, no open questions — it is ready to
delete. Any "plan ready for deletion" cleanup item identified during Phase 1
belongs here, not in Phase 2; if it was deferred, handle it now.

The two checks are independent. The review tracking file can be deleted while
the plan remains, and vice versa. Report each file's readiness separately —
do not treat the result as binary. Ask for confirmation on each file that is
ready, then delete and commit. Do not bundle deletions of unrelated files.

---

## Conventions to follow

- Never skip an item without explaining why it is not applicable.
- If an item turns out to be a non-issue on closer inspection, update the plan
  to `✅ Accepted — <reason>` rather than silently skipping it. Then ask: could
  this same trigger recur in a future review pass? If a small, low-risk
  clarification would make the correct interpretation obvious on first read —
  without changing the substance — make it. An accepted item is resolved, but the
  reason it was raised may still be worth removing.
- Keep fixes minimal — this is a review pass, not a refactor.
- If a fix has meaningful risk or side effects, flag it before proceeding.
- When assessing the severity of a finding that involves an **implicit architectural
  assumption** — a design choice that silently constrains deployment topology,
  integration model, or operational context — do not default to "nice-to-have
  flexibility". Ask: for which deployment contexts does this assumption fail? If it
  fails for an entire class of deployment (air-gapped, on-prem, data-sovereign), the
  severity is high regardless of how natural the assumption feels in the current
  context.
- When an item involves cross-document references, capture the full scope in
  the item description — not just the visible symptom. Check both directions:
  that existing references are accurate AND that new content is reachable from
  the relevant context. A fix that only corrects one direction is incomplete.
- Before logging an external caller **migration concern**, verify the affected
  behaviour exists on `main`. If it was introduced on the current branch, no
  external caller has adopted it — the migration concern does not apply.
- When fixing a GitHub Actions workflow, verify that any variable referenced in
  a `run:` block is actually in scope for that step. `env:` is step-scoped —
  a variable defined in one step's `env:` block is not available in a later
  step unless that step also defines it.
- Before logging a **missing section** or completeness item, test whether the
  absent content would add information a reader could not derive from what is
  already present. If the document already conveys the substance, the item is a
  structural preference, not a real gap.
- When fixing an **ambiguous term or reference**, investigate what it actually
  refers to across the full document set before proposing a substitution. An
  ambiguous term may signal a conceptual gap — something genuinely underdefined
  — rather than a poor word choice. If so, the fix is a concept clarification,
  not a name substitution.
- After any fix that **moves or removes content**, compare the removed lines
  against the replacement to confirm no substance was silently dropped. Do not
  rely on a high-level read of the result — check line by line.
- When fixing a **partial description** — removing a count, a name, or a
  qualifier from a larger phrase — verify that the remaining text is still
  accurate for the current state. The removed element may not have been the
  only thing wrong; what's left can be just as misleading as what was taken out.
- When proposing a wording fix for a **data-flow or behavioral description**,
  establish the correct conceptual framing before suggesting a substitution —
  ask what intent is being described, not just which term is imprecise.
  Replacing one imprecise term with another is not an improvement.
- When two claims in the same document **contradict each other**, treat it as a
  signal worth investigating before proposing a fix. A surface contradiction often
  indicates a deeper design gap — the two claims may each be locally correct but
  incompatible at a structural level. Ask what architectural assumption would need
  to be true for both claims to hold simultaneously; if no such assumption exists,
  the fix belongs at the design level, not the surface claim. Note that the deeper
  issue may not be fully visible in the document — the author may hold relevant
  context that hasn't reached the text yet.
- When describing a finding that involves **plan language**, preserve the hedging
  actually present in the text. Plans often use tentative language ("expected",
  "likely", "would follow") — do not paraphrase this into stronger categorical
  claims ("rules out", "permanently abandoned"). Overstating what a plan commits
  to or rejects deflects the initial engagement before the user can confirm whether
  the inference is even correct.
- Before logging code behavior as a **Bug**, check whether a code comment
  acknowledges or explains that behavior. A comment citing a future work item
  ("X replaces this", "transitional until Y is implemented") signals intent, not
  oversight. In that case, the real finding is typically a documentation gap — does
  the plan explain the transitional design clearly enough? Redirect to a Cleanup
  finding if it does not.

---

## Phase 5 — Retrospective

Move directly into `/retro review`. Do not ask for permission — this is a
natural continuation of the review.
