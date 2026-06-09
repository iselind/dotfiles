# Review skill — improvement notes

## Restructure 3b as a pattern checklist, not a discovery pass

**Problem:** Steps 3a and 3b overlap significantly. 3a (agent, generic prompt) and 3b
(structured review) both do *discovery* over similar territory — bug, security, missing
tests, docs gaps. The PR bot's simple prompt still finds issues the review skill misses,
suggesting accumulated specificity constrains rather than expands what gets found.

**Key insight:** The review skill's value isn't its categories (Bug, Security, Gap, etc.)
— those mirror the bot's prompt and create the overlap. The actual value is the specific
heuristics *within* those categories: PromQL join issues, non-deterministic serialization,
DeferCleanup pairing, log drain isolation, migration completeness, CLAUDE.md compliance,
ADR/OPEN scrutiny. These require domain knowledge the generic prompt won't apply.

**Proposed fix:** Reframe 3b from "identify issues in these categories" (discovery) to
"check for these specific patterns that the generic pass in 3a is unlikely to catch"
(targeted pattern verification). The categories become taxonomy for classifying findings
at Step 4, not a discovery prompt. 3a does open discovery; 3b does pattern verification.

This restructure preserves all accumulated heuristics while eliminating the conceptual
overlap with the agent pass.
