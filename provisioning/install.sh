#!/usr/bin/env bash
set -euo pipefail
# Explaining the set flags:
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error and exit immediately.
# -o pipefail: Prevent errors in a pipeline from being masked. If any command in
#              a pipeline fails, that return code will be used as the return code
#              of the whole pipeline.

# Make sure we are in the expected directory
SCRIPT_DIR="$(dirname "$0")"
cd "$SCRIPT_DIR"

echo "==> Provisioning dev environment"

HOME_DIR="$HOME"
BIN="$HOME/bin"
LOCAL_BIN="$HOME/.local/bin"
# Pick a sensible profile file in $HOME for appending environment changes.
if [ -f "$HOME/.bash_profile" ]; then
  PROFILE="$HOME/.bash_profile"
else
  PROFILE="$HOME/.profile"
fi

mkdir -p "$BIN" "$LOCAL_BIN"

# --------------------------------------------------------------
# Package installation functions
# --------------------------------------------------------------
install_from_file() {
  local file="$1"
  shift
  local cmd=("$@")

  if [ ! -f "$file" ]; then
    echo "==> Missing $file (skipping)"
    return
  fi

  echo "==> Installing packages from $file"

  # Read file into the current shell, not a subshell
  while IFS= read -r pkg; do
    # Skip comments and empty lines
    case "$pkg" in
      ""|\#*) continue ;;
    esac

    echo "    -> $pkg"
    "${cmd[@]}" "$pkg"
  done < "$file"
}

# --------------------------------------------------------------
# PATH handling
# --------------------------------------------------------------
ensure_line() {
  # Append an arbitrary line to a profile file if it doesn't already exist.
  local line="$1"
  local file="${2:-$PROFILE}"
  if ! grep -Fq "$line" "$file" 2>/dev/null; then
    printf '%s\n' "$line" >> "$file"
  fi
}

ensure_path() {
  # Ensure a directory is added to PATH in the chosen profile file.
  local p="$1"
  # Use a simple, idempotent export line that will be appended once.
  ensure_line "export PATH=\"$p:\$PATH\"" "$PROFILE"
}

# Ensure user-local bins are present for future shells and update current shell.
ensure_path "$BIN"
ensure_path "$LOCAL_BIN"
export PATH="$BIN:$LOCAL_BIN:$PATH"

# --------------------------------------------------------------
# Apt packages (WSL / Debian-based only)
# --------------------------------------------------------------
if command -v apt-get >/dev/null 2>&1; then
  echo "==> Installing apt packages"
  sudo apt-get update
  install_from_file "packages/apt.txt" sudo apt install -y
fi

# --------------------------------------------------------------
# Python via uv (TOOLS, not venvs)
# --------------------------------------------------------------
if ! command -v uv >/dev/null 2>&1; then
  echo "==> Installing uv"
  curl -Ls https://astral.sh/uv/install.sh | sh
fi

echo "==> Installing Python version"
uv python install 3.12

echo "==> Installing Python tools"
install_from_file "packages/python.txt" uv tool install --upgrade

# --------------------------------------------------------------
# Node via fnm
# --------------------------------------------------------------
if ! command -v fnm >/dev/null 2>&1; then
  echo "==> Installing fnm"
  curl -fsSL https://fnm.vercel.app/install | bash
fi

# Ensure fnm binary directory is in PATH
FNM_DIR="$HOME/.local/share/fnm"
ensure_path "$FNM_DIR"
export PATH="$FNM_DIR:$PATH"

ensure_line 'export PATH="$HOME/.local/share/fnm:$PATH"' "$PROFILE"
ensure_line 'eval "$(fnm env)"' "$PROFILE"
eval "$(fnm env)"

if ! command -v node >/dev/null 2>&1; then
  echo "==> Installing Node LTS"
  fnm install --lts
  fnm use --lts
fi

echo "==> Enabling corepack"
corepack enable || true

echo "==> Configuring npm to use local prefix"
NPM_PREFIX="$HOME/.npm-global"
mkdir -p "$NPM_PREFIX"
npm config set prefix "$NPM_PREFIX"
ensure_path "$NPM_PREFIX/bin"
export PATH="$NPM_PREFIX/bin:$PATH"

echo "==> Installing Node tools"
install_from_file "packages/npm.txt" npm install -g

# --------------------------------------------------------------
# Go
# --------------------------------------------------------------
GO_VERSION=1.22.0
GOROOT="$HOME/go"
GOPATH="$HOME/go-packages"

if [ ! -d "$GOROOT" ]; then
  echo "==> Installing Go $GO_VERSION"
  curl -LO "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
  tar -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
  mv go "$GOROOT"
  rm "go${GO_VERSION}.linux-amd64.tar.gz"
fi

mkdir -p "$GOPATH"

ensure_line "export GOROOT=\"$GOROOT\"" "$PROFILE"
ensure_line "export GOPATH=\"$GOPATH\"" "$PROFILE"
# Ensure Go bins are in PATH for future shells and for this session.
ensure_path "$GOROOT/bin"
ensure_path "$GOPATH/bin"

export GOROOT
export GOPATH
export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"

echo "==> Installing Go tools"
# The tool `golangci-lint` is not recommended to be installed using `go install` anymore
# so we use their official install script
curl -sSfL https://golangci-lint.run/install.sh | sh -s -- -b $(go env GOPATH)/bin v2.7.2

install_from_file "packages/go.txt" go install

# --------------------------------------------------------------
# Finishing summary
# --------------------------------------------------------------
echo
echo "Restart shells to apply PATH changes."
echo "Provisioning complete."
