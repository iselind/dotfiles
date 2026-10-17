---
name: corrections_improve_repo_docs
description: When user corrects agent work, record it to .task/corrections.md; at stable point, apply the correction AND update repo docs to prevent the disagreement recurring
metadata:
  type: feedback
---

**When you correct an agent's work,** that correction reveals something the repo docs didn't guide toward. Transform it from a one-off fix into lasting institutional knowledge.

**Full Workflow:**

1. **Agent records** the correction to `.task/corrections.md` (see [[commit_at_stable_points]])
   - Freeform markdown, includes context
   - Does not apply immediately; keeps focus on current task
   
2. **At stable point** (all verification passes):
   - Agent applies the correction to relevant repo files
   - Delete `.task/corrections.md` once integrated
   
3. **You identify the missing guidance:**
   - Ask: "What repo docs would have prevented this disagreement?"
   - Examples: verification method, convention, constraint, gotcha, relationship
   - Add that guidance to repo docs (README, CONVENTION.md, ADRs, domain guides — rarely CLAUDE.md)
   
4. **Outcome:** The correction is now institutionalized. Future agents and teammates understand why that choice matters.

**Examples of missing guidance:**
- Verification tools (code needs tests, manifests need `kubectl explain` validation)
- Conventions (naming patterns, file organization, commit message format)
- Constraints (what not to do, what not to change, compatibility requirements)
- Gotchas (edge cases, common mistakes, non-obvious dependencies)
- Relationships (how components interact, when to coordinate with others)

**Why:** Repo docs are the source of truth for all agents and team members. Corrections only help in one conversation unless they update the shared knowledge. Each correction is a signal that docs are incomplete — fix them so the disagreement doesn't recur.

**How to apply:** After applying a correction at stable point, pause and identify what guidance was missing. If it's a verification method, point to the tool. If it's a cross-project pattern that repo docs can't capture, *then* add it to `~/.claude/rules/` — but that's the exception, not the default. The default is: update the repo.
