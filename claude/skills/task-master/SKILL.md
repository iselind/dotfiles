---
name: task-master
description: >
  Investigate a task before implementation. Build a grounded understanding of
  the goal, relevant repository knowledge, constraints, assumptions, and
  unresolved questions. Then iteratively reduce the gap to completion.
user-invocable: true
---

# Manage a Task

Your job is to understand the task, then iteratively reduce the gap until done.
The `.task/` directory is your scratch space for all task-related work.

---

## Phase 1 — Establish the task

Determine:

- What outcome does the user actually want?
- What is explicitly in scope?
- What is explicitly out of scope?
- What important aspects are unspecified?

Do not invent requirements. If the task is unclear, ask the user before proceeding.

---

## Phase 2 — Explore the repository

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

Do not read the entire repository indiscriminately. Retrieve information relevant
to understanding this task specifically.

---

## Phase 3 — Build a task model

Create `.task/` if it does not exist.

Create or update:

**`.task/understanding.md`**

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

---

## Phase 4 — Gap analysis

Document the perceived gap in `.task/gap.md`.

Identify:

- What needs to change?
- What is the current state?
- What is the target state?
- What needs to be decided before work can proceed?

---

## Phase 5 — Resolve what you can

Before asking the user questions, investigate whether the repository can answer them.

Do not ask questions merely because something is unspecified.

Ask only questions where:

- assumptions still need resolving, or
- the answer cannot reasonably be established from the repository, and
- different answers would materially change the implementation or scope.

---

## Phase 6 — Confirm understanding with user

Present:

- Goal and scope (from understanding.md)
- The gap (from gap.md)
- Any unresolved questions

Wait for the user to confirm, correct, or clarify.

Process any corrections using the `correction` skill.

Do not proceed to Phase 7 until the user confirms understanding is aligned.

---

## Phase 7 — Iteratively reduce the gap

Your job is to pick well-fenced gap segments and hand them to `resolve`.
Choose segments based on:

- **Least uncertain first** — prefer gap segments with clear requirements and minimal ambiguity
- **Topological ordering** — respect dependencies between segments (A must be done before B)
- **Proper risk ordering** — de-risk by tackling areas with the most assumptions or design decisions early, or tackle quick wins first to build momentum (choose based on task context)

Use the `resolve` skill to reduce each segment. Invoke it in a separate agent context
to preserve this context and allow the agent to have independent access to `.task/`.

**Parallel resolves:** If multiple gap segments are truly independent, ensure current branch work
is committed and pushed, then create separate branches for parallel agents. After each agent
completes, merge the branch back to the main task branch. Consolidate `.task/` changes
(especially `.task/corrections.md`, which is append-only).

**For each resolve cycle:**

1. Select the next well-fenced gap segment based on criteria above
2. Invoke resolve in a separate agent with access to `.task/`
3. Receive report of what was achieved, what was blocking/unclear, and what remains
4. Update `.task/` accordingly
   - Update `.task/gap.md` with progress
   - Record blockers or new uncertainties
   - Review `.task/understanding.md` for accuracy

5. **Handle blockers and unclear situations:** If resolve reports being blocked, questions that need answering, or ambiguities:
   - Investigate whether the repository can answer them (check docs, code, patterns, existing decisions)
   - If you can resolve it by investigation, update `.task/understanding.md` and continue
   - If investigation doesn't resolve it, ask the user to clarify/redirect
   - Process any user corrections using the `correction` skill
   - Resume resolve on the same gap segment once clarity is achieved

6. Review timing: Based on resolve's report, assess whether a review checkpoint makes sense.
   Consider complexity/size of changes, and whether the next resolve cycle(s) will likely be
   small/isolated or large/interconnected. Suggest to the user if a review would be valuable before continuing.

7. Repeat until all gap segments are fully reduced

---

## Phase 8 — Consolidate and promote

When all gap segments are fully reduced and the task is complete:

Invoke the `consolidate-docs` skill in a separate agent to:

- Review all `.task/` contents (understanding, gap, corrections, notes)
- Promote durable knowledge to permanent repository documentation
- Reduce `.task/` to nothing

Wait for consolidate-docs to complete, then return to the user.

Do not run consolidate-docs between resolve cycles — it is only for final cleanup
when the task is fully done.

---

## Phase 9 — Ready for review and PR

The task is now complete and ready for review.

Suggest to the user:

> Task complete. `.task/` has been cleaned up and knowledge promoted to repository docs.
> 
> Next steps: Run `/review` to review changes before creating a PR.

Do not run review automatically — let the user trigger it.
