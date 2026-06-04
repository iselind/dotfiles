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

All issue format conventions, DAG rules, and TDD mandate are in `issue-format.md`
(companion file in this skill directory). Read it before generating issues.

## Your job

Complete the phases below in order.

---

## Phase 0 — Register on skill stack

Look ahead in the phases below and identify where this skill resumes after invoking a sub-skill. Then run:

```bash
skill-stack push prd-to-issues "<resume>"
```

Set `<resume>` to the single address — a phase name, step label, or other marker — where this skill picks up after the sub-skill returns. If nothing remains after the sub-skill returns, omit the resume argument.

---

## Phase 1 — Read the PRD

**Step 1 — Identify the PRD**

Find the PRD for the current branch. Convention: the branch name encodes the PRD topic;
the PRD lives at `docs/prds/<slug>.md`. Read the file list printed above and pick the one
that matches the branch. If multiple candidates exist, ask the user which to use.

**Step 2 — Read issue-format.md**

Read `issue-format.md` in full. Understand:
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

Break the PRD into issues. Each issue is a phased plan — a self-contained arc of work
an agent completes in one session by working through its phases in order.

Guidelines:
- Each issue covers a meaningful chunk of work, not a single small deliverable
- Work that is naturally sequential within an issue becomes phases within that issue
- Work that is genuinely independent belongs in separate issues so it can run in parallel
- Issues that depend on other issues must declare `blocked-by` relationships
- The full set of issues must cover the PRD's definition of done

**Step 2 — Assign IDs**

Assign sequential IDs starting from ISS-001 within this PRD's set. Check existing issues
in `issues/ISS-*.md` to find the highest existing ID and continue from there.

**Step 3 — Build the DAGs**

**Inter-issue DAG (`blocked-by`):** for every issue, decide which other issues it depends on.

```yaml
blocked-by:
  - id: ISS-00N
    reason: "why this issue cannot start before ISS-00N is complete"
```

- `blocked-by` is a list of objects with `id` and `reason` keys
- An issue with no inter-issue dependencies uses `blocked-by: []`
- No cycles — verify by tracing all dependency chains
- Every `id` must refer to another issue in this set

**Intra-issue phase ordering (`phases[].after`):** for every issue, decide the ordering
of its phases.

```yaml
phases:
  - id: 1
    status: not-started
    after: []
  - id: 2
    status: not-started
    after: [1]
```

- A phase with `after: []` can start as soon as the issue starts
- Multiple phases with satisfied dependencies can run in any order relative to each other
- No cycles within a single issue's phase graph

**Step 4 — Draft each issue**

Draft each issue file following the format in `issue-format.md`. Each issue must have:

- YAML frontmatter with all fields: id, title, status, prd-slug, branch, failure-reason, blocked-by, phases
- `status: not-started`, `branch: ""`, `failure-reason: ""`
- `phases` list with at least one phase; each phase has `id`, `status: not-started`, and `after`
- A `## Phase N: [name]` section in the body for every phase declared in the frontmatter
- Each phase body contains: one-line deliverable, user story (As a / I want / So that), at least one Given/When/Then scenario
- `## Invariants` section if constraints apply across all phases
- `## Context` section if there is background the agent needs

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
- All YAML frontmatter fields are present: id, title, status, prd-slug, branch, failure-reason, blocked-by, phases
- `prd-slug` matches the PRD's `slug` field exactly
- `blocked-by` contains only ids that refer to other issues in this set
- `phases` list is non-empty; every phase has `id`, `status: not-started`, and `after`
- Every id in any `after` list refers to another phase within the same issue
- A `## Phase N` body section exists for every phase declared in the frontmatter
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

---

## Final step — Pop skill stack

```bash
skill-stack pop
```
