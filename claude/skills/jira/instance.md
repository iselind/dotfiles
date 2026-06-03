# Jira instance — Corero CNS

Base URL: `https://corero-cns.atlassian.net`

## User

Account ID: `712020:e7895849-6170-439d-80a3-e6e26e9e65dd`

Always assign newly created tickets to the user using this account ID via `PUT /rest/api/3/issue/<KEY>/assignee`. A Jira automation exists but does not reliably assign the user's tickets.

## Projects

| Key | Purpose |
|-----|---------|
| `CORE` | Primary engineering work source; scoped to the Platform team |
| `FEATURE` | Roadmap themes; no sprints or date fields |

## Custom fields

| Field | ID | Notes |
|-------|----|-------|
| Product/Component (cascading select) | `customfield_10032` | Required on CORE tickets; set to `{"value": "CORE", "child": {"value": "Platform"}}` |
| Sprint | `customfield_10020` | Pass as a plain integer (sprint ID) — not as an object |

## Board

CORE Platform board ID: `181`

## FEATURE ticket time horizons

Time horizon is encoded as a title prefix — no sprint or date fields are used:

| Prefix | Meaning |
|--------|---------|
| `[Short-term]` | Near future |
| `[Mid-term]` | Medium horizon |
| `[Long-term]` | Far horizon |
| `[Very long-term]` | Aspirational |

When listing FEATURE tickets, group by this prefix.
