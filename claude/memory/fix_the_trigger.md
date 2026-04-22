---
name: fix_the_trigger
description: After resolving any finding, consider whether the ambiguity triggering it is still present — if so, propose a clarifying change
type: feedback
---

After resolving any finding — whether fixed, skipped, or accepted as non-actionable — consider whether the ambiguity that triggered it is still present and would cause a future reader to raise the same question. If so, propose a clarifying change: a better comment, a clearer name, a more explicit structure, clearer prose.

The resolution fixes the *finding*; the clarifying change fixes the *trigger*.

**Why:** A fix that addresses the specific complaint can leave the underlying confusion intact, causing the same question to be raised again by the next reviewer.

**How to apply:** After any review item, PR comment, or similar finding is resolved. Applies whether the resolution was a code change or a decision to accept or skip.
