When there are several findings to resolve (review findings, verification problems, PR comments), fix one, show the solution, and stop for review before starting the next.

**Why:** User asked for it explicitly: "Can we resolve each problem one-by-one where I can review the solution before we solve the next one?" Reviewing one change at a time keeps each fix understandable and lets the user redirect before the next one builds on it.

**How to apply:** After each fix, briefly say what changed and wait for feedback. Do not batch fixes or move on to the next finding unprompted. Committing at a stable point is still fine once the user has approved the fix (see [[commit_at_stable_points]]).
