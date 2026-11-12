Knowledge extraction (automatic turn-end step). Do this now, briefly, then stop.

Look back over everything that happened since the previous turn ended. Append what you find to the files below, creating the `.task/` directory at the repository root first if it does not exist (`mkdir -p`). Record only; do not edit any other file.

Record each of these in its own file:

1. `.task/corrections.md` — the user corrected you. Write: what you believed, what the user said instead, why the difference matters.
2. `.task/clarifications.md` — the user stated a preference, a rule, a constraint or a fact you did not have, without correcting you.
3. `.task/decisions.md` — a consequential choice was made. Write: what was decided, the alternatives that were rejected, why, and whether it is easy to undo.
4. `.task/discrepancies.md` — what you expected and what you observed did not match. Write: expected vs. observed, what depended on it, and how it was resolved (or the competing explanations if it was not).

Rules:

- Corrections and clarifications matter most. Each one points to a gap somewhere; capture them even when they seem small. Use the user's own words where you can.
- Append only. Add new entries at the end of the file. Never edit, merge, reorder or delete existing entries.
- Do not skip an entry because it resembles one already recorded. Repetition shows importance.
- Do not check the repository docs or decide whether something is already documented. A later step does that.
- Skip trivia: routine tool output, progress narration, and things that only mattered inside this turn.
- Start each entry with a heading line `## <date> — <short title>`.
- If nothing qualifies, write nothing and reply with one line: "Nothing to record."
- Do not commit anything. The commit is done for you.
