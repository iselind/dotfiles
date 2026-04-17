---
name: retro
description: >
  Run a retrospective on a skill session that just completed. Assesses what went
  well and what could be improved, then applies skill changes one at a time.
  Invoked automatically at the end of other skills; can also be run directly.
argument-hint: "<skill-name>"
user-invocable: true
---

# Retro skill

## Your job

Run a retrospective on the skill session that just completed. Assess the work
honestly, surface improvements, and apply them to the skill file.

---

## Phase 1 — Identify the skill

If `$ARGUMENTS` is provided, use it as the skill name. Otherwise ask:

> "Which skill should I run the retrospective on?"

The skill file is at `~/.claude/skills/<name>/SKILL.md`.

---

## Phase 2 — Self-assessment

Give your own honest assessment of the session that just ran:

- What went well — steps that ran smoothly, findings correct on first read,
  output that needed no iteration
- What could have been better — be honest and open-ended: anything the user
  had to correct or re-explain, steps that took more iterations than expected,
  anything that should have been noticed independently

If your own assessment surfaced "could have been better" items, propose
concrete skill changes to address them — do not wait for the user to raise
them. Then ask:

> "Anything to add, or anything I missed?"

If there is nothing actionable from either your assessment or the user's
response, end here.

---

## Phase 3 — Apply changes

Work through the skill changes one at a time using the
change → review → commit → next flow:

1. **Implement the change.** Read the skill file at
   `~/.claude/skills/<name>/SKILL.md`, then make the targeted edit. Do not
   rewrite the file from scratch.

2. When committing, resolve the symlink `~/.claude/skills` to find the dotfiles
   repo and commit from there.

Changes take effect on the next invocation of the skill.
