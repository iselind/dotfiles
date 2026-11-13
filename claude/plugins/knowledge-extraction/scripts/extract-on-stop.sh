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

# Problems must be visible to the user, not only on stderr: collect them and
# print one `systemMessage` (shown by Claude Code) before exiting.
warnings=()
warn() {
    echo "knowledge-extraction: $*" >&2
    warnings+=("$*")
}
emit_warnings() {
    [ "${#warnings[@]}" -gt 0 ] || return 0
    local IFS=';'
    jq -n --arg m "knowledge-extraction: ${warnings[*]}" '{systemMessage: $m}'
}

if ! command -v jq >/dev/null 2>&1; then
    # No jq to build JSON with; this message has no characters needing escapes.
    echo "knowledge-extraction: jq not found" >&2
    printf '{"systemMessage": "knowledge-extraction: DISABLED, jq not found"}\n'
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
    # --git-path output is relative to $root, so build absolute paths instead.
    local marker gitdir
    gitdir="$(git -C "$root" rev-parse --absolute-git-dir)"
    for marker in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD rebase-merge rebase-apply; do
        if [ -e "${gitdir}/${marker}" ]; then
            warn ".task/ NOT committed, a git operation is in progress"
            return 0
        fi
    done

    local branch ticket="" msg
    branch="$(git -C "$root" symbolic-ref --short -q HEAD || true)"
    if [[ "$branch" =~ ^(feature|fix)/(CORE-[0-9]+)- ]]; then
        ticket="${BASH_REMATCH[2]}: "
    fi
    if [ "$branch" = "main" ]; then
        # Don't commit on main
        exit 0
    fi
    if [ -d "$root/.task" ] && [ -n "$(find "$root/.task" -type f -print -quit)" ]; then
        msg="${ticket}record task knowledge"
    else
        msg="${ticket}clear .task"
    fi

    # Stage only .task/ and commit only .task/. --only leaves every other
    # path, staged or not, exactly as it was.
    if ! git -C "$root" add -A -- .task >/dev/null 2>&1; then
        warn ".task/ NOT committed, staging failed"
        return 0
    fi
    if ! git -C "$root" commit --only -q -m "$msg" -- .task >/dev/null 2>&1; then
        warn ".task/ commit FAILED, left staged"
    fi
    return 0
}

if [ "$active" = "true" ]; then
    commit_task_dir
    emit_warnings
    exit 0
fi

if [ ! -r "$PROMPT_FILE" ]; then
    warn "extraction DISABLED, prompt file missing"
    emit_warnings
    exit 0
fi
jq -Rs '{decision: "block", reason: .}' <"$PROMPT_FILE"
exit 0
