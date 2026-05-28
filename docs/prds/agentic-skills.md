---
slug: agentic-skills
---

# PRD: Agentic Skills

## Goal

Introduce skills and a shell script that operationalize the agentic development workflow
documented in `core-platform/docs/agentic-workflow.md`. The skills cover the human-in-the-loop
stages of the workflow; the shell script covers the autonomous execution stage.

## Motivation

The agentic workflow defines a repeatable process: idea → PRD → issues → autonomous
implementation → review. Without tooling, each stage requires manual steps and relies on
the operator remembering the conventions. The skills make the workflow invocable by name
and self-documenting.

## Requirements

### `/create-prd` skill

- Asks for the idea as its first action
- Conducts a one-question-at-a-time interview (grill-me style) to reach shared understanding
- Explores the codebase when a question can be answered by looking at existing code
- Provides a recommended answer for each question
- Once understanding is reached, creates a branch named after the PRD topic
- Writes the PRD to `docs/prds/<slug>.md` with YAML frontmatter containing a `slug` field
- Commits and pushes the PRD on the new branch

### `/prd-to-issues` skill

- Reads the PRD for the current branch
- Decomposes the PRD into issues following the format in `docs/agentic-workflow.md`:
  - YAML frontmatter: id, title, status, prd-slug, branch, failure-reason, blocked-by
  - Body: user story (As a / I want / So that) and Given/When/Then acceptance criteria
- Constructs the full DAG, declaring blocked-by relationships with reasons
- Presents the complete set of issues for user review before committing
- On confirmation, writes issues to `issues/` and commits and pushes

### `afk` shell script

- Located at `dotfiles/shell/bin/afk`
- Accepts a PRD path as its argument
- Uses `uv run --with pyyaml --with pytest` to invoke the orchestrator without managing
  a venv explicitly
- Invokes `python -m orchestrator.orchestrate --prd <prd-path> --repo <repo-root>`
  where repo-root is derived from the current working directory
- `dotfiles/shell/bin` is added to `$PATH` in `dotfiles/shell/bashrc`

## Constraints

- All skills must reference `docs/agentic-workflow.md` as the authoritative guide for
  conventions (issue format, TDD mandate, phase behaviour, agent contract)
- Issues produced by `/prd-to-issues` must pass the orchestrator's preflight checks
  without modification
- The `afk` script must work from any directory within the target repository

## Out of Scope

- Changes to the orchestrator itself
- QA tooling beyond the existing `/review` skill
- `/review` skill (already exists)

## Definition of Done

- `/create-prd` produces a PRD file with valid frontmatter on a new branch, committed
  and pushed
- `/prd-to-issues` produces issue files that pass orchestrator preflight checks; issues
  are only committed after user confirmation
- `afk <prd-path>` successfully invokes the orchestrator from within any repo
- `afk` is available in `$PATH` in a new shell without manual setup
