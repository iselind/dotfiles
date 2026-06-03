---
name: jira
description: >
  Interact with Jira: query issues, create tickets, update fields, transition
  status, add comments, and more. Use when the user wants to do anything with
  Jira.
user-invocable: true
---

# Jira skill

Jira instance: `https://corero-cns.atlassian.net`

## Rules

- Always authenticate with `curl --netrc`. Never pass credentials on the command line.
- Never read, cat, or inspect `~/.netrc`.
- Use the Jira REST API v3: `https://corero-cns.atlassian.net/rest/api/3/...`
- Always pass `-H "Content-Type: application/json"` on requests with a body.
- Always pass `-H "Accept: application/json"` on GET requests.
- Parse responses with `jq` for readability.
- When querying for the user's own tickets, always use `assignee = currentUser()` — never hardcode an email address.
- Never show a bare ticket ID (e.g. CORE-631). Always accompany it with the summary and current status — e.g. "CORE-631 — Create a means to spread rules and notification configs *(Complete)*". Fetch summaries and status if not already known.
- When presenting any ticket, also fetch and display any linked FEATURE tickets (key, summary, status). Retrieve them from the `issuelinks` field — `GET /rest/api/3/issue/<KEY>?fields=issuelinks` — and filter for links where the other issue's key starts with `FEATURE-`.
- Unless explicitly asked, exclude completed tickets from results by adding `AND statusCategory != Done` to the JQL.
- When a removed or deprecated API endpoint is encountered, update the **Known API changes** section in this skill file before continuing.

## Known API changes

- `GET /rest/api/3/search` is **removed**. Use `POST /rest/api/3/search/jql` with a JSON body instead:
  ```json
  {"jql": "<query>", "maxResults": 50, "fields": ["summary", "status", ...]}
  ```

## Common operations

### Search issues (JQL)
```bash
curl -s --netrc \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -X POST \
     "https://corero-cns.atlassian.net/rest/api/3/search/jql" \
     -d '{"jql": "<JQL>", "maxResults": 50, "fields": ["summary", "status", "issuetype", "priority"]}' \
  | jq '.issues[] | {key: .key, summary: .fields.summary, status: .fields.status.name}'
```

### Get a single issue
```bash
curl -s --netrc \
     -H "Accept: application/json" \
     "https://corero-cns.atlassian.net/rest/api/3/issue/<KEY>" \
  | jq '{key: .key, summary: .fields.summary, status: .fields.status.name, assignee: .fields.assignee.displayName}'
```

### Create an issue

Full creation sequence for a CORE ticket:

**Step 1 — Create**
```bash
curl -s --netrc \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -X POST \
     "https://corero-cns.atlassian.net/rest/api/3/issue" \
     -d '{
       "fields": {
         "project": {"key": "CORE"},
         "summary": "<summary>",
         "issuetype": {"name": "Story"},
         "customfield_10032": {"value": "CORE", "child": {"value": "Platform"}},
         "customfield_10020": <sprint-id-integer>,
         "description": {
           "type": "doc", "version": 1,
           "content": [{"type": "paragraph", "content": [{"type": "text", "text": "<body>"}]}]
         }
       }
     }' \
  | jq '{key: .key, errors: .errors}'
```
Verify `.key` is not null before proceeding — a null key means creation silently failed (usually a field validation error with no explicit message).

**Step 2 — Assign**
```bash
curl -s --netrc \
     -H "Content-Type: application/json" \
     -X PUT \
     "https://corero-cns.atlassian.net/rest/api/3/issue/<KEY>/assignee" \
     -d '{"accountId": "712020:e7895849-6170-439d-80a3-e6e26e9e65dd"}'
```

**Step 3 — Add links**
```bash
curl -s --netrc \
     -H "Content-Type: application/json" \
     -X POST \
     "https://corero-cns.atlassian.net/rest/api/3/issueLink" \
     -d '{"type": {"name": "1 - Delivers"}, "inwardIssue": {"key": "<CORE-KEY>"}, "outwardIssue": {"key": "<FEATURE-KEY>"}}'
```

