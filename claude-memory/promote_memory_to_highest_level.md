---
name: Promote memory to the highest applicable level
description: When saving a memory, place it at the most general scope that applies — global unless it is genuinely repo/project-specific
type: feedback
---

When saving a memory, default to `~/.claude/memory/` unless the content is specific to a particular repository or project. Repo-specific memory should only be used for things that do not apply outside that repo.

**Why:** Preferences, working style, and general feedback apply across all projects. Saving them at repo scope means they are silently absent in other projects and have to be re-learned.

**How to apply:** Before writing to a project memory directory, ask: "would this be wrong or irrelevant in a different repo?" If not, write it to `~/.claude/memory/` instead. Periodically review project-specific memories and promote any that have become obviously general.
