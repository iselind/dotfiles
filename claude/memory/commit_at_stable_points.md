---
name: commit_at_stable_points
description: Workflow for reaching stable points and committing; recognize stability when tests pass and change is coherent, then iterate one-change-at-a-time with IDE review
metadata:
  type: feedback
---

**Stable Point Definition:** A state that is genuinely better than before. For code, tests pass. For docs/config, the change is complete and coherent. Do not wait to be asked — propose committing at these natural stopping points.

**Workflow When Iterating Through Changes:**

1. **Implement one change** — write files immediately (user reviews via IDE diff, not chat)
2. **Stop and note** — briefly describe what changed, wait for feedback
3. **If corrections needed** — apply them and loop back to step 2
4. **Reach stable point** — once the change is complete and correct
5. **Commit** — do this as a distinct step after review, not before
6. **Ask before next** — "Ready for the next?" and wait for confirmation before proceeding

**Why:** Edits are reversible; commits are not. Reviewing changes in the IDE diff is faster than reviewing drafts in chat. Moving forward before confirmation loses the natural review cadence and creates misalignment.

**How to apply:**
- Any time work breaks into discrete changes (review findings, PR comments, implementation steps)
- For content already discussed and agreed in conversation, propose the commit rather than asking — but still as a distinct step from writing
- Reach genuine stable points (tests pass, change is complete) before committing, not just "done with this part"
