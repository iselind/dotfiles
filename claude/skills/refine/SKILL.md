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

**Always analyse the latest `origin/main`, never HEAD.** The checkout's HEAD can be on any branch or commit, and harness hooks commit to it during the session, so it moves. For every repo you examine, run `git fetch origin` first, then read files at `origin/main` (`git show origin/main:<path>`, `git grep <pattern> origin/main -- <paths>`, `git log origin/main -- <paths>`), not from the working tree. Record `git rev-parse origin/main` as that repo's SHA. If the repo's default branch is not `main`, use its default branch.

## 3. Check staleness of any prior analysis

Look for an earlier gap-analysis comment on the ticket. It records, per repo, the commit SHA examined and the paths looked at.

- The analysis is **stale** if, for any recorded path, `git log <sha>..origin/main -- <paths>` in that repo is non-empty (after `git fetch origin`).
- It is **fresh** otherwise. Report that, and stop for this ticket unless the user asked for a re-analysis.

Do not use the Jira `updated` field. Our own writes change it.

## 4. Refinement steps

Work through these in order (an obsolete or done verdict takes the shorter path after 4.1). Jira descriptions and comments are Markdown, not wiki markup, and ADR-style names go in backticks; read the Jira quirks memory before the first write. Before each Jira write (edit, comment, link, epic change), show the proposed change and wait for approval. Ask one question at a time.

**4.1 Gap analysis.** Compare what the ticket asks for with what the repos contain. Give one verdict: done, partly done, obsolete, or open. Back it with evidence: file paths, commit SHAs, and the relevant lines. Derive the paths you examine from the analysis itself, not from ticket text. Tickets often name files that have since moved or been removed.

**If the verdict is obsolete (or done), skip 4.2 and 4.3.** No work remains, so there is nothing to reshape, no shape to write, and no epic to place the ticket under. Instead:

1. Look for leftovers the ticket was about: search every repo you examined (at `origin/main`) and Jira for references to the branch, files, ADRs or plans the ticket names, and check for local branches and worktrees. Report what you found, including "nothing".
2. Name any question from the ticket that nothing else answers. It is not part of closing; offer it to the user as a separate ticket.
3. Post the analysis comment (step 5), including the tip SHA of any branch to be deleted so it stays recoverable.
4. Ask before deleting a remote branch, and delete it only on approval.
5. Ask before closing the ticket. Closing needs a required Development Resolution field (`customfield_10047`). `jira_get_field_options` returns no values for it, so read the values used on other closed CORE tickets (e.g. `Do Not Fix` for superseded work, not `Done/Fixed`) and propose one. The user may close the ticket themselves.

Then continue with step 6 and step 7.

**4.2 Reshape.** Update the summary and description so they describe what remains, not what was originally asked. If the ticket covers several goals, consider splitting it, or cloning it and linking the clones, but only when the parts can land independently. Otherwise keep it as one ticket.

The description must also hold the ticket's shape: the why, the what, the fence and the sources. The shape, how to verify it and how to fix it are defined in `~/.claude/skills/shape-ticket/SKILL.md`; follow its steps 2 and 3 for the reshaped ticket, using the gap analysis from 4.1 as input. Later work, including the `review` skill, tests the branch against the why. A ticket already in that shape is left as it is.

**4.3 Place.** Choose an existing epic that fits, or propose a new one. Every work ticket ends up under an epic, so "unassigned" is a `parent is EMPTY` query. Epics may be small. A one-story epic is fine.

When proposing a new epic:

- Frame it as an outcome, not a task list. State the goal, why it matters, and a "done when" condition.
- Define scope as a condition that can be checked, plus the command that finds its members. Do not write an open-ended "audit for X" line without saying what to look for. If you cannot name the signal, the scope is not ready.
- Do not assume the current repo is the whole picture. Other repos may deploy to the same cluster. When the scope spans repos or concerns deployed state, detect members against the live cluster (for example a `kubectl ... | jq` query the user runs) and put the query, example output and how to read it in the epic description.
- Name only the members you have verified. Say which facts are still unchecked.

When creating a ticket or epic, set `project` to CORE and `customfield_10032` to `{"value": "CORE", "child": {"value": "Platform"}}`.

## 5. Record the analysis

Post the gap analysis as a comment on the ticket. Include:

- The verdict and evidence.
- For each repo examined: `<repo> @ <origin/main commit SHA>` (the fetched `origin/main`, not HEAD).
- The paths examined.

Do not put branch names in ticket descriptions or comments. The Jira–GitHub integration links them automatically.

## 6. Consolidate `.task/` into the ticket

While you refine, harness hooks append to `.task/` at the repository root of the checkout you work in (`corrections.md`, `clarifications.md`, `decisions.md`, `discrepancies.md`). Do this once the analysis comment is posted and the user has no more changes to the ticket:

1. Read every file in `.task/`.
2. Distil what a later reader of the ticket needs: constraints and facts the user stated, decisions with the rejected alternatives and why, and discrepancies between ticket and reality that affect the work (resolved or not). Drop what only mattered during this session: tool quirks, progress narration, and anything already in the description or the analysis comment. Group by theme, not by source file.
3. Show the proposed comment and wait for approval, as for every Jira write. If nothing is worth keeping, say so and skip the comment.
4. Post it as a separate comment, titled as a refinement note, after the analysis comment. Do not mention `.task/` in it.
5. Delete `.task/` and commit the deletion, and nothing else. Do this even when you skipped the comment in step 3, and do not push.
   - Run `git ls-files .task`. If it is empty, nothing is tracked: say so, `rm -r .task` if the directory exists, and skip the commit.
   - Otherwise delete and commit in one command, so no turn boundary falls between them (a hook can recreate `.task/` files in between, and the commit would then carry the new entries instead of the deletion): `git rm -r -q .task && git commit -m "CORE-NNN: Clean out .task/" -- .task`, using the refined ticket's key and the commit attribution line the session specifies. `git rm` leaves untracked files in place, so run `rm -r .task` afterwards if the directory remains.
   - Check `git show --stat HEAD`: it must show only deletions under `.task/`. If it shows anything else, report that and stop. Hook commits ("record task knowledge") may already have removed some files, so the file count can differ from what you expected; that is fine.

Hooks may append more entries after your last turn. That is expected; they are left uncommitted and the next run consolidates them.

## 7. Stop

Report what changed on the ticket and where it now sits. Do not start the next ticket. The user runs this skill again for that.
