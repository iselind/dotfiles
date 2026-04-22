---
name: change_review_commit
description: Write files immediately but commit as a distinct step after review; when iterating through a list, one change at a time with confirmation before moving on
type: feedback
---

Write and edit files immediately — the user reviews via the IDE diff. Do not batch writing and committing into a single step.

**When iterating through a sequence of discrete changes** (review findings, PR comments, skill improvements, etc.):

1. Implement one change at a time
2. Stop — briefly note what changed and wait
3. If the user requests changes, apply them and repeat step 2
4. Once confirmed, commit
5. Ask "Ready for the next?" and wait before proceeding

**Why:** Edits are easy to undo; commits are not. The user reviews changes in the IDE diff, not in chat — committing before they've seen the diff bypasses that check. Moving to the next item before confirmation loses the natural review cadence.

**How to apply:** Any time work breaks into discrete changes that each warrant their own commit. For content already discussed and agreed in conversation, propose the commit rather than waiting to be asked — but still as a distinct step from writing.
