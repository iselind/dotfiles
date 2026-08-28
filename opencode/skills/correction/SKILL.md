---
name: correction
description: Investigate a correction to the agent's understanding, determine why it was wrong, and identify whether any durable repository knowledge should eventually change.
---

# Process a Correction

A correction means that something you believed about the task or repository
was wrong.

Do not immediately modify permanent documentation.

## 1. Record the correction

Create `.task/` if it does not exist.

Record the correction in:

`.task/corrections.md`

Include:

- What I believed
- What the user corrected
- Why the distinction matters

## 2. Investigate

Determine why the incorrect belief occurred.

Check:

- repository documentation
- relevant code
- tests
- existing decisions
- terminology
- references between documents

Determine which of these applies:

- The information was already documented and I failed to find it.
- The information was documented ambiguously.
- The information was documented incorrectly.
- The information was only implicit in code.
- The information was genuinely absent.
- The correction is specific to this task.
- The correction changes the interpretation of the task.

Do not assume that missing retrieval means missing documentation.

## 3. Record the finding

Update `.task/corrections.md` with:

- Diagnosis
- Evidence
- Relevant existing documentation
- Whether the issue is likely to recur

## 4. Consider the smallest durable improvement

If this appears to be a recurring source of misunderstanding, identify
the smallest appropriate improvement.

Possible outcomes include:

- no change
- improve an existing document
- add a missing explanation
- add a cross-reference
- clarify terminology
- add or update an ADR
- add a test or invariant
- change something else in the repository

Do not make the durable change merely because it is possible.

Do not create a new document when an existing document is appropriate.

Do not add agent-specific instructions merely to compensate for poorly
structured repository knowledge.

## 5. Report

Tell the user:

- what was wrong
- what you found
- why the mistake happened
- whether the repository should eventually change
- what change you recommend, if any

Do not automatically promote the correction into permanent documentation.