### Add a comment
```bash
curl -s --netrc \
     -H "Content-Type: application/json" \
     -X POST \
     "https://corero-cns.atlassian.net/rest/api/3/issue/<KEY>/comment" \
     -d '{
       "body": {
         "type": "doc", "version": 1,
         "content": [{"type": "paragraph", "content": [{"type": "text", "text": "<comment>"}]}]
       }
     }'
```

### Transition an issue
First fetch available transitions:
```bash
curl -s --netrc \
     -H "Accept: application/json" \
     "https://corero-cns.atlassian.net/rest/api/3/issue/<KEY>/transitions" \
  | jq '.transitions[] | {id: .id, name: .name}'
```
Then apply the transition:
```bash
curl -s --netrc \
     -H "Content-Type: application/json" \
     -X POST \
     "https://corero-cns.atlassian.net/rest/api/3/issue/<KEY>/transitions" \
     -d '{"transition": {"id": "<TRANSITION_ID>"}}'
```

### Update a field
```bash
curl -s --netrc \
     -H "Content-Type: application/json" \
     -X PUT \
     "https://corero-cns.atlassian.net/rest/api/3/issue/<KEY>" \
     -d '{"fields": {"<field>": "<value>"}}'
```

## Sprints (NOW / NEXT / FUTURE)

The CORE Platform board (id: 181) uses three permanent sprints as a priority signal — not time-boxes:

| Sprint | Meaning                      |
|--------|------------------------------|
| NOW    | Currently being worked on    |
| NEXT   | Up next once NOW items clear |
| FUTURE | Planned but not imminent     |

Sprint field: `customfield_10020`. Board ID: `181`.

Always look up the sprint ID by name rather than hardcoding it — IDs can change if sprints are deleted and recreated:

```bash
curl -s --netrc \
     -H "Accept: application/json" \
     "https://corero-cns.atlassian.net/rest/agile/1.0/board/181/sprint" \
  | jq '[.values[] | select(.name == "NOW") | {id: .id, name: .name, state: .state}]'
```

Sprint field values:
- When **creating**: pass the sprint ID as a plain integer — `"customfield_10020": 4354`
- When **updating**: same — `{"fields": {"customfield_10020": 4354}}`
- `{"id": 4354}` (object form) is rejected with a validation error.

When creating or updating a CORE ticket, ask which sprint it belongs to if not obvious from context.

Always explicitly assign tickets to the user after creation using `PUT /rest/api/3/issue/<KEY>/assignee` with the user's accountId (`712020:e7895849-6170-439d-80a3-e6e26e9e65dd`). A Jira automation exists but does not reliably assign the user's tickets.

## Issue link types

Key link types available in this Jira instance:

| Name | Inward (on target) | Outward (on source) | When to use |
|------|--------------------|---------------------|-------------|
| `1 - Delivers` | is delivered by | delivers | CORE ticket contributes to a FEATURE theme |
| `5 - Blocks` | is blocked by | blocks | Technical dependency — work cannot start until the other is done |
| `Relates to` | relates to | relates to | Related work, no dependency |
| `2 - Implemented` | is implemented by | implements | Implementation of a requirement |

**"1 - Delivers" direction** — empirically verified: to link a CORE ticket as delivering a FEATURE ticket:
```json
{"type": {"name": "1 - Delivers"}, "inwardIssue": {"key": "CORE-NNN"}, "outwardIssue": {"key": "FEATURE-NNN"}}
```
The CORE ticket appears as the inward link when viewing the FEATURE ticket.

## Blocking tickets

Use the "blocks" / "is blocked by" link type for **technical dependencies only** — work that genuinely cannot start until another ticket is complete. Not for planning preference or ordering convenience.

Direction: if B cannot start until A is done, then A **blocks** B (equivalently, B **is blocked by** A).

