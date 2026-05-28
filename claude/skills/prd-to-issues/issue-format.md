# Issue Format

## File location

Issue files live in `issues/<ID>-<slug>.md` — e.g. `issues/ISS-001-add-shellcheck.md`.

## Frontmatter

```markdown
---
id: ISS-001
title: Short descriptive title
status: not-started
prd-slug: my-prd-slug
branch: ""
failure-reason: ""
blocked-by:
  - id: ISS-002
    reason: "why this issue cannot start before ISS-002 is done"
---
```

## Fields

- **id** — sequential, assigned when drafting (ISS-001, ISS-002, …)
- **title** — short human-readable title
- **status** — one of `not-started`, `in-progress`, `done`, `failed`
- **prd-slug** — must match the `slug` field in the PRD frontmatter exactly
- **branch** — left empty when drafting; set by the orchestrator when work begins
- **failure-reason** — left empty when drafting; populated by the agent if status is `failed`
- **blocked-by** — list of objects with `id` and `reason` keys; empty list means unblocked

## Body

```markdown
## Story

As a [actor]
I want [goal]
So that [benefit]

## Acceptance Criteria

**Scenario: [name]**
Given [context]
When [action]
Then [outcome]

## Context

[Optional: implementation notes, constraints, hints the agent should know]
```

## DAG rules

- `blocked-by` forms a directed acyclic graph — no cycles
- Every `id` in a `blocked-by` list must refer to another issue in the same set
- Issues with no dependencies use `blocked-by: []`
- Phases are computed at runtime by topological sort; issues in the same phase run in parallel

## TDD mandate

All issue work follows the red-green-refactor cycle:

1. **Red** — write a failing test that captures the acceptance criteria
2. **Green** — write the minimum code to make the test pass
3. **Refactor** — clean up without breaking the test

## Agent contract

When the orchestrator dispatches an agent to work on an issue, the agent receives:
- Path to the PRD file
- Path to the issue file
- A git worktree on the issue branch

The agent must:
- Update `status` to `in-progress` as its first action
- Commit and push work to the issue branch as progress is made
- Update `status` to `done` when complete
- Update `status` to `failed` and populate `failure-reason` if unable to complete
