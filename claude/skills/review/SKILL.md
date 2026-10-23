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

Review the branch, find issues, and fix them. Fixes go everywhere: code, comments, tests, documentation, CLAUDE.md, conventions.md, or plan files. The skill also maintains a learning loop through conventions: patterns discovered during review may become conventions, and conventions are audited to stay accurate.

Complete the phases below in order.

---

## Phase 1 — Review & populate the plan

**Step 1 — Find the plan**

If `$ARGUMENTS` is provided, use that path as the plan file. Confirm the file contains a status table and detailed sections. If it doesn't look right, ask the user. Also look through the branch's changes for any added or modified plan files that might be relevant; if multiple candidates exist, ask the user which plan found issues should go into.

Otherwise search for a tracking plan in `.github/`, `docs/plans/`, and the repo root — look for files named `*readiness*.md`, `*review*.md`, `*plan*.md`, `*tracker*.md`.

If no plan exists, create a review tracking file. Preferred pattern: `<plan-name>-review.md` alongside the plan (e.g. `helm-chart-migration-review.md`). This file is ephemeral — deleted when all items are resolved. Derive the name from the branch's plan file (present or recently deleted in git history). If the right location is genuinely unclear, ask before creating.

**Step 2 — Read the plan**

Understand: the status table format (columns, emoji conventions, item numbering), the format of detailed sections (how each item is written below the table), and all existing work items and their content.

**Step 3a — Unbiased environmental anchoring**

Spawn an agent in parallel using the Agent tool. The agent has no session context — it reads the diff cold. Use this prompt:

> You are reviewing a branch. Run `git diff origin/main...HEAD` to read the diff, then read the changed files in full.
>
> **Environmental anchoring:** Review by traversing outward through the codebase graph: start from the branch changes, understand context by examining related patterns/resources, and stop when signal-to-noise drops (typically within 2-3 steps). Do the changes make sense in the context of the codebase? Are they anchored in existing patterns and infrastructure?
>
> **Convention placement:** As you traverse, also verify: Are conventions documented at the appropriate level in the directory hierarchy? A convention buried too deep or too high won't be discoverable when it matters.
>
> Missing documentation is NOT a stop criterion — if something is hard to verify due to missing docs, that's a gap to report. DO stop at hypotheticals — if you're making assumptions about behavior you can't verify even with available information, that's noise.
>
> Report ONLY issues that need attention — do not comment on code that is working correctly. Return a plain list of findings, with no cap on the count. For each: one-line description, file and approximate location, why it matters, a severity (high / medium / low), and a short theme label (for example "terminology", "cross-repo scope", "convention placement") so related findings can be grouped later.

**Step 3b — Convention verification**

Load `conventions.md` from the repo root and any directory-specific `conventions.md` files that apply to the changed code. Read the full diff and all changed files yourself. Verify the changed code against the patterns documented in those files.

If no `conventions.md` exists, use the repo's equivalent, such as `CONVENTIONS.md` or `docs/CONVENTIONS.md` and the guides it links to (for ADRs and plans, e.g. `docs/plans-and-adrs.md`). Tell the user which files you are using in place of `conventions.md`, and use them wherever this skill says `conventions.md`.

Classify each finding into the categories in `conventions.md` (Bug, Security, Gap, Suggestion, Cleanup, etc.). If you find an issue pattern that is *not* covered by any convention in the repo, flag it as a potential convention: this pattern should potentially become one.

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

Wait for the Step 3a agent to complete. Combine its findings with your Step 3b findings — deduplicate where they overlap, and classify each into the tracking file categories above.

**Settled-decision check.** Before recording a finding, check it against decisions already made: the repo's ADRs, OPEN documents and plans, and any decision the user has made in this session. A finding that restates a settled decision is dropped, or rewritten as a confirmation that the decision holds. Do not record it as an open item. The 3a agent has no session context by design, so this check belongs to the orchestrator.

**Verify before recording.** Re-read the cited location and confirm the claim against the file. A finding that does not hold is dropped and noted in the report, not recorded.

**Group, do not cap.** Do not drop findings to keep the list short. Cluster the verified findings into groups:
- Each group is a theme, with one tracking item per group and one sub-bullet per finding.
- Rank groups by impact (Pareto): the few groups that remove most of the risk come first. Lower-ranked groups stay tracked and are deferred, not dropped.
- A group is well-sized when its resolution is one decision: it can be stated in one sentence and needs one question to the user. If a group needs two independent decisions, split it.
- Items that change the same concept belong in one group. Items that only share a file do not.
- Soft limit: about five sub-bullets is a prompt to check the decision test above, not a rule. A group with more sub-bullets that all serve one decision stays whole.

In one edit: append a table row per group `| N | Theme: short description | Type | ⬜ Open |` and append a detailed section for the group, with a lettered sub-bullet for each finding, following the exact heading, paragraph, and code-block style already used in the document.

