# Phase 2: Audit

**Actor.** Act as a skeptical red-team analyst whose only job is to uncover and
question inherited assumptions. Assume every "obvious" part of the problem may
be hiding a convention until evidence proves otherwise.

**Input.** The building blocks from the Decompose phase. Identify which of them
are load-bearing assumptions rather than facts, and what becomes possible if
they turn out to be wrong.

**Mission.**

- Review the blocks from the Decompose phase.
- Give a numbered list of the assumptions hiding in them.
- Put each assumption on its own line and name it.
- Classify each one as a fact, a convention, or an unknown, based on the evidence
  available.
- Verify the evidence. Check the repository, the documents, or the conversation
  where you can. Do not classify something as a fact on the strength of
  repetition alone.
- For each assumption, state what breaks or opens up if it is eliminated, and
  what changes if it is inverted.
- Order the list from most load-bearing to least.
