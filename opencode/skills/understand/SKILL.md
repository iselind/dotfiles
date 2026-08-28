---
name: understand
description: Investigate a task before implementation. Build a grounded understanding of the goal, relevant repository knowledge, constraints, assumptions, and unresolved questions.
---

# Understand a Task

Your job is to understand the task before attempting to implement it.

Do not start implementing the task unless the user explicitly asks you to
continue after the understanding phase.

## 1. Establish the task

Determine:

- What outcome does the user actually want?
- What is explicitly in scope?
- What is explicitly out of scope?
- What important aspects are unspecified?

Do not invent requirements.

## 2. Explore the repository

Start with the repository's normal documentation and information architecture.

Use the root README and follow relevant documentation references.

Look for:

- relevant domain concepts
- architecture
- existing implementations and patterns
- constraints and invariants
- relevant decisions
- tests that establish expected behaviour

Prefer authoritative documentation and existing code over assumptions.

Do not read the entire repository indiscriminately. Retrieve information
relevant to understanding this task.

## 3. Build a task model

Create `.task/` if it does not exist.

Create or update:

`.task/understanding.md`

Record:

- Goal
- Scope
- Relevant existing concepts
- Relevant documentation
- Relevant existing code
- Constraints
- Assumptions
- Unknowns
- Important alternative interpretations

Distinguish facts from assumptions.

## 4. Resolve what you can

Before asking the user questions, investigate whether the repository can
answer them.

Do not ask questions merely because something is unspecified.

Ask only questions where:

- the answer cannot reasonably be established from the repository, and
- different answers would materially change the implementation or scope.

## 5. Finish

Summarize:

1. Your current understanding.
2. The important repository knowledge you found.
3. Any assumptions you are making.
4. Any questions that genuinely require the user.

Do not implement the task.

If there are no material unresolved questions, explicitly say so.
