---
name: create-prd
description: >
  Conduct an interview-driven PRD creation process. Asks for an idea, interviews
  relentlessly one question at a time (with a recommended answer for each), explores
  the codebase when questions can be answered by reading code, then writes the PRD
  to docs/prds/<slug>.md with valid YAML frontmatter on a new branch, committed
  and pushed. Use when you want to go from an idea to a committed PRD.
user-invocable: true
---

# Create-PRD skill

PRD format, branch naming, and workflow conventions are in `prd-format.md` (companion
file in this skill directory). Read it before writing any PRD.

---

## Phase 1 — Capture the idea

**Ask for the idea before doing anything else.**

Say: "What's the idea?" — then wait. Do not explore the codebase, create a branch, or
take any other action until the user has described their idea.

---

## Phase 2 — Interview

Conduct a grill-me-style interview to reach shared understanding before writing anything.

**Rules:**
- Ask one question at a time — never bundle multiple questions.
- For every question, provide a recommended answer so the user can accept or redirect
  rather than starting from scratch. Format it as:
  > Recommended: [your suggested answer]
- If a question can be answered by exploring the codebase (e.g. "does this pattern
  already exist?", "what does the current API look like?"), read the relevant files
  instead of asking.
- Walk down each branch of the decision tree, resolving dependencies between decisions
  one at a time.
- Continue until you have reached shared understanding across all aspects: goal,
  motivation, requirements, constraints, definition of done, and out-of-scope items.

Areas to cover (not necessarily in this order — follow the natural dependency chain):

1. **Goal** — what outcome does this achieve?
2. **Motivation** — why is this needed now? What pain does it remove?
3. **Requirements** — what must the implementation do? Break into sub-components if applicable.
4. **Constraints** — what must the implementation respect (existing interfaces, tools, conventions)?
5. **Out of scope** — what is explicitly excluded to keep the PRD bounded?
6. **Definition of done** — what observable outcomes confirm the work is complete?

---

## Phase 3 — Human checkpoint before writing

Before creating the branch or writing any files, summarise your understanding:

- Proposed PRD title
- Proposed slug (kebab-case, e.g. `my-feature-name`)
- Key requirements (bullet list)
- Definition of done (bullet list)

Say: "Does this match your intent? Reply yes to proceed, or correct anything." Then wait.
Do not create the branch or write the PRD until the user confirms.

---

## Phase 4 — Create branch and write PRD

**Step 1 — Branch naming**

Branch names follow the pattern `prd/<slug>` where `<slug>` matches the PRD's `slug`
frontmatter field (see `prd-format.md` for the full convention).

Create and switch to the branch:

```
git checkout -b prd/<slug>
```

**Step 2 — Write the PRD**

Write the PRD to `docs/prds/<slug>.md`. The file must include a YAML frontmatter block
with a `slug` field (required by the orchestrator's preflight checks):

```markdown
---
slug: <slug>
---

# PRD: <Title>

## Goal
...

## Motivation
...

## Requirements
...

## Constraints
...

## Out of Scope
...

## Definition of Done
...
```

**Step 3 — Commit and push**

Stage and commit the PRD:

```
git add docs/prds/<slug>.md
git commit -m "Add PRD: <Title>"
git push -u origin prd/<slug>
```

Then report the branch name and file path to the user.
