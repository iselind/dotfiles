---
name: disagreement_signals_incomplete_docs
description: When you (the human) disagree with an agent's choice, repo docs didn't guide to the right verification tool — update docs to point to that tool
metadata:
  type: feedback
---

**You (the human) disagree with a choice an agent made** — e.g., agent submits a k8s manifest without validating it with `kubectl explain`. This signals that the repo's documentation didn't guide the agent to the right verification method or tool.

**The connection to change_support_evidence:** Different change types have different evidence hierarchies (tests for code, `kubectl explain` for manifests, terraform tools for IaC, docs as fallback). When you disagree, the agent likely skipped the right verification step because the repo docs don't mention it.

**Process:**
1. **Identify the verification tool/process that was missed** — what should have been used? (tests, `kubectl explain`, schema validation, terraform docs, etc.)
2. **Fix the repo docs** — document that verification step in the appropriate place (README, CONVENTION.md, ADRs, domain guides — usually NOT CLAUDE.md). Example: "k8s manifest changes must be verified with `kubectl explain`" or "code changes must include tests"
3. **Not personal memory** — the goal is shared team visibility, not just guiding Claude in future conversations

**Why:** Updated repo docs help you, your colleagues, and future agents use the right verification tools. Personal memories only help in your conversations with Claude — they miss the team entirely. The repo is the source of truth.

**How to apply:** When you disagree with an agent's choice, ask: "What verification tool or process should have been used here?" Add that guidance to the repo docs, pointing to the tool (not replacing it with documentation). If it's a cross-project pattern that repo docs genuinely can't capture, *then* consider global memory — but that's the exception, not the default. See [[change_support_evidence]] for the evidence hierarchy.
