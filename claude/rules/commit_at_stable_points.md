---
name: commit_at_stable_points
description: Workflow for reaching stable points and committing; stability = all verification passes AND all corrections from .task/corrections.md are integrated
metadata:
  type: feedback
---

**Stable Point Definition:** A change has reached a stable point when (1) all appropriate verification has passed, AND (2) any corrections recorded in `.task/corrections.md` have been applied to the repo and the file has been deleted.

**Verification by change type** (see [[change_support_evidence]]). A change may involve multiple types — verify all of them:
- **Code changes:** tests pass
- **Kubernetes manifests:** `kubectl explain` validates fields and special considerations
- **Terraform/IaC:** `terraform validate` succeeds AND `terraform plan` succeeds (shows expected changes)
- **Documentation/config:** change is complete and coherent (docs currently have no formal verification)
- **Other changes:** appropriate validation for that type has passed

**Workflow When Iterating Through Changes:**

1. **Implement one change** — write files immediately (user reviews via IDE diff, not chat)
2. **Stop and note** — briefly describe what changed, wait for feedback
3. **If corrections needed** — agent records them in `.task/corrections.md` (see [[record_corrections_to_task]]), does not apply immediately; loop back to step 2 if more work on current change
4. **Run verification** — once the change is complete, run appropriate verification (tests, terraform plan, etc.) until all passes
5. **Apply corrections** — integrate all corrections from `.task/corrections.md` into relevant repo files, then delete the corrections file
6. **Commit** — this is implied when stable point is reached; do not wait to be asked
7. **Ask before next** — "Ready for the next?" and wait for confirmation before proceeding

**Why:** Edits are reversible; commits are not. Recording corrections without applying them immediately keeps focus on current work. Verifying first ensures the baseline is sound before integrating feedback. Committing at natural stopping points creates a clear history.

**How to apply:**
- Any time work breaks into discrete changes (review findings, PR comments, implementation steps)
- When user provides corrections, don't apply immediately — let agent record them and continue focused work
- Before committing, run the appropriate verification: tests for code, `kubectl explain` for manifests, `terraform validate && terraform plan` for IaC
- Once verification passes, apply all corrections and commit as a natural next step
- Do not advance to the next change until stable point is reached and committed
