---
name: disagreement_signals_incomplete_docs
description: When you (the human) disagree with an agent's choice, the repo docs didn't guide properly — update docs to cover what's missing
metadata:
  type: feedback
---

**You (the human) disagree with a choice an agent made** — the repo's documentation didn't adequately guide the agent. This could be missing guidance on verification methods, conventions, constraints to avoid, gotchas to keep in mind, or other aspects of how to work in this repo.

**Examples of what might be missing:**
- Verification tools (code needs tests, manifests need `kubectl explain` validation)
- Conventions (naming patterns, file organization, commit message format)
- Constraints (what not to do, what not to change, compatibility requirements)
- Gotchas (edge cases, common mistakes, non-obvious dependencies)
- Relationships (how components interact, when to coordinate with others)

**Process:**
1. **Identify what guidance was missing** — what would have guided the agent toward the right choice? (verification step, convention, constraint, gotcha, etc.)
2. **Fix the repo docs** — add that guidance in the appropriate place (README, CONVENTION.md, ADRs, domain guides — usually NOT CLAUDE.md)
3. **Not personal memory** — the goal is shared team visibility, not just guiding Claude in future conversations

**Why:** Updated repo docs help you, your colleagues, and future agents understand how to work in this repo. Personal memories only help in your conversations with Claude — they miss the team entirely. The repo is the source of truth.

**How to apply:** When you disagree with an agent's choice, ask: "What guidance would have prevented this choice?" Add that to the repo docs. If it's a verification method, point to the tool (don't replace the tool with docs). If it's a cross-project pattern that repo docs genuinely can't capture, *then* consider global memory — but that's the exception, not the default.
