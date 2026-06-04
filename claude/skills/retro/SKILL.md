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

## Phase 0 — Register on skill stack

Determine the resume from the calling context visible in the conversation — identify where the calling skill continues after this skill completes. Then run:

```bash
skill-stack push retro "<resume>"
```

Set `<resume>` to the single address — a phase name, step label, or other marker — where the calling skill should pick up once this skill completes. Derive this from the calling context visible in the conversation; if context is thin, read ahead in the calling skill's file as a fallback. If invoked standalone with no calling skill, omit the resume argument.

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

For each "could have been better" item, diagnose the root cause before
proposing a fix:

- **Guidance was missing** → add it
- **Guidance was present but not followed** → the skill file has a
  presentation problem for its intended audience (an LLM); refactor it
  so the relevant instructions are salient — well-placed, unambiguous, and
  free of structural noise that competes for attention.
- **Guidance was present and followed but produced the wrong outcome** →
  the guidance itself needs revision

If your own assessment surfaced "could have been better" items, propose
concrete skill changes to address them — do not wait for the user to raise
them. Then ask:

> "Anything to add, or anything I missed?"

If there is nothing actionable from either your assessment or the user's
response, end here.

---

## Phase 3 — Apply changes

Work through the skill changes one at a time using the
change → assess → review → commit → next flow:

1. **Implement the change.** Read the skill file at
   `~/.claude/skills/<name>/SKILL.md`, then make the targeted edit. Do not
   rewrite the file from scratch.

2. **Assess coverage.** Before asking the user to review, assess how likely the
   implemented change is to prevent the original issue from recurring. Be honest:
   if the change addresses the surface symptom but leaves the underlying cause
   unaddressed, say so and propose a refinement. Only move to review once the
   change is well-aimed at the root cause.

3. When committing, resolve the symlink `~/.claude/skills` to find the dotfiles
   repo and commit from there.

After the last change is committed, end the retro. Do not ask for further
additions — that was already covered in Phase 2.

---

## Final step — Pop skill stack

```bash
skill-stack pop
```
