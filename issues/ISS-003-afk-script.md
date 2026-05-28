---
id: ISS-003
title: Create afk script and PATH setup
status: in-progress
prd-slug: agentic-skills
branch: ""
failure-reason: ""
blocked-by: []
---

## Story

As a developer
I want to run `afk <prd-path>` from within a repository to invoke the orchestrator
So that I can start autonomous implementation without managing a Python environment manually

## Acceptance Criteria

**Scenario: script is available in PATH**
Given a new shell is opened
When I type `afk`
Then the command is found without any manual PATH configuration

**Scenario: script fails gracefully with no arguments**
Given the script is invoked with no arguments
When it runs
Then it exits non-zero and prints a usage message

**Scenario: script invokes the orchestrator**
Given a valid PRD path is provided
When `afk <prd-path>` is run from within a git repository
Then it invokes `python -m orchestrator.orchestrate --prd <prd-path> --repo <repo-root>`
using `uv run --with pyyaml --with pytest`

**Scenario: repo root is derived automatically**
Given the script is run from any directory within a git repository
When it resolves the repo root
Then it passes the correct `--repo` value to the orchestrator regardless of the working
directory

## Context

The script goes in `shell/bin/afk` and must be executable.

`shell/bin/` does not yet exist and must be created. `dotfiles/shell/bashrc` must be
updated to add `$HOME/code/dotfiles/shell/bin` to `$PATH` so the script is available in
new shells without further setup.

The orchestrator lives in `core-platform` at
`/home/patrik/code/core-platform/orchestrator/`. The `uv run` invocation must be run
from the `core-platform` directory so the `orchestrator` package is importable, while
`--repo` points at the target repository.
