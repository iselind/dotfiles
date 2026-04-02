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

Branch commits (vs main): !`git log main...HEAD --oneline`

Changed files: !`git diff main...HEAD --stat`

## Your job

You have two phases. Complete phase 1 before starting phase 2.

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

If no plan exists, tell the user and ask where to create one before proceeding. The
preferred pattern is a separate `<plan-name>-review.md` file alongside the plan (e.g.
`helm-chart-migration-review.md` for `helm-chart-migration.md`). This keeps the plan
itself clean — it records what to do, not what reviewers found. The review file is
deleted when all items are resolved; it never outlives the plan it accompanies.

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

If no new issues were found, say so clearly and skip to phase 2.

After editing, tell the user: "Added items N–M to the plan. Ready to start
with item N?" — then wait for confirmation before beginning phase 2.

---

## Phase 2 — Work through open issues one at a time

Work through open (⬜) items in ascending order, one at a time.

**For each item:**

1. State the item number and describe the issue you are going
   to fix, the motivations why a fix is needed, and alternatives for fixing the
   issue. If there are alternatives, ask the user to confirm which one to
   implement before proceeding.

2. Fix the issue. Read the relevant files first. Make the minimal, focused
   change that resolves the item.

3. Update the plan: change `⬜ Open` to `✅ Done — <one-line resolution>` in
   the status table row for that item.

4. Stop and report what you did. Show the specific change (inline or as a
   brief diff summary) so the user has something concrete to review. End with:
   "Ready for review — let me know when you're ready to commit." Then wait.

5. When the user confirms: commit with a message in the style already used on
   this branch (look at recent commits for the pattern). Then ask: "Ready for
   item N+1?" and wait.

**Do not work on the next item until the user confirms the current one.**

If you reach the last open item and complete it, follow the normal confirmation
flow for that item (step 4 → user confirms → step 5 commit) before proceeding
to phase 3.

---

## Phase 3 — Delete the review tracking file

Once all items are committed, delete the review tracking file and commit the
deletion with a message in the style already used on this branch. Do not ask
for permission — the review is complete and the file has served its purpose.

## Phase 4 — Extract architectural decisions

After the deletion commit, move directly into `/extract-adr`. Do not ask for
permission — this is a natural continuation of the review.

---

## Conventions to follow

- Never skip an item without explaining why it is not applicable.
- If an item turns out to be a non-issue on closer inspection, update the plan
  to `✅ Accepted — <reason>` rather than silently skipping it.
- Keep fixes minimal — this is a review pass, not a refactor.
- If a fix has meaningful risk or side effects, flag it before proceeding.
