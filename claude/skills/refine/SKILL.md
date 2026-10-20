---
name: refine
description: >
  Use when an open CORE ticket assigned to the user, with no parent epic, needs its ask checked against what the repos already contain, reshaped to what remains, and placed under an epic.
argument-hint: "[CORE-NNN] [repo-path]"
user-invocable: true
---

# Refine skill

Refine one CORE ticket per run: gap analysis, reshape, place. Overlap checks and consolidation between tickets are not part of this skill; they belong to epic-level work.

Jira is the state store. The analysis lives in a comment on the ticket, so the next run can check whether it is still current.

---

## 1. Pick the ticket

If an argument names a ticket key, use that ticket.

Otherwise run this query through the Jira tools and take the first result that is not an epic and has no analysis comment, or whose analysis is stale (see step 3):

```
project = CORE AND assignee = currentUser() AND statusCategory != Done AND parent is EMPTY ORDER BY created ASC
```

Epics in the result belong to epic-level work. Skip them.

Read the ticket in full, including its comments, before anything else. Tickets were often written before current workflows existed, so the summary alone is not enough.

## 2. Locate the repos

Use the repo path from the argument if given. Otherwise search under `~/code/` for the repo or repos the ticket is about. `core-platform` is the usual one. Use the ticket text and the Jira development info to pick others. Name the repos you chose and why, and ask if the choice is unclear.

## 3. Check staleness of any prior analysis

Look for an earlier gap-analysis comment on the ticket. It records, per repo, the commit SHA examined and the paths looked at.

- The analysis is **stale** if, for any recorded path, `git log <sha>..HEAD -- <paths>` in that repo is non-empty.
- It is **fresh** otherwise. Report that, and stop for this ticket unless the user asked for a re-analysis.

Do not use the Jira `updated` field. Our own writes change it.

## 4. Refinement steps

Work through these in order. Before each Jira write (edit, comment, link, epic change), show the proposed change and wait for approval. Ask one question at a time.

**4.1 Gap analysis.** Compare what the ticket asks for with what the repos contain. Give one verdict: done, partly done, obsolete, or open. Back it with evidence: file paths, commit SHAs, and the relevant lines. Derive the paths you examine from the analysis itself, not from ticket text. Tickets often name files that have since moved or been removed.

**4.2 Reshape.** Update the summary and description so they describe what remains, not what was originally asked. If the ticket covers several goals, consider splitting it, or cloning it and linking the clones, but only when the parts can land independently. Otherwise keep it as one ticket.

**4.3 Place.** Choose an existing epic that fits, or propose a new one. Every work ticket ends up under an epic, so "unassigned" is a `parent is EMPTY` query. Epics may be small. A one-story epic is fine.

When creating a ticket or epic, set `project` to CORE and `customfield_10032` to `{"value": "CORE", "child": {"value": "Platform"}}`.

## 5. Record the analysis

Post the gap analysis as a comment on the ticket. Include:

- The verdict and evidence.
- For each repo examined: `<repo> @ <commit SHA>`.
- The paths examined.

Do not put branch names in ticket descriptions or comments. The Jira–GitHub integration links them automatically.

## 6. Stop

Report what changed on the ticket and where it now sits. Do not start the next ticket. The user runs this skill again for that.
