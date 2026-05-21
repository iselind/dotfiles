# OPEN format

## Template

```markdown
# OPEN-NNN: Title in sentence case

## Question

What is the unresolved question?

## Context

What situation surfaced this question? What work on this branch made it
relevant? Include what is already known or settled so the reader starts with
a clear baseline.

## Options considered

For each option, present a pro/con analysis (table or list). Name options
clearly so they can be referenced in discussion.

## Open questions

What needs to be resolved, learned, or decided before a conclusion can
be reached?
```

Before listing something as open, test it: could it be answered from the context already established in the document or the branch? If yes, move it to Context as a settled fact rather than listing it as open.

## Format rules

- Separate number sequence from ADRs: OPEN-001, OPEN-002, …
- No Decision or Rationale sections — those do not exist yet
- When the question is decided, the OPEN becomes the foundation for an ADR: Context transfers directly, Decision and Rationale are added, OPEN is deleted
- OPEN documents are never referenced by ADRs (the reference would outlive the file)

## What makes a good OPEN

Test every candidate against:

> *Would future work in this area need to rediscover these trade-offs without this document?*

If "the trade-offs are obvious or already captured" — skip it.  
If "someone will need to decide this and the analysis is worth preserving" — write it.

An OPEN is not a failed ADR — it is a different artifact. Something can clearly not merit an ADR (the decision is obvious) but still merit an OPEN (how to implement it has real unresolved trade-offs). Evaluate both independently.

If a question is already tracked in the plan with enough context to drive a decision, a standalone OPEN duplicates that work. Defer it: the work will naturally produce the ADR or OPEN. Only propose an OPEN when the question has no active home — it would otherwise be lost when the plan is deleted.
