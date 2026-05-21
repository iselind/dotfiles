---
name: fix-pr-comments
description: >
  Fetch open review comments on the current branch's PR and work through them
  one at a time: understand the comment, implement the fix, review, then commit.
  Use when the user has PR review comments to address.
argument-hint: "[pr-number | comment-url]"
user-invocable: true
---

# Fix-PR-comments skill

Current branch: !`git branch --show-current`

## Your job

Work through PR review comments one at a time. For each comment: read it,
understand the surrounding code, implement the fix, stop for the user to review,
commit that fix, then move to the next. Do not batch fixes or commit before the
user has reviewed.

---

## Phase 1 — Identify the comments to work through

**Step 1 — Check what's already in context**

If review comments are already present in the conversation (the user pasted
them, or they arrived via a notification), use those directly — skip the
remaining steps and go straight to presenting the list. There is no need to
fetch from GitHub when the comments are already here.

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

Ask: "Any of these to skip? Otherwise I'll start with comment 1." — then wait
for the user's response before proceeding to Phase 2.

---

## Phase 2 — Work through comments one at a time

Work through comments in ascending order, one at a time. Skip any the user
asked to skip in Phase 1.

**For each comment:**

1. **Present the comment in full.** Show:
   - Author
   - For inline comments: file path and line number
   - The full comment body
   - For inline comments: the code at that location — read the file and show
     ±5 lines around the referenced line so the context is clear

   Do not propose a fix yet — let the user engage with the comment first. Wait
   for the user to respond.

2. **Once the user has engaged**, propose a concrete fix. If multiple
   approaches exist, present them briefly with pros and cons and ask the user to confirm which one
   to implement before proceeding.

3. **Implement the fix.** Read the relevant file(s) first if not already done.
   Make the minimal, focused change that addresses the comment — no unrelated
   cleanup.

4. **Stop for review.** End with: "Ready for review — let me know when you're
   ready to commit." Then wait.

   If the user requests changes, apply them and repeat this step.

5. **Once the user approves**, commit the fix in its own commit — do not
   batch multiple comment fixes together. Use a commit message in the style
   already used on this branch (check `git log --oneline -10`). The message
   should indicate what was changed; a reference to the comment is optional
   but useful (e.g. `fix: <what changed>, per review comment`).

6. **Optionally reply on GitHub.** Ask: "Reply to the comment on GitHub?
   (Enter to skip.)"

   If the user provides reply text, post it:
   - For inline comments:
     `gh api repos/{owner}/{repo}/pulls/{number}/comments -X POST -f body="<reply>" -f in_reply_to_id=<comment-id>`
   - For general comments:
     `gh api repos/{owner}/{repo}/issues/{number}/comments -X POST -f body="<reply>"`

   If the user presses Enter or says nothing actionable, skip without posting.

7. **Move to the next.** Ask: "Done — ready for comment N+1?" — then wait for
   confirmation.

**Do not move to the next comment until the user confirms the current one.**

**When a comment is not actionable** (question already answered, superseded by
other changes, or applies to code that no longer exists) — say so, describe
why, and ask the user whether to skip it or reply to it before moving on.

---

## Phase 3 — Retrospective

Move directly into `/retro fix-pr-comments`. Do not ask for permission — this
is a natural continuation of the fix.
