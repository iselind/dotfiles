---
name: commit_at_stable_points
description: Workflow for reaching stable points and committing; stability = all verification for that change type passes (tests, kubectl explain, terraform validate+plan, etc.)
metadata:
  type: feedback
---

**Stable Point Definition:** All appropriate verification for the change type has passed. Do not wait to be asked — propose committing at these natural stopping points.

**Verification by change type** (see [[change_support_evidence]]):
- **Code changes:** tests pass
- **Kubernetes manifests:** `kubectl explain` validates fields and special considerations
- **Terraform/IaC:** `terraform validate` succeeds AND `terraform plan` succeeds (shows expected changes)
- **Documentation/config:** change is complete, coherent, and passes any linting
- **Other changes:** appropriate validation for that type has passed

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
- Before committing, run the appropriate verification: tests for code, `kubectl explain` for manifests, `terraform validate && terraform plan` for IaC, linting for docs
- For content already discussed and agreed in conversation, propose the commit rather than asking — but still as a distinct step from writing
- Do not commit until all appropriate verification passes — this defines "stable"
