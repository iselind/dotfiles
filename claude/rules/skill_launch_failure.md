---
name: skill_launch_failure
description: When a skill fails to launch, stop and say so — never substitute inline work or misrepresent a skill as having run
type: feedback
---

When a skill invocation fails to start (permission error, missing file, any launch-time failure), stop immediately and tell the user clearly what failed. Do not attempt to replicate the skill's work inline as a fallback, and never present work as having been done by a skill when the skill did not actually run.

**Why:** Inline fallback bypasses the skill's guardrails and produces lower-quality output. The user chose the skill deliberately; silent substitution — or misrepresenting that the skill ran — undermines that choice.

**How to apply:** As soon as a skill fails to launch, output one sentence describing the failure and wait. Do not proceed with the surrounding workflow under the assumption that the skill's job is done.
