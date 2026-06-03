# Gap discovery workflow

For each gap identified in Phase 3, propose a targeted change to
`~/.claude/skills/review/SKILL.md` that would cause the `/review` skill to
catch the class of issue in future. Work through them one at a time:

1. **Propose the change.** Describe what to add or modify in the review skill
   and why it addresses the gap. Wait for the user to confirm or redirect.

2. **Implement it.** Read the review skill file, make the minimal focused edit.

3. **Assess coverage.** Before asking for review: would this change actually
   surface the issue if the reviewer had run the skill on this branch? Be
   honest — if it only partially addresses the gap, say so and refine.

4. **Stop for review.** Wait for the user to approve the change.

5. **Commit.** Resolve `~/.claude/skills` to the dotfiles repo path and commit
   from there. Use a message like `review: catch <gap-description>, per PR review`.
