---
name: fix-pr-comments
description: >
  Use when a user mentions PR review comments, feedback, or items to address (we got PR comments, there are review comments to fix, address the feedback, etc.). Fetch open review comments on the current branch's PR and work through them: understand, implement fixes, verify, then commit.
argument-hint: "[pr-number | comment-url]"
user-invocable: true
---

# Fix-PR-comments skill

Current branch: !`git branch --show-current`

## Your job

Work through PR review comments inside the fence (see
`~/.claude/rules/work_inside_the_fence.md`). For each comment: read it,
understand the surrounding code, implement the fix, verify it, commit that fix
in its own commit, then move to the next. Put a comment to the user only when
the fix is a choice the fence does not settle.

---

## Phase 1 — Identify the comments to work through

**Step 1 — Check what's already in context**

If review comments are already present in the conversation (the user pasted
them, or they arrived via a notification), use those directly — skip ahead to
Phase 2. There is no need to fetch from GitHub when the comments are already
here.

**Step 2 — Parse arguments** (only if comments are not already in context)

If `$ARGUMENTS` is a GitHub comment URL (contains `#discussion_r` or
`#issuecomment-`), extract from it:
- The owner/repo slug (from the URL path)
- The PR number
- The comment ID (the numeric suffix after `_r` or `-`)

Treat the skill as targeting that single comment only — go directly to
presenting that one comment.

If `$ARGUMENTS` is a bare PR number, use it and proceed to Step 4.

**Step 3 — Resolve the PR number** (only if not yet known)

Run `gh pr list --head <current-branch> --json number,url` to find the open PR.
If that returns nothing, ask the user:

> "I couldn't find an open PR for this branch. Can you give me the PR number
> or a link to a specific comment?"

Wait for the response before proceeding.

**Step 4 — Fetch the repo slug**

Run:

```
gh repo view --json nameWithOwner --jq '.nameWithOwner'
```

You will use this as `{owner}/{repo}` in subsequent API calls.

**Step 5 — Fetch comments from GitHub**

Fetch inline review comments (top-level only — replies are part of an existing
thread, not new work items):

```
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  --jq '[.[] | select(.in_reply_to_id == null) | {id, path, line, original_line, body, user: .user.login}]'
```

Fetch general (non-inline) PR comments:

```
gh api repos/{owner}/{repo}/issues/{number}/comments \
  --jq '[.[] | {id, body, user: .user.login}]'
```

**Step 6 — Present the comment list**

Show a numbered list of all comments:

```
Open comments (N total):
1. [inline] <author> on <file>:<line> — <first 80 chars of body>
2. [inline] <author> on <file>:<line> — <first 80 chars of body>
3. [general] <author> — <first 80 chars of body>
```

If there are no comments, say so and end here.

Skip any the user has already said to skip, and go on to Phase 2 with the rest.

---

## Phase 2 — Work through the comments

Work through comments in ascending order. Skip any the user asked to skip.

**For each comment:**

1. **Present the comment in full.** Show:
   - Author
   - For inline comments: file path and line number
   - The full comment body
   - For inline comments: the code at that location — read the file and show
     ±5 lines around the referenced line so the context is clear

   If the fix is unambiguous, go straight to step 3.

   If the fix is ambiguous or has real alternatives that the task's fence does
   not settle, set the comment aside with the problem and the options, and put
   it to the user together with the other such comments once the rest are done.

2. **Choose the fix.** For a comment the user decided, start from their
   answer. If multiple approaches exist and the fence settles the choice, take
   that one and say why in the commit message; if the fence does not settle it,
   ask. If proposing an
   alternative API or stdlib function, verify its documented behaviour before
   recommending it — or flag the uncertainty explicitly rather than presenting
   it as a known-good improvement.

3. **Implement the fix.** Read the relevant file(s) first if not already done.
   Make the minimal, focused change that addresses the comment — no unrelated
   cleanup. Before writing code, check the project's CLAUDE.md for invariants
   that apply to the change — in particular constraints on early returns,
   NotFound handling, and logging requirements.

   **If the fix involves documenting an accepted trade-off** (rather than
   addressing the root cause), first verify that no tighter alternative exists
   — check whether the platform supports a more constrained option, whether a
   relevant condition key or list form is available, etc. Do not document a
   limitation as accepted until you have actively ruled out better options. The
   user should not have to ask.

   **If the fix involves writing prose** (comments, explanations), verify every
   factual claim against the code before writing. Do not write from assumption
   — an inaccurate comment is worse than no comment.

4. **Verify the fix** with the tests or checks that apply to the change.

5. **Once verified**, commit the fix in its own commit — do not
   batch multiple comment fixes together. Use a commit message in the style
   already used on this branch (check `git log --oneline -10`). The message
   should indicate what was changed; a reference to the comment is optional
   but useful (e.g. `fix: <what changed>, per review comment`).
6. **Reflect: what type of feedback surfaced in the PR review?** After committing, consider whether that feedback was on style, prose, or context — name any gaps (e.g. wrong scope, missing heuristic, project-specific invariant, prose or comment quality, etc.).

Keep the gaps for Phase 3 and tell the user about them in the final report.

7. **Move to the next.**

**When a comment is not actionable** (question already answered, superseded by
other changes, or applies to code that no longer exists) — say so, describe
why, and ask the user whether to skip it or reply to it. A reply to a reviewer
is outward-facing, so it is the user's call. Ask together with the other
questions, once the other comments are done.

**After the last comment is committed**, re-read every file altered during this
session. Check for artifacts introduced by the fixes — extra blank lines, stale
imports, formatting inconsistencies. Fix any found before moving on.

This artifact check is a hard gate before `git push` — even if the user
combined commit and push authorization in one message (e.g. "commit and push"),
always complete the artifact check between the commit and the push.

**Invoke `/review`** on the branch after the artifact check and before pushing.
PR comment fixes can introduce new issues — the review is the gate that catches
them. Repeat rounds until Phase 6's verdict is "no further rounds needed". Act
on Phase 6's verdict — do not make your own assessment of whether another round
is warranted.

Then ask: "All comments addressed — anything else before I push?" Wait for the
user to confirm before running `git push`. Do not push earlier — premature
pushes trigger CI and may draw reviewer attention before all intended changes
are in place.

---

## Phase 3 — Close review skill gaps

First, check whether a review was actually run on this branch before the PR was created. If not, surface that as a process gap in the invoking workflow rather than proposing heuristic changes — the issue is that the gate was skipped.

Collect all step-6 gap findings from this session — every comment where the
verdict was **"No — gap identified"** (including any discussion that refined
or expanded the gap). If none were identified, skip directly to Phase 4.

For each identified gap, propose a targeted change to
`~/.claude/skills/review/SKILL.md` to address that gap when appropriate. Work through them one at a time:

1. **Propose the change.** Describe what to add or modify in the review skill
   and why it addresses the gap. Wait for the user to confirm or redirect.

2. **Implement it.** Read the review skill file, make the minimal focused edit.

3. **Assess coverage.** Before asking for review: would this change actually
   surface the issue if the reviewer had run the skill on this branch? Be
   honest — if it only partially addresses the gap, say so and refine.

4. **Stop for review.** Wait for the user to approve the change.

5. **Commit.** Resolve `~/.claude/skills` to the dotfiles repo path and commit
   from there. Use a message like `review: catch <gap-description>, per PR review`.

After all gaps are addressed, move directly to Phase 4.

---

## Phase 4 — Retrospective

Next: run retro fix-pr-comments. Do not ask for permission — this
is a natural continuation of the fix.
