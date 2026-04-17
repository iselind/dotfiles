If your own assessment surfaced "could have been better" items, propose concrete
skill changes to address them — do not wait for the user to raise them. Then
ask for the user's additions.

If there is nothing actionable from either your assessment or the user's
response, end here.

Otherwise, work through the skill changes one at a time using the
change → review → commit → next flow. For each change:

1. **Implement the change.** Read this skill's own SKILL.md — the path is
   `~/.claude/skills/<name>/SKILL.md` where `<name>` is the `name:` field in
   this skill's frontmatter. Make the targeted edit; do not rewrite from scratch.

2. When committing, resolve the symlink `~/.claude/skills` to find the dotfiles
   repo and commit from there.

Changes take effect on the next invocation of this skill.
