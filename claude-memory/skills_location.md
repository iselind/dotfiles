---
name: skills_location
description: Where Claude Code skills are stored and how they are linked
type: reference
---

`~/.claude/skills` is a symlink into a dotfiles repository. Follow the symlink to find the real path on the current machine.

**How to apply:** When creating or editing skills, resolve the symlink first (`realpath ~/.claude/skills`) and work there so changes go through version control.
