---
name: jira
description: >
  Interact with Jira: query issues, create tickets, update fields, transition
  status, add comments, and more. Use when the user wants to do anything with
  Jira.
user-invocable: true
---

# Jira skill

At the start of every interaction, read `instance.md` (in this skill directory) — it contains the base URL, account ID, project keys, and custom field IDs needed for all API calls.

## Rules

- Always authenticate with `curl --netrc`. Never pass credentials on the command line.
- Never read, cat, or inspect `~/.netrc`.
- Use the Jira REST API v3: `<base-url>/rest/api/3/...` (base URL in `instance.md`).
- Always pass `-H "Content-Type: application/json"` on requests with a body.
- Always pass `-H "Accept: application/json"` on GET requests.
- Parse responses with `jq` for readability.
- When querying for the user's own tickets, always use `assignee = currentUser()` — never hardcode an email address.
- Never show a bare ticket ID (e.g. CORE-631). Always accompany it with the summary and current status — e.g. "CORE-631 — Create a means to spread rules and notification configs *(Complete)*". Fetch summaries and status if not already known.
- When presenting any ticket, also fetch and display any linked FEATURE tickets (key, summary, status). Retrieve them from the `issuelinks` field — `GET <base-url>/rest/api/3/issue/<KEY>?fields=issuelinks` — and filter for links where the other issue's key starts with `FEATURE-`.
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
     "<base-url>/rest/api/3/search/jql" \
     -d '{"jql": "<JQL>", "maxResults": 50, "fields": ["summary", "status", "issuetype", "priority"]}' \
  | jq '.issues[] | {key: .key, summary: .fields.summary, status: .fields.status.name}'
```

### Get a single issue
```bash
curl -s --netrc \
     -H "Accept: application/json" \
     "<base-url>/rest/api/3/issue/<KEY>" \
  | jq '{key: .key, summary: .fields.summary, status: .fields.status.name, assignee: .fields.assignee.displayName}'
```

### Create an issue
```bash
curl -s --netrc \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -X POST \
     "<base-url>/rest/api/3/issue" \
     -d '{
       "fields": {
         "project": {"key": "<PROJECT-KEY>"},
         "summary": "<summary>",
         "issuetype": {"name": "<Story|Epic|...>"},
         "description": {
           "type": "doc", "version": 1,
           "content": [{"type": "paragraph", "content": [{"type": "text", "text": "<body>"}]}]
         }
       }
     }' \
  | jq '{key: .key, errors: .errors}'
```
Verify `.key` is not null before proceeding — a null key means creation silently failed (usually a field validation error with no explicit message).

See `conventions.md` for project-specific required fields (e.g. CORE Platform component, sprint).

After creating, assign the ticket to the user — account ID in `instance.md`:
```bash
curl -s --netrc \
     -H "Content-Type: application/json" \
     -X PUT \
     "<base-url>/rest/api/3/issue/<KEY>/assignee" \
     -d '{"accountId": "<account-id>"}'
```

### Add a comment
```bash
curl -s --netrc \
     -H "Content-Type: application/json" \
     -X POST \
     "<base-url>/rest/api/3/issue/<KEY>/comment" \
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
     "<base-url>/rest/api/3/issue/<KEY>/transitions" \
  | jq '.transitions[] | {id: .id, name: .name}'
```
Then apply the transition:
```bash
curl -s --netrc \
     -H "Content-Type: application/json" \
     -X POST \
     "<base-url>/rest/api/3/issue/<KEY>/transitions" \
     -d '{"transition": {"id": "<TRANSITION_ID>"}}'
```

### Update a field
```bash
curl -s --netrc \
     -H "Content-Type: application/json" \
     -X PUT \
     "<base-url>/rest/api/3/issue/<KEY>" \
     -d '{"fields": {"<field>": "<value>"}}'
```

## Reference files

Load these when the relevant topic comes up — do not load them preemptively.

| File | Load when… |
|------|-----------|
| `sprints.md` | Assigning, querying, or looking up sprints |
| `links.md` | Creating, viewing, or modifying issue links |
| `descriptions.md` | Writing, reviewing, or assessing ticket descriptions or ticket hierarchy |
| `starting-work.md` | User says they are starting work on or will be working on a ticket |
| `conventions.md` | Project-specific creation defaults, GitHub integration, branch derivation, or state transitions |

## Phase 0 — Register on skill stack

Determine the resume from the calling context visible in the conversation — identify where the calling skill continues after this skill completes. Then run:

```bash
skill-stack push jira "<resume>"
```

Set `<resume>` to the single address — a phase name, step label, or other marker — where the calling skill should pick up once this skill completes. Derive this from the calling context visible in the conversation; if context is thin, read ahead in the calling skill's file as a fallback. If invoked standalone with no calling skill, omit the resume argument.

## Your job

Understand what the user wants to do, construct the appropriate API call(s),
run them, and present the results clearly. For destructive or irreversible
operations (closing, deleting, bulk updates), confirm with the user before
executing.

When the job is complete, run:

```bash
skill-stack pop
```
