#!/usr/bin/env bash
# Stop hook.
#
# First invocation of a turn: block stopping once, with the instructions in
# prompts/extract.md as the reason, so Claude records what happened to .task/.
# Second invocation (stop_hook_active=true, i.e. after that re-prompt turn):
# commit the .task/ changes on their own. Never fails the session.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_FILE="${SCRIPT_DIR}/../prompts/extract.md"

warn() { echo "knowledge-extraction: $*" >&2; }

if ! command -v jq >/dev/null 2>&1; then
    warn "jq not found; skipping"
    exit 0
fi

input="$(cat)"
cwd="$(jq -r '.cwd // empty' <<<"$input")"
active="$(jq -r '.stop_hook_active // false' <<<"$input")"

[ -n "$cwd" ] || exit 0
root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)" || exit 0

commit_task_dir() {
    # Nothing changed under .task/ (new, modified or deleted files): nothing to do.
    [ -n "$(git -C "$root" status --porcelain -- .task 2>/dev/null)" ] || return 0

    # Do not commit in the middle of a merge, rebase or cherry-pick.
    local marker
    for marker in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD rebase-merge rebase-apply; do
        if [ -e "$(git -C "$root" rev-parse --git-path "$marker")" ]; then
            warn "git operation in progress; not committing .task/"
            return 0
        fi
    done

    local branch ticket="" msg
    branch="$(git -C "$root" symbolic-ref --short -q HEAD || true)"
    if [[ "$branch" =~ ^(feature|fix)/(CORE-[0-9]+)- ]]; then
        ticket="${BASH_REMATCH[2]}: "
    fi
    if [ -d "$root/.task" ] && [ -n "$(find "$root/.task" -type f -print -quit)" ]; then
        msg="${ticket}record task knowledge"
    else
        msg="${ticket}clear .task"
    fi

    # Stage only .task/ and commit only .task/. --only leaves every other
    # path, staged or not, exactly as it was.
    if ! git -C "$root" add -A -- .task >/dev/null 2>&1; then
        warn "could not stage .task/"
        return 0
    fi
    if ! git -C "$root" commit --only -q -m "$msg" -- .task >/dev/null 2>&1; then
        warn "could not commit .task/ (left staged for you to handle)"
    fi
    return 0
}

if [ "$active" = "true" ]; then
    commit_task_dir
    exit 0
fi

[ -r "$PROMPT_FILE" ] || { warn "missing $PROMPT_FILE"; exit 0; }
jq -Rs '{decision: "block", reason: .}' <"$PROMPT_FILE"
exit 0
