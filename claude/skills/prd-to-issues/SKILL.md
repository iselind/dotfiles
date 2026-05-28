---
name: prd-to-issues
description: >
  Read the PRD for the current branch, decompose it into a reviewed set of issue files
  with correct frontmatter and a DAG of dependencies, then commit and push on confirmation.
  Use when you want to turn a PRD into a ready-to-orchestrate set of issues.
user-invocable: true
---

# prd-to-issues skill

Current branch: !`git branch --show-current`

PRD files: !`find docs/prds -name "*.md" 2>/dev/null | sort`

Existing issues: !`ls issues/ISS-*.md 2>/dev/null | sort`

## Authoritative reference

All issue format conventions, DAG rules, and TDD mandate come from `docs/agentic-workflow.md`.
Read that document before generating issues. The issue format and phase behaviour described
there are authoritative; this skill operationalises them.

## Your job

Complete the phases below in order.

---

## Phase 1 — Read the PRD

**Step 1 — Identify the PRD**

Find the PRD for the current branch. Convention: the branch name encodes the PRD topic;
the PRD lives at `docs/prds/<slug>.md`. Read the file list printed above and pick the one
that matches the branch. If multiple candidates exist, ask the user which to use.

**Step 2 — Read docs/agentic-workflow.md**

Read `docs/agentic-workflow.md` in full. Understand:
- The issue file format (YAML frontmatter fields and their meanings)
- The blocked-by structure (list of objects with `id` and `reason` keys)
- The DAG rules (no cycles; blocked-by forms a directed acyclic graph)
- The Agent Contract (what the issue agent receives and must do)

**Step 3 — Read the PRD**

Read the PRD fully. Understand the goal, requirements, constraints, and definition of done.
Note the `slug` field in the PRD frontmatter — every generated issue must have `prd-slug`
set to exactly this value.

---

## Phase 2 — Decompose into issues

**Step 1 — Identify the work units**

Break the PRD into discrete, independently workable units. Each unit becomes one issue.
Aim for issues that can be completed by a single autonomous agent in one session.

Guidelines:
- Each issue should have a single, clear deliverable
- Issues that depend on other issues must declare `blocked-by` relationships
- The full set of issues must cover the PRD's definition of done
- Avoid issues that are too broad to implement in one pass

**Step 2 — Assign IDs**

Assign sequential IDs starting from ISS-001 within this PRD's set. Check existing issues
in `issues/ISS-*.md` to find the highest existing ID and continue from there.

**Step 3 — Build the DAG**

For every issue, decide which other issues it depends on. Record each dependency as:

```yaml
blocked-by:
  - id: ISS-00N
    reason: "why this issue cannot start before ISS-00N is complete"
```

Rules:
- `blocked-by` is a list of objects with `id` and `reason` keys
- An issue with no dependencies uses `blocked-by: []`
- The DAG must have no cycles — verify by tracing all dependency chains
- Every `id` in a `blocked-by` list must refer to another issue in this set

**Step 4 — Draft each issue**

Draft each issue file in the format from `docs/agentic-workflow.md`:

```markdown
---
id: ISS-00N
title: Short descriptive title
status: not-started
prd-slug: <prd-slug>
branch: ""
failure-reason: ""
blocked-by:
  - id: ISS-00M
    reason: "dependency reason"
---

## Story

As a [actor]
I want [goal]
So that [benefit]

## Acceptance Criteria

**Scenario: [name]**
Given [context]
When [action]
Then [outcome]
```

Each issue must have:
- YAML frontmatter with all fields: id, title, status, prd-slug, branch, failure-reason, blocked-by
- `status: not-started`
- `branch: ""`
- `failure-reason: ""`
- A user story (As a / I want / So that)
- At least one Given/When/Then scenario per acceptance criterion
- A `## Context` section if there are implementation notes, constraints, or hints

---

## Phase 3 — Present for review

**Step 1 — Show the complete issue set**

Present all drafted issues in full to the user. For each issue show:
- The complete file content (frontmatter + body)
- Its position in the DAG (what it blocks, what blocks it)

Also show a DAG summary — a list of phases (groups of unblocked issues that can run in parallel),
derived by topological sort. This lets the user verify the dependency structure is correct.

**Step 2 — Wait for confirmation**

Say: "Here are the N issues for PRD '<slug>'. Please review the content and DAG structure.
Reply 'confirm' to write and commit, or tell me what to change."

> **STOP — do not write any files until the user explicitly confirms.**

If the user requests changes, apply them and re-present before asking again.

---

## Phase 4 — Write, commit, and push

**Only proceed here after the user has confirmed in Phase 3.**

**Step 1 — Write the issue files**

Write each issue to `issues/<ID>-<slug>.md` where `<slug>` is the title lower-cased with
spaces replaced by hyphens and non-alphanumeric characters removed
(e.g. `ISS-001-create-prd-skill.md`).

**Step 2 — Verify the files**

After writing, re-read each file and confirm:
- All YAML frontmatter fields are present: id, title, status, prd-slug, branch, failure-reason, blocked-by
- `prd-slug` matches the PRD's `slug` field exactly
- `blocked-by` contains only ids that refer to other issues in this set
- The file is parseable YAML (no syntax errors)

**Step 3 — Commit and push**

Stage the new issue files and commit:

```
git add issues/
git commit -m "Add issues for <prd-slug> PRD"
git push
```

Report the commit hash and confirm the push succeeded.

---

## Phase 5 — Retrospective

Move directly into `/retro prd-to-issues`. Do not ask for permission — this is a
natural continuation of the skill.
