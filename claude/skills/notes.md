# Claude Skills — Design Notes

Evolving thoughts on the skills ecosystem and future improvements.

---

## New task execution workflow (2026-09-10)

Implemented task-master, resolve, correction, consolidate-docs as a coherent workflow.
Replaces PRD-based approach (create-prd, prd-to-issues) with flexible `.task/` scratch space.

**Key insight:** `.task/` as durable scratch space + consolidate-docs promotion is more flexible
than prescriptive PRD structure. Adapts to task at hand rather than forcing template.

---

## Deprecation candidates

### `create-prd` and `prd-to-issues`
- **Status:** Candidate for deprecation
- **Rationale:** PRD-based approach felt "blunt" and didn't always hit the sweet spot
- **Valuable aspect:** The iterative "grilling" to flesh out understanding
- **Replacement:** task-master's Phases 1–5 provide similar clarification but more flexibly
- **Open question:** Is the grilling/questioning approach still useful as a distinct step, or does task-master cover it adequately?

### `retro`
- **Status:** Deprecate
- **Rationale:** Became a dumping ground for task-specific knowledge instead of promoting to repo docs
- **Replacement:** `.task/` scratch space + consolidate-docs captures and filters knowledge properly

### `jira` (skill)
- **Status:** Deprecate skill, replace with script/utility
- **Rationale:** Skills are too heavyweight for ticket operations; should be lightweight integration
- **Replacement concept:** Script that:
  1. Pulls task description from Jira ticket
  2. Seeds `.task/understanding.md` with it
  3. Triggers task-master (user-invoked or automated)
  4. Updates ticket comments and state when complete
- **Open questions:**
  - Should there be a wrapper skill orchestrating this, or just a standalone script?
  - How should task-master be invoked from Jira workflow? (manually, via state transition, CI hook?)

---

## Post-PR workflow gap

**Current flow:** task-master → resolve → consolidate-docs → ready for PR

**What happens after PR is created:** Unclear. Gap exists here.

**Existing fix-pr-comments skill:** Works through review comments, re-reviews, pushes.
Mixed results but the re-review after fixing comments did catch issues.

**Questions:**
- Should fix-pr-comments stay as a separate workflow after PR creation?
- Or should PR feedback loop back into task-master → resolve cycle?
- Is there value in a distinct "post-PR" workflow, or should all changes flow through task-master?

---

## Extract-adr

**Current state:** Standalone skill + invoked by review (Phase 3)

**Questions:**
- Is there value in keeping as standalone tool, or only-via-review?
- Should ADR extraction be optional in review, or always triggered?

---

## Review skill

**Current state:** Elaborate (219 lines) with many conventions and patterns

**Observation:** Some knowledge in the skill (specific patterns, conventions) probably
belongs in core-platform repo, not a generic Claude skill

**Potential improvement:** Slim down review to generic principles, make repository-specific
patterns configurable or loaded from repo's own conventions.md

---

## Grilling and iterative clarification

**Observation:** create-prd's iterative questioning to build understanding was valuable,
even though the overall PRD-based workflow felt limiting.

**Current approach:** task-master handles this in Phases 1–5 (establish → explore → build model
→ gap analysis → resolve questions).

**Question:** Is this sufficient, or should the grilling aspect be more explicit/aggressive?

---

## Skills vs. utilities

**Observation:** Some operations (Jira, linting, verification) might be better as lightweight
scripts/utilities rather than full skills. Skills carry overhead (phases, confirmation points,
elaborate reporting).

**Potential future direction:** Distinguish between:
- **Skills** — orchestration workflows that involve judgment/iteration (task-master, review, consolidate-docs)
- **Utilities** — lightweight operations invoked by skills (jira script, verification, linting)

---

## Future: Deprecation strategy

When removing skills, consider:
- Documentation of why (DEPRECATED.md in claude/skills/?)
- Migration path for users still using old skills
- Clear signaling about which new approach replaces it
