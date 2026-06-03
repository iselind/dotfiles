# Issue Format

## File location

Issue files live in `issues/<ID>-<slug>.md` — e.g. `issues/ISS-001-add-shellcheck.md`.

## Frontmatter

```yaml
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
phases:
  - id: 1
    status: not-started
    after: []
  - id: 2
    status: not-started
    after: [1]
  - id: 3
    status: not-started
    after: []
---
```

## Fields

- **id** — sequential, assigned when drafting (ISS-001, ISS-002, …)
- **title** — short human-readable title
- **status** — one of `not-started`, `in-progress`, `done`, `failed` — reflects overall issue state
- **prd-slug** — must match the `slug` field in the PRD frontmatter exactly
- **branch** — left empty when drafting; set by the orchestrator when work begins
- **failure-reason** — left empty when drafting; populated by the agent if status is `failed`
- **blocked-by** — list of objects with `id` and `reason` keys; empty list means unblocked
- **phases** — list of phases within this issue. Each phase has:
  - **id** — integer, sequential within the issue (1, 2, 3, …)
  - **status** — one of `not-started`, `in-progress`, `done`, `failed`
  - **after** — list of phase ids that must be `done` before this phase can start; `[]` means no prerequisites

## Body

```markdown
## Invariants

[Constraints that must hold across all phases — e.g. "no phase may break backward
compatibility on the existing API". Omit section if none.]

## Context

[Background the agent needs: libraries, conventions, existing behaviour, references.
Omit section if none.]

---

## Phase 1: [name]

[What this phase delivers]

As a [actor] I want [goal] so that [benefit]

**Scenario: [name]**
Given [context]
When [action]
Then [outcome]

---

## Phase 2: [name]

[What this phase delivers]

As a [actor] I want [goal] so that [benefit]

**Scenario: [name]**
Given [context]
When [action]
Then [outcome]
```

## DAG rules

**Inter-issue (`blocked-by`):**
- Forms a directed acyclic graph — no cycles
- Every `id` in a `blocked-by` list must refer to another issue in the same set
- Issues with no inter-issue dependencies use `blocked-by: []`
- Issues in the same topological layer run in parallel

**Intra-issue (`phases[].after`):**
- Forms a directed acyclic graph within the issue — no cycles
- Every id in an `after` list must refer to another phase in the same issue
- A phase with `after: []` can start as soon as the issue starts
- Multiple phases with satisfied `after` constraints can run in any order relative to each other
- The agent determines available phases by finding phases whose `after` dependencies are all `done`

## TDD mandate

All phase work follows the red-green-refactor cycle:

1. **Red** — write a failing test that captures the acceptance criteria
2. **Green** — write the minimum code to make the test pass
3. **Refactor** — clean up without breaking the test

## Agent contract

When the orchestrator dispatches an agent to work on an issue, the agent receives:
- Path to the PRD file
- Path to the issue file
- A git worktree on the issue branch

The agent must:
- Update issue `status` to `in-progress` as its first action
- For each phase, in an order that satisfies the `after` constraints:
  - Update the phase `status` to `in-progress`
  - Complete the phase work following the TDD mandate
  - Update the phase `status` to `done`
  - Commit and push progress to the issue branch
- Update issue `status` to `done` when all phases are complete
- Update issue `status` to `failed` and populate `failure-reason` if unable to complete
