---
name: change_review_commit
description: Workflow pattern for iterating on changes — implement one at a time, stop for review before committing, wait before moving to the next
type: feedback
---

When working through a sequence of changes (review findings, PR comments, skill improvements, or any similar list):

1. Implement one change at a time
2. Stop for review — end with "Ready for review — let me know when you're ready to commit." and wait
3. If the user requests changes, apply them and repeat step 2
4. Once confirmed, commit
5. Ask "Ready for the next?" and wait before proceeding

**Why:** The user reviews changes in the IDE diff, not in the conversation. Committing before the user has seen the diff bypasses that check. Moving to the next item before confirmation loses the natural review cadence.

**How to apply:** Any time work is broken into discrete changes that will each be committed individually. Applies within skills, in retrospectives, and in ad-hoc multi-step edits.
