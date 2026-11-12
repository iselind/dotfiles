#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash).
#
# While the repository's .task/ directory holds anything other than dotfiles:
#   - deny `gh pr create`
#   - deny `git push` when the current branch has an OPEN pull request
# Everything else is allowed. Every failure mode (no jq, no perl, no gh, no
# network, not a repo) allows the command.
#
# Known limits: a `cd dir && git push` is judged by the session cwd, and a
# push of another branch via an explicit refspec is judged by the current one.
set -uo pipefail

warn() { echo "knowledge-extraction: $*" >&2; }

for tool in jq perl; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        warn "$tool not found; push guard disabled"
        exit 0
    fi
done

input="$(cat)"
command_line="$(jq -r '.tool_input.command // empty' <<<"$input")"
cwd="$(jq -r '.cwd // empty' <<<"$input")"
[ -n "$command_line" ] || exit 0

# Blank out quoted strings (commit messages, echo arguments) so that text
# inside them never counts as a command. Then split into simple commands.
stripped="$(perl -0777 -pe 's/("(?:[^"\\]|\\.)*"|\x27[^\x27]*\x27)/""/gs' <<<"$command_line")"
segments="$(sed -E 's/(&&|\|\||[;|&])/\n/g' <<<"$stripped")"

push_re='^[[:space:]]*(([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*)git([[:space:]]+(-C[[:space:]]+[^[:space:]]+|-c[[:space:]]+[^[:space:]]+|--[^[:space:]]+))*[[:space:]]+push([[:space:]]|$)'
pr_re='^[[:space:]]*(([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*)gh[[:space:]]+pr[[:space:]]+create([[:space:]]|$)'
dir_re='[[:space:]]-C[[:space:]]+([^[:space:]]+)'

kind=""
target_dir="$cwd"
while IFS= read -r seg; do
    if [[ "$seg" =~ $pr_re ]]; then
        kind="pr-create"
        break
    elif [[ "$seg" =~ $push_re ]]; then
        kind="push"
        if [[ "$seg" =~ $dir_re ]]; then
            target_dir="${BASH_REMATCH[1]}"
            [[ "$target_dir" = /* ]] || target_dir="${cwd}/${target_dir}"
        fi
        break
    fi
done <<<"$segments"

[ -n "$kind" ] || exit 0
[ -n "$target_dir" ] || exit 0

root="$(git -C "$target_dir" rev-parse --show-toplevel 2>/dev/null)" || exit 0
[ -d "$root/.task" ] || exit 0

# Non-empty means at least one entry whose name does not start with a dot.
# Run find from inside .task/ so the ".task" component itself is not mistaken
# for a hidden entry.
files="$(cd "$root/.task" && find . -mindepth 1 -type f -not -path '*/.*' 2>/dev/null | sed 's|^\./|.task/|' | sort)"
[ -n "$files" ] || exit 0

if [ "$kind" = "push" ]; then
    command -v gh >/dev/null 2>&1 || exit 0
    state="$(cd "$root" && gh pr view --json state -q .state 2>/dev/null)" || exit 0
    [ "$state" = "OPEN" ] || exit 0
    what="push to a branch that has an open pull request"
else
    what="create a pull request"
fi

# shellcheck disable=SC2001  # per-line prefix; parameter expansion can't anchor each line
reason="Blocked: cannot ${what} while .task/ still holds recorded knowledge:
$(sed 's/^/  - /' <<<"$files")
Run the consolidate-docs skill to promote what is worth keeping into the repository docs and empty .task/, then retry."

jq -n --arg reason "$reason" '{
    hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: $reason
    }
}'
exit 0
