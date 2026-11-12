# knowledge-extraction

A Claude Code plugin that captures what a session teaches, so
[`consolidate-docs`](../../skills/consolidate-docs/SKILL.md) can promote it into
the repository's docs. It replaces the `correction`, `choose` and `reconcile`
skills, which never got invoked (see
[triggering.md](../../skills/triggering.md)).

## What it does

**At every turn end** (Stop hook), Claude is re-prompted once to look back over
the turn and append to the repository's `.task/` directory (created if missing):

| File | Content |
|---|---|
| `corrections.md` | You corrected Claude: what it believed, what you said, why it matters |
| `clarifications.md` | A preference, rule or fact you stated that Claude lacked |
| `decisions.md` | A consequential choice: alternatives, why, reversibility |
| `discrepancies.md` | Expected vs. observed, what depended on it, the resolution |

Entries are raw signals. Recording is append-only, repeats are kept on purpose
(repetition signals importance), and nothing is checked against the repo docs;
that is `consolidate-docs`' job.

After that turn, the hook commits **only `.task/`**, in its own commit
(`CORE-NNN: record task knowledge` on `{feature,fix}/CORE-NNN-*` branches).
Other staged or unstaged changes are left untouched. This is a deliberate
exception to "commit only at stable points" in
`claude/rules/commit_at_stable_points.md`. The commit is skipped during a merge,
rebase or cherry-pick, and a failed commit only prints a warning.

**Before a push or PR** (PreToolUse hook on Bash), while `.task/` holds any
non-dotfile, the hook denies:

- `gh pr create`
- `git push` when the current branch has an `OPEN` pull request (`gh pr view`)

The denial lists the files and suggests running `consolidate-docs`. Deleting
`.task/` (what `consolidate-docs` does last) lifts the block.

`.task/` is version-controlled and must never be git-ignored.

## Limits

- Costs one extra model turn after every turn. Claude Code stops consecutive
  stop-hook continuations after 8.
- The first push of a branch with no PR is allowed; enforcement begins at
  `gh pr create`.
- The guard fails open: no `jq`, `perl`, `gh`, or a failing `gh pr view`
  (auth, network), means the command is allowed. These cases are not silent:
  the hook prints a `systemMessage`, which Claude Code shows as a notice
  (`PreToolUse:Bash says: knowledge-extraction: push NOT checked ...`). "No pull
  request for this branch" and "not a git repo" are normal and stay silent. The
  Stop hook warns the same way when it is disabled (no `jq`, missing prompt) or
  when the `.task/` commit is skipped or fails (`.task/` stays staged).
- `cd dir && git push` is judged by the session's working directory. A push of
  another branch through an explicit refspec is judged by the current branch.
- `git add -A` by hand can still put `.task/` into a work commit; the push guard
  is the backstop.
- Whether Haiku follows the extraction prompt reliably has not been measured.

## Layout

```
.claude-plugin/plugin.json
hooks/hooks.json
scripts/extract-on-stop.sh   # Stop: re-prompt, then commit .task/
scripts/guard-push.sh        # PreToolUse: deny gh pr create / push to open PR
prompts/extract.md           # the instructions Claude receives at turn end
tests/run.sh                 # plain-bash tests, stub gh, temp git repos
```

Run the tests with `tests/run.sh`. Requires `jq`, `perl` and `git`.

## Install

`shell/bashrc` (sourced by `setup.sh`) defines a `claude` function that adds
`--plugin-dir` for every directory in `claude/plugins/` containing
`.claude-plugin/plugin.json`, so every CLI session started from that shell
loads the plugin (listed as `knowledge-extraction@inline`). IDE and desktop
sessions do not go through the function and do not load it.

A symlink into `~/.claude/plugins/` does **not** work: that directory is Claude
Code's own state, plugins placed there are not discovered, and linking the
directory itself would clobber that state. Check with `claude plugin list`.
