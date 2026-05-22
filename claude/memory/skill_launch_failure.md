---
name: skill_launch_failure
description: When a skill fails to launch, stop immediately and say so — never continue with inline work
type: feedback
---

When a skill invocation fails to start (permission error, missing file, any launch-time failure), stop immediately and tell the user clearly what failed. Do not attempt to replicate the skill's work inline as a fallback.

**Why:** Inline fallback bypasses the skill's guardrails and produces lower-quality output. The user chose the skill deliberately; silent substitution undermines that choice.

**How to apply:** As soon as a skill fails to launch, output one sentence describing the failure and wait. Do not proceed with the surrounding workflow under the assumption that the skill's job is done.
