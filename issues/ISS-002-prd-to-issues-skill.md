---
id: ISS-002
title: Create /prd-to-issues skill
status: done
prd-slug: agentic-skills
branch: ""
failure-reason: ""
blocked-by: []
---

## Story

As a developer
I want to invoke `/prd-to-issues` to decompose a PRD into a reviewed set of issue files
So that I can hand off to the orchestrator without manually writing issue frontmatter

## Acceptance Criteria

**Scenario: issues are generated from PRD**
Given a PRD exists at `docs/prds/<slug>.md` on the current branch
When I invoke `/prd-to-issues`
Then the skill produces issue files in `issues/` with correct YAML frontmatter (id, title,
status, prd-slug, branch, failure-reason, blocked-by) and user story + Given/When/Then
acceptance criteria in the body

**Scenario: DAG is declared**
Given the PRD describes work with dependencies between pieces
When issues are generated
Then each issue declares its `blocked-by` list with a reason for each blocker, forming a
valid DAG with no cycles

**Scenario: user confirms before commit**
Given the skill has drafted the issues
When it presents them for review
Then no files are committed until I explicitly confirm

**Scenario: issues pass orchestrator preflight**
Given the issues are committed
When the orchestrator runs preflight checks
Then it finds at least one issue matching the PRD slug and proceeds without error

**Scenario: skill references the workflow**
Given the skill file exists
When its content is read
Then it references the issue file format and DAG conventions from the agentic development
workflow

## Context

The skill file goes in `claude/skills/prd-to-issues.md`.

Issue IDs are assigned sequentially starting from ISS-001 within each PRD's set. The
`prd-slug` field must match the `slug` field in the PRD frontmatter exactly. The
`blocked-by` field is a list of objects with `id` and `reason` keys.
