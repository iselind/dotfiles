---
name: resolve
description: >
  Resolve a task by reducing the gap. Use test-driven development for code changes,
  and documentation-driven approach for non-code changes. Report progress, blockers,
  and remaining work.
---

# Resolve the gap

You receive a `.task/` directory with task understanding and gap analysis.

Your job is to reduce the gap by making changes to the repository.

---

## Determine task type

Review `.task/understanding.md` and `.task/gap.md`.

Determine whether this is:

- **Code-related work** — primarily involves writing or modifying code
- **Non-code work** — primarily involves documentation, configuration, or policy
- **Mixed** — combination of both

---

## Code-related gap reduction

Use test-driven development:

1. **Write a test that fails** — implement a test that exercises the target behavior and currently fails
2. **Make the test pass** — implement code to pass the test
3. **Refactor and cleanup** — improve the implementation while keeping tests passing
4. **Iterate** — repeat until the gap segment is fully reduced

All tests must pass before refactoring begins on the next segment.

---

## Non-code gap reduction

Rely on documentation:

- Repository documentation (CLAUDE.md, README, architecture docs, decision records)
- External authoritative sources referenced in the repository
- Existing patterns and conventions in the codebase

Follow the repository's existing patterns when making changes.

---

## Mixed work

When reducing a gap that involves both code and non-code changes:

- **Code portions:** Use test-driven development — write failing test, implement code to pass, refactor
- **Non-code portions:** Anchor in documentation — follow existing patterns and documented constraints
- **Coordination:** Keep code and docs in sync. Update documentation when code behavior changes; add tests for documented behavior to ensure it remains true

The techniques differ (TDD for code, docs-anchored for non-code) but the work is coordinated
toward a single reduced gap.

---

## Verification

Before reporting completion, verify:

- All tests pass
- All linters pass
- Any verification commands (Makefile, etc.) pass
- Changes align with repository patterns and documented constraints

---

## Reporting progress

When work is complete or blocked, report what task-master needs to decide next:

- **What was achieved** — specific changes made, gap segments closed
- **What remains** — remaining gap segments, unresolved questions
- **What was blocking** — if any uncertainties or design decisions were encountered
- **Updated state** — note any changes to `.task/understanding.md` or `.task/gap.md`
- **Review readiness** — optionally suggest whether a review checkpoint would be valuable now

Be specific and concrete — point to actual files, tests, and changes made.

The format and emphasis should match the specific situation. What is relevant in one report
(e.g., the architectural impact of a design decision) may not be in another (e.g., straightforward
test-driven implementation of a documented feature).
