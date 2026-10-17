---
name: correction
description: >
  Record a correction to the agent's understanding. Append to the task log,
  investigate why the belief was wrong, and document findings to support
  future promotion to permanent documentation.
user-invocable: true
---

# Process a Correction

A correction means something you believed about the task or repository was wrong.

Always append corrections, even if similar corrections have been recorded before.
Repeated corrections signal that the issue deserves promotion to permanent documentation.

Never modify permanent documentation directly during correction recording.

---

## Phase 1 — Record the correction

Create `.task/` if it does not exist.

Append to `.task/corrections.md` (append-only log):

Include:

- **What I believed** — the incorrect understanding
- **What the user corrected or clarified** — the accurate information
- **Why the distinction matters** — the impact or consequence of the mistake

Consider `.task/corrections.md` an audit trail of understanding improvements.

---

## Phase 2 — Investigate

Determine why the incorrect belief occurred.

Check:

- repository documentation
- relevant code
- tests
- existing decisions
- terminology
- references between documents

Determine which of these applies:

- The information was already documented and I failed to find it
- The information was documented ambiguously
- The information was documented incorrectly
- The information was only implicit in code
- The information was genuinely absent
- The correction is specific to this task
- The correction changes the interpretation of the task

Do not assume that missing retrieval means missing documentation.

---

## Phase 3 — Record findings

Update `.task/corrections.md` with:

- **Diagnosis** — why the incorrect belief occurred
- **Evidence** — what you found in the repository
- **Relevant existing documentation** — references to related docs
- **Recurrence likelihood** — whether this issue is likely to recur

---

## Phase 4 — Report

Tell the user what you documented regarding the correction.

Example:

> Recorded correction: I believed X, but you clarified Y. 
> Diagnosis: X was implicit in the code but not documented. 
> Added to `.task/corrections.md` for consolidate-docs to consider during promotion.

This skill can be user-invoked when a correction occurs, or auto-invoked by other
skills (e.g., task-master) if they detect a correction in user feedback. Either
approach is acceptable.

Do not automatically promote the correction into permanent documentation.
That is consolidate-docs' job.
