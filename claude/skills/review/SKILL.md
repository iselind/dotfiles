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
- **Suggestion** — correct but improvable patterns or inconsistencies
- **Verification** — things that must be confirmed before merge
- **Cleanup** — dead code, stale comments, misleading names
- **Minor** — low-impact observations worth recording

For each issue, check the existing plan items — skip anything already tracked
(open or resolved).

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
   change that resolves the item. Before declaring the fix complete, check
   whether the fix should apply consistently to all sibling or parallel
   instances of the same pattern (e.g. if fixing one of four symmetric steps,
   verify the other three are correct too).

4. Update the plan: change `⬜ Open` to `✅ Done — <one-line resolution>` in
   the status table row for that item.

5. Stop for review. End with: "Ready for review — let me know when you're
   ready to commit." Then wait.

6. When the user confirms: commit with a message in the style already used on
   this branch (look at recent commits for the pattern). Then ask: "Ready for
   item N+1?" and wait.

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
  continue the Phase 2 loop. Do not do a third pass — this second pass runs
  exactly once.
- If the user says **skip**: add them to the tracking file as
  `⏭ Skipped — <reason>` so they are visible to later phases and not silently
  lost, then proceed to Phase 3.

If no new issues are found, proceed to Phase 3.

---

## Phase 3 — Extract architectural decisions

Move directly into `/extract-adr`. Do not ask for permission — this is a
natural continuation of the review.

**Important:** Phase 3 runs before Phase 4 deliberately. The review tracking
file may contain resolutions that are architectural decisions worth capturing
as ADRs (e.g., a bug fix that required choosing between approaches). The
extract-adr skill needs access to this file before it is deleted.

extract-adr runs its own mandatory retrospective before returning. When it
does, proceed directly to Phase 4 — do not treat extract-adr's completion as
the end of the review skill.

## Phase 4 — Delete the review tracking file

After the ADR extraction commit(s), read the review tracking file. Check
whether all items are resolved (no ⬜ Open rows remain). Report your
assessment to the user — either "all items resolved, ready to delete" or a
summary of what remains open — and ask for confirmation before deleting. Once
confirmed, delete the file and commit the deletion in its own dedicated commit
— do not bundle it with any other changes. Use a message in the style already
used on this branch.

---

## Conventions to follow

- Never skip an item without explaining why it is not applicable.
- If an item turns out to be a non-issue on closer inspection, update the plan
  to `✅ Accepted — <reason>` rather than silently skipping it.
- Keep fixes minimal — this is a review pass, not a refactor.
- If a fix has meaningful risk or side effects, flag it before proceeding.
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

---

## Phase 5 — Retrospective

Move directly into `/retro review`. Do not ask for permission — this is a
natural continuation of the review.
