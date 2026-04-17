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

PR for this branch: !`gh pr list --head $(git branch --show-current) --json number,title,url --jq '.[0] // "No PR found"' 2>/dev/null || echo "gh not available or no PR found"`

## Your job

Fetch open review comments on this branch's PR, then work through them one at a
time: read the comment, understand the surrounding code, implement the fix,
review with the user, then commit.

---

## Phase 1 — Find the PR and identify the scope

**Step 1 — Parse arguments**

If `$ARGUMENTS` is a GitHub comment URL (contains `#discussion_r` or
`#issuecomment-`), extract from it:
- The owner/repo slug (from the URL path)
- The PR number
- The comment ID (the numeric suffix after `_r` or `-`)

Treat the skill as targeting that single comment only — skip Steps 3–4 and
go directly to Phase 2 with just that one comment.

If `$ARGUMENTS` is a bare PR number, use it. Otherwise use the PR number from
the context above.

If no PR could be determined, tell the user and ask:

> "Should I work through all open comments on this PR, or do you have a link
> to a specific comment?"

Wait for the response before proceeding.

**Step 2 — Fetch the repo slug** (if not already extracted from a URL)

Run:

```
gh repo view --json nameWithOwner --jq '.nameWithOwner'
```

You will use this as `{owner}/{repo}` in subsequent API calls.

**Step 3 — Fetch inline review comments**

Run:

```
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  --jq '[.[] | select(.in_reply_to_id == null) | {id, path, line, original_line, body, user: .user.login}]'
```

This returns top-level inline comments (file/line annotations). Replies are
excluded because they are part of an existing discussion thread, not new work
items.

**Step 4 — Fetch general (non-inline) PR comments**

Run:

```
gh api repos/{owner}/{repo}/issues/{number}/comments \
  --jq '[.[] | {id, body, user: .user.login}]'
```

**Step 5 — Present the comment list**

Show a numbered list combining both sets:

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

5. **Once the user approves**, commit the fix. Use a commit message in the
   style already used on this branch (check `git log --oneline -10`). The
   message should indicate what was changed; a reference to the comment is
   optional but useful (e.g. `fix: <what changed>, per review comment`).

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
