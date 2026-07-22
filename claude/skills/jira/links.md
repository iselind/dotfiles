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

## Reading issue links from a fetched issue

When you `GET` an issue with `fields=issuelinks`, each entry has a `type` (with both
`inward` and `outward` label text) plus **either** an `outwardIssue` **or** an
`inwardIssue` field — never both. Which one is present tells you which label applies;
it is not determined by which label sounds right or by preferring one label generically:

- If the entry has `outwardIssue`, the current issue is the source of the relationship —
  use `type.outward` (e.g. "blocks").
- If the entry has `inwardIssue`, the current issue is the target — use `type.inward`
  (e.g. "is blocked by").

A `jq` filter that always prefers `type.inward` when present (e.g.
`(.type.inward // .type.outward)`) silently gets this backwards for every link where
`outwardIssue` is the populated field, since `type.inward` still exists as a string even
when it doesn't apply to this entry — `//` only falls back on null/false, not on
"wrong field for this entry." This produced an apparently-circular blocking chain (A
blocked by B, B blocked by A) that was actually a correctly linear chain read backwards.

Correct pattern:
```bash
jq -r '.fields.issuelinks[]? |
  if .outwardIssue then "\(.type.outward): \(.outwardIssue.key) - \(.outwardIssue.fields.summary)"
  elif .inwardIssue then "\(.type.inward): \(.inwardIssue.key) - \(.inwardIssue.fields.summary)"
  else empty end'
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

**This instance has two distinct "blocks"-flavored link types with reversed inward/outward
labels** — confirmed via `GET /rest/api/3/issueLinkType`:

| id | name | inward | outward |
|----|------|--------|---------|
| `10000` | `5 - Blocks` | `is blocked by` | `blocks` |
| `10007` | `Blocked` | `blocks` | `is blocked by` |

Both are live on real tickets, not just theoretically available — CORE-695's child
tickets use a mix of both. This isn't just an API footgun: in the Jira **UI**, a human
picking a relationship by its label text ("blocks" / "is blocked by") has no way to tell
which of the two underlying types gets created — the UI doesn't surface `10000` vs.
`10007` as a distinguishable choice, it only shows label text that both types share. So
existing links on this instance are not reliably one type or the other, regardless of
who created them or how carefully.

**Consequence:** never infer a link's direction from its label text combined with an
assumption about which type produced it. Always read direction from that specific link
entry's own `type.inward`/`type.outward` together with whether `outwardIssue` or
`inwardIssue` is populated (see "Reading issue links from a fetched issue" above) — that
approach is correct regardless of which of the two types is in play, since it never
assumes one over the other.

When *creating* a new link via the API (where explicit type selection is possible, unlike
the UI), use `5 - Blocks` and put the **blocker as inward, blocked as outward**:

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
