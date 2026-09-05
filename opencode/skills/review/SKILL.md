---
name: review
description: >
  Review a completed task and consolidate useful task knowledge into the
  repository's permanent docs while discarding temporary working knowledge.
---

# Review a Change

Review the changes made to the current branch compared to main.

Focus on actionable defects rather than style preferences or summarizing the
diff.

Check for:

- Bugs, incorrect behavior, security issues, data loss, and compatibility problems
- Missing or inadequate tests
- Inconsistencies or contradictions between the code, tests, configuration, schemas, APIs, comments, and existing behavior
- Documentation that is missing, stale, contradictory, or insufficient to explain the change
- Does the implementation satisfy the intended task?
- Are important requirements missing?
- Are tests sufficient?
- Did implementation choices contradict existing repository knowledge?
- Did the task introduce a meaningful architectural or domain decision?

Inspect relevant surrounding code and call sites, not just changed lines. Validate each concern against a realistic execution path.

Report findings in priority order. For each finding, include:

- Severity: P0–P3
- File and line
- Concise explanation of the problem and its impact
- Suggested fix, when apparent

Do not report vague concerns or optional improvements. If no actionable issues are found, state that clearly. End with a brief assessment of whether the tests and documentation adequately support the change.
