# Description guidelines

## Philosophy

- **No eternal tickets.** Every ticket needs a visible finish line. The explicit "not doing" list is load-bearing: it's what prevents a ticket from absorbing adjacent work indefinitely.
- **Guide what to work on next.** Descriptions should be actionable, not just documentary.

## Ticket hierarchy

```
FEATURE (roadmap theme)
  └── CORE Epic  (large body of work, decomposed from FEATURE or standalone)
        └── CORE Story
  └── CORE Story (can link directly to FEATURE — epics are not mandatory)

Standalone (no FEATURE parent — legitimate, not a gap):
  CORE Epic → CORE Story
  CORE Story
```

Epics are not containers — they are stories that got too large to deliver in one branch. Split them into child stories.

## Linking implementation work to FEATURE tickets

Use "1 - Delivers" (see `links.md`) and apply this rule uniformly:

- Link a **Story** to the FEATURE ticket when the work is contained enough to fit in a Story.
- Link an **Epic** to the FEATURE ticket when the work is large enough to warrant one — the Epic then owns the child Stories.

In multi-project scenarios (e.g. CORE and SWO both contributing to a FEATURE), each project independently links whichever is appropriate for its slice. A FEATURE ticket may end up with a mix of Epics and Stories from different projects — that is expected and correct.

## FEATURE tickets

Two questions drive the description:

1. **What does this theme deliver?** — the goal, concrete enough to know when you've arrived. A well-written goal is already a done condition; no separate "Definition of Done" needed.
2. **What does this theme not cover?** — the fence. Explicit enough to deflect scope creep and make it clear when a new ticket is needed instead.

Supporting context (why it matters, constraints, phase notes) is welcome but secondary.

## CORE Epics

- **Lead** (1-2 sentences): what this body of work delivers
- **When to put a ticket in this epic**: inclusion criteria with concrete examples
- **This epic is for** / **This epic is not for**: explicit scope boundaries
- **Definition of Done**: measurable conditions that close the epic

## CORE Stories

- What needs to be done — concrete and implementable in a branch or two
- Acceptance criteria — what done looks like
- Context/why only if not obvious from the linked epic or FEATURE ticket
