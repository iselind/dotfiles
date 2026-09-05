---
name: resolve
description: Resolve a task
---

# Resolve the task

There are three different kinds of tasks: code, not code, and a mix of the two.

Code-related changes are solved by test-driven development. Write a test that
fails, make the test pass, and then refactor and cleanup the code. Iterate
until done with the code-related parts of the task. All tests need to pass
before a refactoring and cleanup may start.

Non-code-related changes cannot use test-driven development. Instead we have to
lean a lot more on the documentation. That means both the documentation in the
repository and elsewhere. The documentation in the repository should keep a list
of authoritative/preferred documentation sources for various topics relevant to
the code base.

## Check your work

Check the project for linting and verification commands. They might be in
Makefile files or similar.

All tests and linters need to pass before the task can be considered done.
