---
name: skills_location
description: Where Claude Code skills are stored and how they are linked
type: reference
---

`~/.claude/skills` is a symlink into a dotfiles repository. Follow the symlink to find the real path on the current machine.

`~/.claude/skills/` is the invariant path to use when referencing skills — do not use the dotfiles source path directly as it can change.

**How to apply:** When creating or editing skills, resolve the symlink first (`realpath ~/.claude/skills`) and work there so changes go through version control. When skill instructions need to reference their own path, use `/home/patrik/.claude/skills/<skill-name>/SKILL.md`.
