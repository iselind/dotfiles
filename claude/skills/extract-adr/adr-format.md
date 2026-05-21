# ADR format

## Template

```markdown
# ADR-NNN: Title in sentence case

## Context

What situation or forces led to this decision? Include the problem being
addressed, constraints that ruled out other approaches, and alternatives
seriously considered.

Keep factual and specific. When describing failure modes or edge cases, prefer
a general statement over an enumerated list — enumeration implies completeness,
which is rarely true.

When the decision captures a general pattern motivated by a concrete first
instance, state the problem at the generic level first, then introduce the
concrete instance marked with "e.g." or "in the current implementation".
Concrete-first framing makes a generic ADR read as system-specific, which
ages badly as the pattern recurs elsewhere.

## Options considered

For each option, present a pro/con analysis (table or list). Name options
clearly ("Option A: …", "Option B: …") so the Decision section can refer back.

## Decision

What was decided. One or two paragraphs, stated directly. Sub-headings or a
list if the decision has multiple parts.

Do not include transitional or migration choices that are explicitly temporary.
If it will be gone before the ADR is a year old, it does not belong here.

## Rationale

Why this decision is correct given the context above. Focus on reasoning a
future reader could not reconstruct from the code alone.

Verify every factual claim before writing. "Already used elsewhere for X" and
"consistent with the established pattern of Y" are common failure modes — only
include if a specific, verifiable instance exists in the codebase.
```

## Format rules

- Sentence case: `ADR-003: Foo bar baz`, not `ADR-003: Foo Bar Baz`
- No status field — the branch/PR workflow provides status
- Sub-headings within Rationale are fine when reasoning has distinct parts
- Code blocks and tables are fine where they clarify
- Do not reference specific tickets (Jira, GitHub issues, etc.) by ID — describe the problem or constraint directly. Ticket IDs may appear in filenames (e.g. a hook script named after its ticket) when quoting that filename, but never as a reference for context.

## What makes a good ADR

Test every candidate against:

> *Would a new team member benefit from reading this in a year?*

If "they'd figure it out from the code" — skip it.  
If "they'd wonder why we did it this way" — write it.

Before treating a candidate as undocumented, verify the reasoning is not already in durable documentation (integration guides, workflow head comments, other ADRs). A candidate whose rationale lives only in the plan is genuinely undocumented — the plan will be deleted. But if the same reasoning exists in durable form elsewhere, an ADR adds nothing.

When reasoning exists in durable documentation but is poorly placed (buried in a long header comment), improve the placement rather than writing an ADR. Route the placement improvement to the review tracking file; do not count it as an ADR gap.

Before proposing an ADR, check whether the rationale depends on an unresolved question. If clearly yes, propose an OPEN instead. If uncertain, surface it to the user before classifying.

Also check whether the decision is contingent on work that may never be built. If adopting the decision requires first building something optional or speculative, the ADR is premature — the rationale belongs alongside that future work.
