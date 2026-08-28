---
name: review
description: Review a completed task and consolidate useful task knowledge into the repository while discarding temporary working knowledge.
---

# Review a Task

Review both the implementation and the knowledge accumulated while doing
the task.

The task workspace `.task/` is temporary.

The goal is to leave the repository with all durable knowledge preserved
in the appropriate existing locations and no task scratch space remaining.

## 1. Understand the task state

Inspect:

- git status
- git diff
- relevant tests
- `.task/`
- documentation touched by the task
- relevant repository documentation

Understand what was actually changed.

## 2. Review the implementation

Check:

- Does the implementation satisfy the intended task?
- Are important requirements missing?
- Are tests sufficient?
- Did implementation choices contradict existing repository knowledge?
- Did the task introduce a meaningful architectural or domain decision?

Report problems before proposing documentation changes.

## 3. Review task knowledge

Inspect everything in `.task/`.

For each meaningful finding, classify it as one of:

- DISCARD
- ALREADY_CAPTURED
- TASK_SPECIFIC
- UPDATE_EXISTING_DOC
- ADD_DOCUMENTATION
- ADR
- TEST_OR_INVARIANT
- OTHER

Prefer existing documentation over creating new documents.

Prefer improving discoverability over duplicating information.

Prefer the smallest durable change that prevents the knowledge from being
lost or the same misunderstanding from recurring.

## 4. Verify proposed knowledge

Do not promote claims merely because they appear in `.task/`.

Where practical, verify them against:

- code
- tests
- existing documentation
- git history
- decisions

Task scratch space contains observations and hypotheses, not authoritative
truth.

## 5. Promote

Make the appropriate repository changes for findings that genuinely deserve
to survive the task.

Do not create agent-specific repository instructions simply because they
would make your own job easier.

Repository knowledge should remain useful to both humans and future agents.

## 6. Final cleanup

After all useful knowledge has been promoted:

- ensure `.task/` contains nothing worth preserving
- remove `.task/`
- verify the resulting git diff
- run appropriate verification

The task review is not complete while task scratch space remains.

## 7. Report

Summarize:

- implementation review
- documentation/knowledge changes
- findings deliberately discarded
- any unresolved concerns
- final verification

The final state should contain no `.task/` directory.
