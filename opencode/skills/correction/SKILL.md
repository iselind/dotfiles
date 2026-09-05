---
name: correction
description: >
  Investigate corrections to the agent's understanding, determine why it was
  wrong, and document findings.
---

# Process a Correction

A correction means that something you believed about the task or repository was
wrong.

Never modify permanent documentation directly.

## 1. Record the correction

Create `.task/` if it does not exist.

Append the correction to `.task/corrections.md` regardless how many times it
might already have been repeated.

Include:

- What I believed
- What the user corrected or clarified
- Why the distinction matters

Consider `.task/corrections.md` an append-only log.

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

## 4. Report

Tell the user what you documented regarding the correction.

Do not automatically promote the correction into permanent documentation.
