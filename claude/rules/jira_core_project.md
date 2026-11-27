---
name: jira-core-project
description: Context about the CORE Jira project — primary source of work, shared across company teams
metadata:
  type: reference
---

The CORE project in Jira (corero-cns.atlassian.net) is the primary source of work. It is shared across many company teams. The main teams active in CORE are:
- Patrik Iselind's team (currently a team of one — all filtering should use `currentUser()`)
- The CORElet team
- The chief architect, who has a significant number of tickets

Branches for CORE work follow the pattern `{feature,fix}/CORE-NNN-descriptive-title`. A single ticket may span multiple branches — not all work is done in one go.

Commit titles should be prefixed with the ticket key: `CORE-NNN: description`. This links the commit in Jira via the GitHub–Jira integration. Branch names and PRs are also linked automatically — never mention branch names in ticket descriptions.

**Why:** Helps avoid querying CORE as if it were a single-team project — always scope to currentUser() or a specific team rather than listing everything.

When creating tickets related to the user or their work, always set:
- `project`: CORE
- `customfield_10032` (Product/Component, cascading select): `{"value": "CORE", "child": {"value": "Platform"}}`

CORE has no `Task` issue type. The valid types are Epic, Story, Bug, Sub-task, Docs Story and Vulnerability; use Story for ordinary work and cleanup tickets. A Bug also requires Severity (`customfield_10033`), Where Found (`customfield_10039`) and Affects versions, and the field-options call returns no options for the first two, so their values cannot be looked up. When those values are unknown, create a Story. User: "just do a story if it's tricky with a bug".

**How to apply:** When listing CORE tickets, default to `assignee = currentUser()` unless asked for a broader view. When creating tickets, pre-fill project=CORE and component=Platform unless told otherwise. When planning a branch, check whether the ticket scope fits in one branch or needs scoping down first.
