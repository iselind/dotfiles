#!/usr/bin/env bash
set -euo pipefail

echo "==> Starting user-space dev environment install"

BIN="$HOME/bin"
PROFILE="$HOME/.bashrc"

mkdir -p "$BIN"

add_to_path() {
  if ! grep -q "$BIN" "$PROFILE" 2>/dev/null; then
    echo "export PATH=\"$BIN:\$PATH\"" >> "$PROFILE"
  fi
}

add_to_path

export PATH="$BIN:$PATH"

# --------------------------------------------------------------
# uv (Python)
# --------------------------------------------------------------
if ! command -v uv >/dev/null 2>&1; then
  echo "==> Installing uv"
  curl -Ls https://astral.sh/uv/install.sh | sh
fi

# --------------------------------------------------------------
# fnm (Node.js)
# --------------------------------------------------------------
if ! command -v fnm >/dev/null 2>&1; then
  echo "==> Installing fnm"
  curl -fsSL https://fnm.vercel.app/install | bash
fi

# shell integration for fnm
if ! grep -q "fnm env" "$PROFILE"; then
  echo 'eval "$(fnm env)"' >> "$PROFILE"
fi

# --------------------------------------------------------------
# Go
# --------------------------------------------------------------
GO_VERSION=1.22.0
GO_DIR="$HOME/go"

if [ ! -d "$GO_DIR" ]; then
  echo "==> Installing Go $GO_VERSION"
  curl -LO "https://go.dev/dl/go${GO_VERSION}.windows-amd64.zip"
  unzip "go${GO_VERSION}.windows-amd64.zip"
  mv go "$GO_DIR"
  rm "go${GO_VERSION}.windows-amd64.zip"
fi

if ! grep -q GOROOT "$PROFILE"; then
  cat >> "$PROFILE" <<EOF
export GOROOT="$GO_DIR"
export GOPATH="\$HOME/go-packages"
export PATH="\$GOROOT/bin:\$GOPATH/bin:\$PATH"
EOF
fi

# --------------------------------------------------------------
# Node corepack
# --------------------------------------------------------------
if command -v node >/dev/null 2>&1; then
  echo "==> Enabling corepack"
  corepack enable || true
fi

echo "==> Done."
echo "Restart Git Bash to pick up environment changes."