To add a link:
```bash
curl -s --netrc \
     -H "Content-Type: application/json" \
     -X POST \
     "https://corero-cns.atlassian.net/rest/api/3/issueLink" \
     -d '{
       "type": {"name": "Blocks"},
       "inwardIssue": {"key": "<BLOCKED-TICKET>"},
       "outwardIssue": {"key": "<BLOCKING-TICKET>"}
     }'
```

When surfacing or creating blocking relationships, state the technical reason — not just that one ticket precedes another.

## Description guidelines

These are living guidelines — expect them to be refined over time.

### Philosophy

- **No eternal tickets.** Every ticket needs a visible finish line. The explicit "not doing" list is load-bearing: it's what prevents a ticket from absorbing adjacent work indefinitely.
- **Guide what to work on next.** Descriptions should be actionable, not just documentary.

### Ticket hierarchy

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

**Linking implementation work to FEATURE tickets** — use "1 - Delivers" and apply this rule uniformly:

- Link a **Story** to the FEATURE ticket when the work is contained enough to fit in a Story.
- Link an **Epic** to the FEATURE ticket when the work is large enough to warrant one — the Epic then owns the child Stories.

In multi-project scenarios (e.g. CORE and SWO both contributing to a FEATURE), each project independently links whichever is appropriate for its slice. A FEATURE ticket may end up with a mix of Epics and Stories from different projects — that is expected and correct.

### FEATURE tickets

Two questions drive the description:

1. **What does this theme deliver?** — the goal, concrete enough to know when you've arrived. A well-written goal is already a done condition; no separate "Definition of Done" section needed.
2. **What does this theme not cover?** — the fence. Explicit enough to deflect scope creep and make it clear when a new ticket is needed instead.

Supporting context (why it matters, constraints, phase notes) is welcome but secondary to those two questions.

### CORE Epics

- **Lead** (1-2 sentences): what this body of work delivers
- **When to put a ticket in this epic**: inclusion criteria with concrete examples
- **This epic is for** / **This epic is not for**: explicit scope boundaries
- **Definition of Done**: measurable conditions that close the epic

### CORE Stories

- What needs to be done — concrete and implementable in a branch or two
- Acceptance criteria — what done looks like
- Context/why only if not obvious from the linked epic or FEATURE ticket

## Project conventions

### CORE project
When creating tickets related to the user or their work, always set:
- `project`: `{"key": "CORE"}`
- `customfield_10032` (**Product/Component**, cascading select): `{"value": "CORE", "child": {"value": "Platform"}}`

### FEATURE project
Tickets are roadmap themes with no sprints or date fields. Time horizon is encoded in the ticket title as a prefix: `[Short-term]`, `[Mid-term]`, `[Long-term]`, `[Very long-term]`. When listing FEATURE tickets, group by this prefix.

## GitHub–Jira integration

The Jira instance is linked to GitHub. Branches, commits, and PRs are automatically associated with a ticket when they reference its key. This means:

- **Branch names** referencing `CORE-NNN` appear in the ticket automatically — no need to mention the branch in the ticket description.
- **Commit titles** starting with `CORE-NNN:` (e.g. `CORE-647: add summarize script`) are linked in the ticket. Always prefix commit titles with the ticket key when working on CORE tickets.
- **PRs** are linked once opened.

Never reference branch names in ticket descriptions — the integration handles that. Linked branches, commits, and PRs appear in the **Development** section of the right-hand panel in the Jira ticket UI.

## Deriving the ticket from a branch

Branch names follow `{feature,fix}/CORE-NNN-descriptive-title`, so the Jira ticket can usually be extracted directly from the branch name. When context requires knowing the current ticket and none has been stated, run `git branch --show-current` and parse out the key.

