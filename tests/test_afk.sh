#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AFk_SCRIPT="$REPO_ROOT/shell/bin/afk"

pass=0
fail=0

assert_eq() {
    local desc="$1" expected="$2" actual="$3"
    if [[ "$actual" == "$expected" ]]; then
        echo "PASS: $desc"
        pass=$((pass + 1))
    else
        echo "FAIL: $desc"
        echo "  expected: $expected"
        echo "  actual:   $actual"
        fail=$((fail + 1))
    fi
}

assert_contains() {
    local desc="$1" needle="$2" haystack="$3"
    if echo "$haystack" | grep -qF -- "$needle"; then
        echo "PASS: $desc"
        pass=$((pass + 1))
    else
        echo "FAIL: $desc"
        echo "  expected to contain: $needle"
        echo "  actual: $haystack"
        fail=$((fail + 1))
    fi
}

# --- Test: script exists and is executable ---
if [[ -x "$AFk_SCRIPT" ]]; then
    echo "PASS: afk script exists and is executable"
    pass=$((pass + 1))
else
    echo "FAIL: afk script does not exist or is not executable at $AFk_SCRIPT"
    fail=$((fail + 1))
fi

# --- Test: no arguments exits non-zero and prints usage ---
set +e
output=$("$AFk_SCRIPT" 2>&1)
exit_code=$?
set -e
assert_eq "no-args exits non-zero" "1" "$((exit_code != 0 ? 1 : 0))"
assert_contains "no-args prints usage" "Usage" "$output"

# --- Test: script invokes uv run with correct flags from core-platform dir ---
# Create a fake git repo and fake uv to capture the invocation.
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

fake_bin="$tmp_dir/bin"
mkdir "$fake_bin"

# Fake git: returns a known repo root when asked for rev-parse
cat > "$fake_bin/git" <<'EOF'
#!/usr/bin/env bash
if [[ "$*" == *"rev-parse --show-toplevel"* ]]; then
    echo "/fake/repo"
    exit 0
fi
# Delegate everything else to real git
exec /usr/bin/git "$@"
EOF
chmod +x "$fake_bin/git"

# Fake uv: records its arguments
cat > "$fake_bin/uv" <<'EOF'
#!/usr/bin/env bash
echo "uv $*" > /tmp/afk_test_uv_invocation
EOF
chmod +x "$fake_bin/uv"

export PATH="$fake_bin:$PATH"

set +e
output=$(cd "$tmp_dir" && "$AFk_SCRIPT" /some/prd.md 2>&1)
set -e

if [[ -f /tmp/afk_test_uv_invocation ]]; then
    uv_invocation=$(cat /tmp/afk_test_uv_invocation)
    rm -f /tmp/afk_test_uv_invocation
else
    uv_invocation=""
fi

assert_contains "invokes uv run" "uv run" "$uv_invocation"
assert_contains "passes --with pyyaml" "--with pyyaml" "$uv_invocation"
assert_contains "passes --with pytest" "--with pytest" "$uv_invocation"
assert_contains "invokes orchestrator module" "python -m orchestrator.orchestrate" "$uv_invocation"
assert_contains "passes --prd flag" "--prd /some/prd.md" "$uv_invocation"
assert_contains "passes --repo flag with git root" "--repo /fake/repo" "$uv_invocation"

# --- Test: bashrc adds shell/bin to PATH ---
bashrc="$REPO_ROOT/shell/bashrc"
if grep -qF 'dotfiles/shell/bin' "$bashrc"; then
    echo "PASS: bashrc exports dotfiles/shell/bin in PATH"
    pass=$((pass + 1))
else
    echo "FAIL: bashrc does not export dotfiles/shell/bin in PATH"
    fail=$((fail + 1))
fi

echo ""
echo "Results: $pass passed, $fail failed"
[[ $fail -eq 0 ]]
