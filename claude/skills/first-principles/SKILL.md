---
name: first-principles
description: Use when the user wants to rethink a problem, idea, or design from first principles before committing to it. Covers breaking the problem into parts, questioning hidden assumptions, generating structurally different alternatives, and finding a cheap test that could rule an idea out. Triggers on phrases like "first principles", "question our assumptions", "rethink this from scratch", "what are we taking for granted", "break this problem down", "is there a better way to do this", "test this idea cheaply", or "before we commit to this design". Not for fixing a specific bug, reviewing a diff, or picking between options already on the table.
---

# First principles

Four phases in a fixed order. Each phase consumes the previous phase's output,
so the chain only works if each handoff is preserved:

1. **Decompose** ([decompose.md](decompose.md)): break the problem into parts.
   Output: a hierarchy of the problem, its components, and their elements.
2. **Audit** ([audit.md](audit.md)): question the parts. Output: a numbered list
   of assumptions, each classified and ordered by how load-bearing it is.
3. **Recombine** ([recombine.md](recombine.md)): build solutions only from the
   assumptions that survived the audit. Output: three solutions that differ in
   structure.
4. **Experiment** ([experiment.md](experiment.md)): design the cheapest test for
   each solution. Output: a test, a ruling-out result, and a keep-alive result
   for each.

Read each phase file when you reach that phase, not before.

## Handoffs

- Decompose's output is the input to Audit. Audit treats every block from
  Decompose as a candidate for hidden assumptions.
- Audit's surviving blocks are the only materials Recombine may use. A block the
  audit marked as a fact stays usable. A block marked as a convention or unknown
  is usable only if you label it as an assumption when you use it.
- Recombine's three solutions are the input to Experiment.

## Stop points

- After Decompose, stop and wait for the user. If the stated problem seems to
  hide a deeper question, name that question in one sentence and ask which one
  to decompose. Do not replace the user's problem with the deeper one on your
  own.
- The other phases run straight through, unless the user redirects.

## Gotchas

- The problem comes from the conversation. If the user has not stated a problem
  clearly enough to decompose, ask for it. Do not invent one.
- Phase files are instructions to the model, not text for the user to read as a
  template. Output goes to the user, so write it for them.