If the branch does not follow the convention:
- Note it, and ask whether a Jira ticket exists for the work.
- If a ticket exists but the branch name doesn't reference it — the branch can stay, just ensure the ticket is kept up to date.
- If no ticket exists — discuss whether one should be created. The primary goal is that all work in progress is reflected in Jira. Creating a ticket is almost always the right call; skipping it should be a deliberate exception.

## State transitions

Jira status should reflect the actual state of work. Apply transitions at these moments:

- **Branch created** → transition ticket to `In Progress`
- **PR opened** → transition ticket to `In Review`
- **PR merged** → do not automatically transition. Ask: "Is CORE-NNN fully done, or is there more work remaining?" If done → transition to `Complete`. If more to do → leave in `In Progress` (or transition back if currently `In Review`).

To apply a transition, first fetch available transitions for the ticket, match by name, then POST the transition ID. See the Transition operation under Common operations.

## Starting work on a ticket

When the user says they'll be working on a ticket (e.g. "we'll be working on CORE-345"):

1. **Fetch the ticket** — read the summary, description, acceptance criteria, and any linked issues.
2. **Present the scope** — summarise what the ticket is asking for in your own words, highlighting anything large, ambiguous, or that could reasonably be split across multiple branches.
3. **Discuss focus** — ask what the intended focus of this branch is. One question, wait for the answer. Use the ticket content to make the question concrete (e.g. "the ticket covers X and Y — is this branch tackling both, or just X?").
4. **Propose a branch name** — once scope is agreed, propose a branch name following the pattern `{feature,fix}/CORE-NNN-descriptive-title` (lowercase, hyphen-separated). Wait for confirmation or a name tweak.
5. **Create the branch** — always base it on `origin/main`, never on a local branch or other remote. Push immediately after creation so the upstream is set to the new remote branch, not `origin/main`:
   ```bash
   git fetch origin
   git checkout -b <branch-name> origin/main
   git push -u origin <branch-name>
   ```
   The `-u` flag sets the upstream to `origin/<branch-name>`. Without the immediate push, the upstream would point to `origin/main` and a bare `git push` could target main — never do that.

6. **Agree on how to proceed** — before writing any code, propose an approach and wait for the user to confirm it:
   - Assess whether the work warrants a planning session: does it involve design choices, touch multiple files or systems, or leave the implementation approach open? Or is it contained and unambiguous enough to implement directly?
   - State your assessment in one sentence and propose either invoking `/create-prd` or proceeding directly.
   - Wait for the user to confirm or redirect. Do not start implementing until they do.

**If the direct path is chosen:** proceed with implementation.

**If the PRD path is chosen**, follow this sequence:

1. **Create the PRD** — invoke `/create-prd`. The PRD is committed and pushed to the branch.

2. **Review the PRD** — invoke `/review` on the PRD. Repeat rounds until the review skill's Phase 6 verdict is "no further rounds needed". Act on Phase 6's verdict — do not make your own assessment of whether another round is warranted.

3. **Comment on the Jira ticket:**
   > PRD approved — `<repo>/<branch>`

4. **Create issues** — invoke `/prd-to-issues`. Issues are committed and pushed to the branch.

5. **Comment on the Jira ticket:**
   > Issues created — `<repo>/<branch>`: ISS-001, ISS-002, … *(list all issue IDs)*

6. **Review each issue** — invoke `/review` on each issue. Repeat rounds per issue until Phase 6 clears it. When an issue clears, comment on the Jira ticket:
   > ISS-NNN cleared for implementation — `<repo>/<branch>`

7. **Implementation begins** — per the agent contract defined in the prd-to-issues skill's `issue-format.md`.

**Resuming after interruption:** read the Jira ticket comments to determine which phase completed last, then check git on `<repo>/<branch>` for current file state. Pick up from the last incomplete phase.

Do not create the branch before scope and name are confirmed.
Do not write code before step 6 is resolved.

## Your job

Understand what the user wants to do, construct the appropriate API call(s),
run them, and present the results clearly. For destructive or irreversible
operations (closing, deleting, bulk updates), confirm with the user before
executing.
