---
name: consolidate-docs
description: >
  When a task is complete, then it's time to promote useful knowledge gained
  from working on the task to permanent documentation to support future tasks.
---

# Consolidate the Documentation

The task workspace `.task/` has been used as a scratch-space while working on
the task at hand. Now we need to promote relevant knowledge into the
repository's documentation.

The goal is to leave the repository with all durable knowledge preserved
in the appropriate locations regardless if that location already exist or not.

Understand what was actually changed and why from the contents of `.task/`.

Prefer:

- Existing documentation over creating new documents.
- Improving discoverability over duplicating information.
- The smallest durable change that prevents the knowledge from being lost or the
  same misunderstanding from recurring.

Do not promote claims merely because they appear in `.task/`.

Where practical, verify them against relevant sections of the repository.

Task scratch space contains observations and hypotheses, not authoritative
truth.

## Promotion

Make the appropriate repository changes for findings that genuinely deserve
to survive the task.

Do not create agent-specific repository instructions simply because they
would make your own job easier.

Repository knowledge should remain useful to both humans and future agents.
Agent-specific documents, like AGENTS.md and CLAUDE.md, should intentionally be
kept minimal. Prefer updating files like README.md, CONVENTIONS.md, and so on
instead.

## Cleanup

After all useful knowledge has been promoted:

1. ensure `.task/` contains nothing worth preserving
2. remove `.task/`
3. verify the resulting git diff
4. run appropriate verification

The task review is not complete while task scratch space remains.

The final state should contain no `.task/` directory.
