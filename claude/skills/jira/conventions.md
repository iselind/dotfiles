# Project conventions and integration

## CORE project defaults

When creating CORE tickets, always set:
- `project`: `{"key": "CORE"}`
- `customfield_10032` (Product/Component): `{"value": "CORE", "child": {"value": "Platform"}}`
- `customfield_10020` (Sprint): integer sprint ID (look up by name — see `sprints.md`)

## GitHub–Jira integration

The Jira instance is linked to GitHub. Branches, commits, and PRs are automatically associated with a ticket when they reference its key:

- **Branch names** referencing `CORE-NNN` appear in the ticket automatically — no need to mention the branch in the ticket description.
- **Commit titles** starting with `CORE-NNN:` are linked in the ticket. Always prefix commit titles with the ticket key when working on CORE tickets.
- **PRs** are linked once opened.

Never reference branch names in ticket descriptions — the integration handles that. Linked branches, commits, and PRs appear in the **Development** section of the right-hand panel in the Jira ticket UI.

## Deriving the ticket from a branch

Branch names follow `{feature,fix}/CORE-NNN-descriptive-title`, so the Jira ticket key can be extracted directly from the branch name. When context requires knowing the current ticket and none has been stated, run `git branch --show-current` and parse out the key.

If the branch does not follow the convention:
- Note it, and ask whether a Jira ticket exists for the work.
- If a ticket exists but the branch name doesn't reference it — the branch can stay, just ensure the ticket is kept up to date.
- If no ticket exists — discuss whether one should be created. Creating a ticket is almost always the right call; skipping it should be a deliberate exception.

## State transitions

Jira status should reflect the actual state of work. Apply transitions at these moments:

- **Branch created** → transition ticket to `In Progress`
- **PR opened** → transition ticket to `In Review`
- **PR merged** → do not automatically transition. First assess whether the
  change contains deployable artifacts (GitOps manifests, Terraform config,
  service configuration). If it does, ask: "Has this been deployed all the
  way to production?" — wait for confirmation before transitioning to
  `Complete`. If it has not yet been deployed, leave the ticket in `In Review`
  and revisit when deployment is confirmed.

  If the change is workflow/CI, documentation, or tooling only (nothing
  promoted through tiers), ask: "Is CORE-NNN fully done, or is there more
  work remaining?" If done → transition to `Complete` immediately. If more
  to do → leave in `In Progress`.

To apply a transition, first fetch available transitions for the ticket, match by name, then POST the transition ID. See the Transition operation in `SKILL.md`.
