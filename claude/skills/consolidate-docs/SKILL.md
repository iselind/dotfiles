---
name: consolidate-docs
description: >
  Promote knowledge from the task scratch space (.task/) to permanent repository
  documentation. Determine what should survive the task, where it belongs, and
  what can be discarded. Reduce .task/ to nothing.
---

# Consolidate the Documentation

The `.task/` directory has been your scratch space during task work.
Now we promote durable knowledge into the repository's documentation.

The goal: leave the repository with all knowledge worth preserving,
in the appropriate locations, then delete `.task/`.

---

## Phase 1 — Understand what changed and why

Read the contents of `.task/`:

- `.task/understanding.md` — what we learned about the task
- `.task/gap.md` — what we needed to change
- `.task/corrections.md` — corrections and investigations (if present)
- Any other notes accumulated during the task

Understand:

- What was actually changed and why
- What assumptions were corrected or clarified
- What design decisions emerged
- What patterns or constraints became clear

---

## Phase 2 — Determine what deserves promotion

Not everything in `.task/` should become permanent documentation.

Apply these criteria:

**Promote if:**

- It documents a constraint or invariant that applies beyond this task
- It clarifies terminology or concepts used in the codebase
- It records a design decision that affects future work
- It corrects a misunderstanding that could recur
- It documents a pattern now used in the codebase
- It explains why something is the way it is

**Do not promote if:**

- It is specific to this task and will not apply again
- It documents implementation details that are obvious from the code
- It duplicates information already in the repository
- It is speculation or tentative analysis

Verify candidates against the codebase. Do not promote claims that cannot be verified.
Task scratch space contains observations and hypotheses, not authoritative truth.

---

## Phase 3 — Choose appropriate locations

Promote to the repository with these preferences:

**Prefer existing documentation** over creating new files.

**Prefer descriptive filenames** over generic ones.

**Avoid CLAUDE.md by default** — keep it tight and minimal.
Only add if it is guidance for agents (not humans) working on the codebase.

**Consider these locations first:**

- `README.md` — high-level concepts, architecture overview
- `CONVENTIONS.md` — patterns and best practices
- Architecture docs or decision records — design decisions (ADRs)
- Domain-specific docs — concepts, terminology, constraints
- Code comments — where the behavior is implemented
- Configuration docs — if the change affects how the project is configured

**Create new files only if:**

- The content doesn't fit anywhere existing
- A new topic deserves its own focused document
- The document will be actively referenced and maintained

When creating new files, use descriptive names:
`PATTERNS.md`, `DOMAIN-CONCEPTS.md`, `DEPLOYMENT-CONSTRAINTS.md`, etc.

---

## Phase 4 — Verify promoted content

For each piece of documentation you promote:

- Verify it against relevant sections of the codebase
- Ensure it does not contradict existing documentation
- Ensure it is accurate and not based on assumptions
- Check that it is discoverable from relevant context

If promoting a design decision or pattern, verify it is actually used in the code.

**Verification approach:**

The specifics of how to verify depend on the claim and codebase structure.
You might search for implementations, check test coverage, review related ADRs,
or spawn an Explore agent to locate relevant code patterns. The goal is to avoid
promoting claims that cannot be grounded in the actual repository state.

Do not promote something if you cannot verify it or cannot reasonably explain how
a future reader would verify it.

---

## Phase 5 — Make repository changes

Make appropriate changes to promote knowledge:

**Small, focused changes** — prefer small improvements to existing documents over large additions.

**Improve discoverability** — if the knowledge is already present but hard to find, reorganize or link to it rather than duplicate.

**Repository knowledge is for all** — documents should be useful to humans and future agents.
Agent-specific instructions belong in CLAUDE.md (kept minimal).
General patterns, constraints, and decisions belong in accessible documentation.

Commit changes with clear messages explaining what knowledge is being promoted and why.

---

## Phase 6 — Cleanup

After all durable knowledge has been promoted:

1. **Ensure `.task/` contains nothing worth preserving**
   - Verify all important findings have been promoted
   - Check that `.task/` has no decision records, patterns, or constraints that should survive

2. **Delete `.task/`**
   - Remove the entire directory
   - Verify git diff shows only `.task/` deletion plus promoted documentation

3. **Verify promotion succeeded**
   - Run relevant linting and verification
   - Spot-check that promoted content is accurate and discoverable
   - Ensure no promoted content contradicts existing documentation

The task is now complete. The repository has gained the knowledge learned during the task,
and the scratch space has been cleaned up.
