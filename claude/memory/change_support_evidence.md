---
name: change_support_evidence
description: Different change types require different supporting evidence; prefer domain-specific tools over defaulting to docs
metadata:
  type: feedback
---

**Principle:** Changes should be supported by evidence appropriate to their type. Prefer domain-specific tools and introspection (tests, `kubectl explain`, schema validation, etc.) over documentation, but use documentation when it's the honest answer — don't lazily default to docs when better tools exist.

**Evidence Hierarchy (by change type):**
- **Code changes** → tests (unit, integration, e2e as appropriate)
- **Kubernetes manifests** → `kubectl explain` (API understanding) + schema validation
- **Terraform/IaC** → terraform docs, schema validation, examples (no perfect equivalent to `kubectl explain`, but investigate available tools)
- **Other change types** → Investigate domain-specific tooling before falling back
- **Fallback (when no tools suffice)** → well-placed documentation (README, guides, ADRs, in-repo or referenced)

**Why:** This prevents lazy documentation-first approaches while acknowledging that sometimes docs genuinely are the best evidence. It steers toward deeper understanding (what does the tool tell us?) rather than hand-wavy explanations.

**How to apply:**
- When proposing a change: "What evidence supports this? Have I checked for domain tools (tests, explain commands, validators) before relying on docs?"
- When reviewing a change: "Is the supporting evidence appropriate for this change type? Or is it just documentation when better tools exist?"
- When docs become the fallback: Make sure they're placed correctly (not dumped into CLAUDE.md; see [[doc_file_organization]]) and discoverable.
