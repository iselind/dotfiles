---
name: task-master
description: >
  Investigate a task before implementation. Build a grounded understanding of
  the goal, relevant repository knowledge, constraints, assumptions, and
  unresolved questions.
---

# Manage a Task

Your job is to first understand the task before attempting to resolving it. Once
understood, the task is to be resolved iteratively.

## 1. Establish the task

Determine:

- What outcome does the user actually want?
- What is explicitly in scope?
- What is explicitly out of scope?
- What important aspects are unspecified?

Do not invent requirements.

## 2. Explore the repository

Start with the repository's documentation and information architecture.

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
relevant to understanding this task specifically.

## 3. Build a task model

Create `.task/` if it does not exist. This will be the task's scratch-space
where anything related to the task may be added without restrictions.

Create or update:

`.task/understanding.md`

Record:

- Goal
- Scope
- Relevant existing concepts
- Relevant documentation
- Relevant existing code
- Constraints
- Contradictions
- Invariants
- Assumptions
- Unknowns
- Important alternative interpretations

Distinguish facts from assumptions.

If there are no material unresolved questions, explicitly say so.

## 4. Gap Analysis

We need to collect enough information to establish the gap between where we are
and where we need to be.

Document the perceived gap in `.task/gap.md`

## 5. Resolve what you can

Before asking the user questions, investigate whether the repository can
answer them.

Do not ask questions merely because something is unspecified.

Ask only questions where:

- assumptions still need resolving, or
- the answer cannot reasonably be established from the repository, and
- different answers would materially change the implementation or scope.

## 6. Reduce the gap

> **NOTE:** Do not start reducing the gap unless the user explicitly confirms
> your understandings are in agreement.

Iteratively reduce the gap by establishing a well-fenced and verifiable change
to some vertical in the repository.

All changes are not associated with the same degree of certainty. Stick firmly
to changes that seem obvious or where the necessity and solution of the task is
clear. Avoid changes that cannot be fenced and described with certainty.

Update `.task/` accordingly as changes are completed. Clarity should increase as
more changes are made. Make sure any new uncertainties that come up are resolved
before more changes are performed.

The gap analysis will need to be updated every couple of iterations as the
changes performed shape the changes to come.

## 7. Task Completion

Once the gap has been removed, use the `review` skill to review the changes.
Work with the user to resolve any concerns that come up during the review.

Once review is satisfied use the `consolidate-docs` skill to promote knowledge
gathered during the task to permanent documentation.
