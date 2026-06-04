# Issue links

## Link types

| Name | Inward (on target) | Outward (on source) | When to use |
|------|--------------------|---------------------|-------------|
| `1 - Delivers` | is delivered by | delivers | CORE ticket contributes to a FEATURE theme |
| `5 - Blocks` | is blocked by | blocks | Technical dependency — work cannot start until the other is done |
| `Relates to` | relates to | relates to | Related work, no dependency |
| `2 - Implemented` | is implemented by | implements | Implementation of a requirement |

## Adding a link

```bash
curl -s --netrc \
     -H "Content-Type: application/json" \
     -X POST \
     "<base-url>/rest/api/3/issueLink" \
     -d '{"type": {"name": "<link-type>"}, "inwardIssue": {"key": "<KEY>"}, "outwardIssue": {"key": "<KEY>"}}'
```

## "1 - Delivers" direction

Empirically verified — to link a CORE ticket as delivering a FEATURE ticket:
```json
{"type": {"name": "1 - Delivers"}, "inwardIssue": {"key": "CORE-NNN"}, "outwardIssue": {"key": "FEATURE-NNN"}}
```
The CORE ticket appears as the inward link when viewing the FEATURE ticket.

## Blocking tickets

Use "blocks" / "is blocked by" for **technical dependencies only** — work that genuinely cannot start until another ticket is complete. Not for planning preference or ordering convenience.

Direction: if B cannot start until A is done, then A **blocks** B (B **is blocked by** A).

There are two blocking link types with mirrored inward/outward labels — use `5 - Blocks` and put the **blocker as inward, blocked as outward**:

```bash
curl -s --netrc \
     -H "Content-Type: application/json" \
     -X POST \
     "<base-url>/rest/api/3/issueLink" \
     -d '{
       "type": {"name": "5 - Blocks"},
       "inwardIssue": {"key": "<BLOCKING-TICKET>"},
       "outwardIssue": {"key": "<BLOCKED-TICKET>"}
     }'
```

**How Jira renders links:** the inward issue sees the outward text ("blocks"), the outward issue sees the inward text ("is blocked by"). So the blocked ticket (outward) correctly shows "is blocked by [blocker]".

When surfacing or creating blocking relationships, state the technical reason — not just that one ticket precedes another.
