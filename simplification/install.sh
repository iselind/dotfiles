#!/usr/bin/env bash
set -euo pipefail

echo "==> Provisioning dev environment"

HOME_DIR="$HOME"
BIN="$HOME/bin"
LOCAL_BIN="$HOME/.local/bin"
PROFILE="$HOME/.bashrc"

mkdir -p "$BIN" "$LOCAL_BIN"

# --------------------------------------------------------------
# PATH handling (POSIX only; Windows PATH is printed later)
# --------------------------------------------------------------
ensure_path() {
  local p="$1"
  if ! grep -q "$p" "$PROFILE" 2>/dev/null; then
    echo "export PATH=\"$p:\$PATH\"" >> "$PROFILE"
  fi
}

ensure_path "$BIN"
ensure_path "$LOCAL_BIN"

export PATH="$BIN:$LOCAL_BIN:$PATH"

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
uv tool install \
  black \
  ruff \
  pyright \
  mypy \
  debugpy

# --------------------------------------------------------------
# Node via fnm
# --------------------------------------------------------------
if ! command -v fnm >/dev/null 2>&1; then
  echo "==> Installing fnm"
  curl -fsSL https://fnm.vercel.app/install | bash
fi

if ! grep -q "fnm env" "$PROFILE"; then
  echo 'eval "$(fnm env)"' >> "$PROFILE"
fi

eval "$(fnm env)"

if ! command -v node >/dev/null 2>&1; then
  echo "==> Installing Node LTS"
  fnm install --lts
  fnm use --lts
fi

echo "==> Enabling corepack"
corepack enable || true

echo "==> Installing Node tools"
npm install -g \
  typescript \
  typescript-language-server \
  eslint \
  prettier \
  bash-language-server

# --------------------------------------------------------------
# Go
# --------------------------------------------------------------
GO_VERSION=1.22.0
GOROOT="$HOME/go"
GOPATH="$HOME/go-packages"

if [ ! -d "$GOROOT" ]; then
  echo "==> Installing Go $GO_VERSION"
  curl -LO "https://go.dev/dl/go${GO_VERSION}.windows-amd64.zip"
  unzip -q "go${GO_VERSION}.windows-amd64.zip"
  mv go "$GOROOT"
  rm "go${GO_VERSION}.windows-amd64.zip"
fi

mkdir -p "$GOPATH"

if ! grep -q GOROOT "$PROFILE"; then
  cat >> "$PROFILE" <<EOF
export GOROOT="$GOROOT"
export GOPATH="$GOPATH"
export PATH="\$GOROOT/bin:\$GOPATH/bin:\$PATH"
EOF
fi

export GOROOT
export GOPATH
export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"

echo "==> Installing Go tools"
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install honnef.co/go/tools/cmd/staticcheck@latest

# --------------------------------------------------------------
# PATH summary
# --------------------------------------------------------------
echo
echo "============================================================"
echo "PATH ENTRIES TO ADD"
echo "============================================================"
echo
echo "POSIX (Git Bash, WSL, etc.):"
echo
echo "  $BIN"
echo "  $LOCAL_BIN"
echo "  $GOROOT/bin"
echo "  $GOPATH/bin"
echo
echo "Windows (User PATH):"
echo
echo "  $(cygpath -w "$BIN")"
echo "  $(cygpath -w "$LOCAL_BIN")"
echo "  $(cygpath -w "$GOROOT/bin")"
echo "  $(cygpath -w "$GOPATH/bin")"
echo
echo "============================================================"
echo
echo "Restart shells to apply PATH changes."
echo "Provisioning complete."
