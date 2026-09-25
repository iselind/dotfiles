---
name: disagreement_signals_incomplete_docs
description: When an agent makes a choice you disagree with, the repo docs are likely incomplete — fix them there, not in personal memory
metadata:
  type: feedback
---

When you disagree with how an agent solved a problem or chose an approach, it usually signals that the repo's documentation is incomplete or unclear — not that the agent made a random mistake.

**Process:**
1. **Identify what's missing** — what docs would have prevented this choice?
2. **Fix the repo docs** — add the clarification in the appropriate place (README, CONVENTION.md, ADRs, domain-specific guides — usually NOT CLAUDE.md)
3. **Not personal memory** — the goal is shared team visibility, not just guiding Claude in future conversations

**Why:** Updated repo docs help you, your colleagues, and future agents. Everyone has access to them. Personal memories only help in your conversations with Claude — they miss the team entirely. The repo is the source of truth.

**How to apply:** When disagreement arises, ask: "What documentation would have made this choice obviously wrong?" Fix that gap in the repo, in the appropriate file. If it's a cross-project pattern that repo docs genuinely can't capture, *then* consider global memory — but that's the exception, not the default.
