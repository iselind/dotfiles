---
id: ISS-001
title: Create /create-prd skill
status: not-started
prd-slug: agentic-skills
branch: ""
failure-reason: ""
blocked-by: []
---

## Story

As a developer
I want to invoke `/create-prd` to start an interview-driven PRD creation process
So that I can go from an idea to a committed PRD without remembering the conventions manually

## Acceptance Criteria

**Scenario: skill is invoked**
Given I invoke `/create-prd` in a repository
When the skill starts
Then it asks for my idea before doing anything else

**Scenario: interview is conducted**
Given I have provided my idea
When the skill conducts the interview
Then it asks one question at a time, provides a recommended answer for each, and explores
the codebase rather than asking when a question can be answered by reading existing code

**Scenario: PRD is produced**
Given the interview has reached shared understanding
When the skill writes the PRD
Then the PRD exists at `docs/prds/<slug>.md` with valid YAML frontmatter containing a
`slug` field, on a new branch named after the PRD topic, committed and pushed

**Scenario: skill references the workflow**
Given the skill file exists
When its content is read
Then it references the agentic development workflow conventions — specifically the PRD
format, branch naming, and human checkpoint expectations

## Context

The skill file goes in `claude/skills/create-prd.md` (picked up via the `~/.claude/skills`
symlink). Skill files are markdown with YAML frontmatter (`name` and `description` fields)
followed by the instruction body.

The interview follows the grill-me pattern:
- Interview relentlessly about every aspect of the idea until shared understanding is reached
- Walk down each branch of the decision tree, resolving dependencies between decisions
  one at a time
- Ask one question at a time — never bundle multiple questions
- For each question, provide a recommended answer so the user can accept or redirect
  rather than starting from scratch
- If a question can be answered by exploring the codebase, explore it instead of asking
