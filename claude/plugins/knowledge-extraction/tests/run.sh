#!/usr/bin/env bash
# Plain-bash tests for both hook scripts. Usage: tests/run.sh
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOP="${HERE}/../scripts/extract-on-stop.sh"
GUARD="${HERE}/../scripts/guard-push.sh"

pass=0
fail=0
check() { # check <name> <condition-exit-status>
    if [ "$2" -eq 0 ]; then pass=$((pass + 1)); echo "ok   - $1"; else fail=$((fail + 1)); echo "FAIL - $1"; fi
}

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Stub gh: `gh pr view ...` prints $GH_STATE, or fails when GH_STATE=error.
mkdir -p "$TMP/bin"
cat >"$TMP/bin/gh" <<'EOF'
#!/usr/bin/env bash
[ "${GH_STATE:-}" = "error" ] && exit 1
[ "${GH_STATE:-}" = "none" ] && exit 1
echo "${GH_STATE:-OPEN}"
EOF
chmod +x "$TMP/bin/gh"
export PATH="$TMP/bin:$PATH"

new_repo() { # new_repo <branch>
    local d
    d="$(mktemp -d -p "$TMP")"
    git -C "$d" init -q -b main
    git -C "$d" config user.email t@example.com
    git -C "$d" config user.name t
    echo base >"$d/base.txt"
    git -C "$d" add base.txt
    git -C "$d" commit -q -m base
    git -C "$d" checkout -q -b "$1"
    echo "$d"
}

stop_in() { # stop_in <dir> <active>
    jq -n --arg cwd "$1" --argjson a "$2" '{cwd: $cwd, stop_hook_active: $a}' | "$STOP"
}
guard_cmd() { # guard_cmd <dir> <command>
    jq -n --arg cwd "$1" --arg c "$2" '{cwd: $cwd, tool_name: "Bash", tool_input: {command: $c}}' | "$GUARD"
}
denied() { grep -q '"permissionDecision": "deny"' <<<"$1"; }

# ---- Stop hook -------------------------------------------------------------
repo="$(new_repo feature/CORE-123-thing)"

out="$(stop_in "$repo" false)"
[ "$(jq -r .decision <<<"$out")" = "block" ]; check "stop: first call blocks" $?
grep -q 'corrections.md' <<<"$(jq -r .reason <<<"$out")"; check "stop: reason carries the prompt" $?

out="$(stop_in "$TMP" false)"
[ -z "$out" ]; check "stop: non-repo cwd does nothing" $?

# Second call commits only .task/, leaving other staged and unstaged work alone.
mkdir -p "$repo/.task"
echo entry >"$repo/.task/corrections.md"
echo staged >"$repo/staged.txt"
git -C "$repo" add staged.txt
echo dirty >>"$repo/base.txt"
out="$(stop_in "$repo" true)"
[ -z "$out" ]; check "stop: active call prints nothing" $?
[ "$(git -C "$repo" show --name-only --format=%s HEAD | sed '/^$/d' | tr '\n' ' ')" = "CORE-123: record task knowledge .task/corrections.md " ]
check "stop: commit has ticket prefix and only .task/ files" $?
git -C "$repo" diff --cached --name-only | grep -qx staged.txt; check "stop: unrelated staged file stays staged" $?
git -C "$repo" diff --name-only | grep -qx base.txt; check "stop: unrelated unstaged change stays unstaged" $?

before="$(git -C "$repo" rev-parse HEAD)"
stop_in "$repo" true >/dev/null
[ "$before" = "$(git -C "$repo" rev-parse HEAD)" ]; check "stop: no commit when .task/ unchanged" $?

echo more >>"$repo/.task/corrections.md"
touch "$(git -C "$repo" rev-parse --absolute-git-dir)/MERGE_HEAD"
before="$(git -C "$repo" rev-parse HEAD)"
stop_in "$repo" true >/dev/null 2>&1
[ "$before" = "$(git -C "$repo" rev-parse HEAD)" ]; check "stop: no commit during a merge" $?
rm "$(git -C "$repo" rev-parse --absolute-git-dir)/MERGE_HEAD"

rm -r "$repo/.task"
stop_in "$repo" true >/dev/null
[ "$(git -C "$repo" log -1 --format=%s)" = "CORE-123: clear .task" ]; check "stop: deleting .task/ is committed as a clear" $?

plain="$(new_repo scratch)"
mkdir -p "$plain/.task"
echo x >"$plain/.task/clarifications.md"
stop_in "$plain" true >/dev/null
[ "$(git -C "$plain" log -1 --format=%s)" = "record task knowledge" ]; check "stop: no ticket prefix on other branches" $?

# ---- Guard hook ------------------------------------------------------------
repo="$(new_repo feature/CORE-9-x)"

export GH_STATE=OPEN
out="$(guard_cmd "$repo" "git push")"
[ -z "$out" ]; check "guard: missing .task/ allows push" $?

mkdir -p "$repo/.task"
touch "$repo/.task/.gitkeep"
out="$(guard_cmd "$repo" "git push")"
[ -z "$out" ]; check "guard: .gitkeep only allows push" $?

echo x >"$repo/.task/corrections.md"
out="$(guard_cmd "$repo" "git push origin HEAD")"
denied "$out"; check "guard: push with open PR is denied" $?
grep -q 'consolidate-docs' <<<"$out"; check "guard: deny reason suggests consolidate-docs" $?
grep -q 'corrections.md' <<<"$out"; check "guard: deny reason lists the files" $?

out="$(guard_cmd "$repo" "git -C $repo push")"
denied "$out"; check "guard: git -C push is denied" $?
out="$(guard_cmd "$repo" "make test && git push")"
denied "$out"; check "guard: push after && is denied" $?
out="$(guard_cmd "$repo" "FOO=1 git push")"
denied "$out"; check "guard: env-prefixed push is denied" $?

out="$(guard_cmd "$repo" 'git commit -m "docs: explain git push and gh pr create"')"
[ -z "$out" ]; check "guard: push text inside a commit message is ignored" $?
out="$(guard_cmd "$repo" "git commit -m \"\$(cat <<'EOF'
note about
git push
EOF
)\"")"
[ -z "$out" ]; check "guard: multi-line quoted text is ignored" $?
out="$(guard_cmd "$repo" "git status")"
[ -z "$out" ]; check "guard: unrelated command is allowed" $?

out="$(guard_cmd "$repo" "gh pr create --title x")"
denied "$out"; check "guard: gh pr create is denied" $?

GH_STATE=CLOSED out="$(guard_cmd "$repo" "git push")"
[ -z "$out" ]; check "guard: closed PR allows push" $?
GH_STATE=none out="$(guard_cmd "$repo" "git push")"
[ -z "$out" ]; check "guard: no PR allows push" $?
GH_STATE=error out="$(guard_cmd "$repo" "git push")"
[ -z "$out" ]; check "guard: gh failure allows push" $?

rm "$repo/.task/corrections.md"
out="$(guard_cmd "$repo" "gh pr create")"
[ -z "$out" ]; check "guard: empty .task/ allows gh pr create" $?

echo
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
