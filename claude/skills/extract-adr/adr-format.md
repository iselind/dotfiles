# ADR format

## Template

```markdown
# ADR-NNN: Title in sentence case

## Context

The problem and the forces on it, the constraints that ruled out other approaches, and the alternatives seriously considered. State the problem generically first; a concrete instance follows, marked "e.g.".

## Options considered

One heading per option, named "Option A: …", "Option B: …", so Decision can refer back. Each has a pro/con table or list.

## Decision

What was decided, stated directly, in one or two paragraphs. Exclude migration steps that are explicitly temporary: if the decision will be gone before the ADR is a year old, it does not belong here.

## Rationale

Why the decision is right given the context. Focus on reasoning a future reader cannot reconstruct from the code. Verify each factual claim, such as "already used elsewhere" or "consistent with the pattern of Y", against a specific instance before writing it.
```

## Format rules

- Sentence case in the title: `ADR-003: Foo bar baz`.
- Sub-headings in Rationale, and tables or code blocks, are fine where they clarify.
- Enumerations (failure modes, edge cases) are general statements, not lists, unless complete. Use "e.g." for examples.
- Timeless: describe the decision and its reasons, not the state of the implementation. Avoid "currently", "today", "for now" and "in the current implementation".
- No ticket IDs as context. Describe the problem or constraint directly. A ticket ID may appear only when quoting a filename that contains it.
- No status field: the branch and PR workflow provides status (on a branch means proposed, merged to main means accepted).
- Lifecycle: an ADR that has never been merged to main may be deleted. Once merged, it is never deleted. A superseded ADR gets the bold line `**Superseded by [ADR-NNN](…)**` directly under its title. A discarded ADR gets `**Discarded because …**` directly under its title, giving the reason.

## What makes a good ADR

Test every candidate against: *would a new team member benefit from reading this in a year?* If they would figure it out from the code, skip it. If they would wonder why it was done this way, write it.

Before treating a candidate as undocumented, check durable documentation (integration guides, workflow header comments, other ADRs). A rationale that lives only in a plan is undocumented, because the plan will be deleted. If durable documentation has the reasoning but poorly placed, improve the placement and route that to the review tracking file; do not write an ADR for it.

If the rationale depends on an unresolved question, propose an OPEN instead. If the decision depends on work that may never be built, the ADR is premature: the rationale belongs with that future work.
