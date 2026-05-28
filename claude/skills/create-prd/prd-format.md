# PRD Format

## File location

PRD files live in `docs/prds/<slug>.md` on a dedicated branch.

## Frontmatter

Every PRD must include a YAML frontmatter block with a `slug` field. The slug is used by
the orchestrator to associate issues with the PRD and to name the pre-run recovery tag.

```markdown
---
slug: my-prd-slug
---

# PRD: Title

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

## Branch naming

PRD branches follow the pattern `prd/<slug>` — e.g. `prd/add-check-target` for slug
`add-check-target`.

## Way of working

1. `/create-prd` — interview-driven PRD creation; produces a committed PRD on a new branch
2. `/prd-to-issues` — decomposes the PRD into issues; requires user confirmation before committing
3. `afk <prd-path>` — runs the orchestrator autonomously against the issues
4. `/review` — QA and review once all issues are complete

Human presence is required at steps 1 and 2 (confirmation checkpoints) and step 4 (review).
The orchestrator drives step 3 without supervision.