If no new issues were found, run a secondary pass: explicitly identify the top 3 worst findings you can locate (even if minor — test gaps, brittleness, usability concerns, design inflexibilities). Present them ranked by severity with context about why they're not blocking. This gives the user visibility into what's present even in a clean review, and demonstrates the review actually looked critically. If there are existing open items, skip to Phase 2. If there are no open items at all, skip to Phase 3.

Commit the tracking file (or the updated plan) before waiting for the user's confirmation. This ensures findings survive a context reset between Phase 1 and Phase 2.

Tell the user: "Added items N–M to the plan. Ready to start with the next open issue?" — then wait for confirmation.

---

## Phase 2 — Work through open issues one at a time

**Before starting Phase 2, read `conventions.md` from the repo root (and any directory-specific ones that apply) — do not skip this step.**

Work through open (⬜) items in ascending order, one at a time. An item is a group: work through its sub-bullets together, and ask one question per group, not one per sub-bullet. If a sub-bullet turns out to need a separate decision while you work through the group, split it into its own item before going on.

**For each item:**

1. State the item number and describe the problem: what is wrong, where it is, and why it matters. For a group, name each sub-bullet briefly, then state the one decision the group needs. Do not propose a fix yet — let the user engage with the problem first. Wait for the user to respond.

2. Once the user has engaged, propose a fix (and alternatives if they exist). Prefer structural fixes over scattered per-instance changes — if a single change point (e.g. a shared function, a global redirect, a convention) can replace many individual changes, propose that first. If there are alternatives, confirm which to implement before proceeding.

For collision or uniqueness bugs (two items competing for the same key, filename, or slot), consider both the disambiguation approach (make the key more specific) and the consolidation approach (merge into a shared container with a separator or composite) before proposing. One is not always better than the other.

3. Fix the issue. Read the relevant files first. Make the minimal, focused change. Apply the guidance in `conventions.md` throughout.

4. Update the plan: change `⬜ Open` to `✅ Done — <one-line resolution>`. For a group, mark each sub-bullet done and the group row done once all are resolved.

5. Stop for review: "Ready for review — let me know when you're ready to commit." Wait.

6. When the user's response clearly signals intent to commit — not just closes a side discussion — commit in the branch's style (look at recent commits for the pattern). If the response raises a new concern, addresses wording, or asks a question, treat it as continued review, not confirmation. **An affirmation that confirms a wording proposal ("yes", "looks good", "do that") is not a commit signal — it means implement the change. The step 5 review checkpoint must still be held after implementing it.** Then ask: "Ready for item N+1?" and wait.

   Do not add a "what type of feedback surfaced in the PR review?" reflection after each item — you are already running the review skill; the question is circular.

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

## Phase 5 — Retrospective and conventions audit

Before running retro review, audit the conventions:

**Conventions audit:**
- Did 3a discover patterns in the codebase (beyond the actual branch changes) that should become conventions?
- Were there cases in 3b where you verified against a convention that works well? Note that — it's working.
- Were there cases in Phase 2 fixes where the pattern wasn't yet documented in conventions? Those are candidates for adding.
- Did any convention fail you — did you verify against it, but the code still had problems? That convention may need refinement.
- Are conventions at the right level in the directory hierarchy, or should any be moved?

Update `conventions.md` (and any directory-specific ones) based on what you learned. Commit those changes before moving to retro.

**Important:** The actual work is fixing code, comments, and documentation (which includes conventions.md as a documentation artifact). The conventions audit is infrastructure that supports the review process — it identifies patterns worth codifying. Do not let the audit eclipse the primary work of improving the branch.

Then move directly into retro review. Do not ask for permission — this is a natural continuation of the review.

---

## Phase 6 — Round assessment

Using the finding counts noted in Phase 4, assess whether another review round is warranted.

Present the heavyweight findings (Bug, Security, Gap) by number and one-line description. State your preliminary assessment: whether those findings were substantial enough — affecting correctness, requiring an undocumented design decision, or exposing a security issue — to warrant another round, or whether they were isolated and contained. If this is the second or later round and findings were markedly less substantial than the previous round, note that.

The more useful framing is not just "were findings substantial?" but "do these findings suggest there is another meaningful layer to discover — something a fresh context would likely find?" Iterative discovery, structural churn, and fixes that touched many locations are indicators that more may remain. Contained, well-bounded fixes with systematic coverage are indicators that the layer is clean.

A useful test: did any fix disturb shared infrastructure, a convention, or a load-bearing abstraction in a way that could propagate to adjacent code? If yes, that's a ripple-effect signal. If every fix was local and self-contained, that's a clean-convergence signal regardless of severity.

Wait for the user to confirm, correct, or add context.

After the user responds, state the verdict:

- **Warranted:** "Another round is warranted — [one sentence on what drove it]. Use /clear to reset context, run review to start the next round."
- **Not warranted:** "No further rounds needed — [one sentence on why]."
