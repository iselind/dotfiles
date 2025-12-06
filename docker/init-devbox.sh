#!/bin/bash
set -euo pipefail

# Initialize the devbox home directory on first start. This script is intended
# to be used as the container entrypoint. It copies any files from /etc/skel
# into the mounted home volume (only when not already present), creates
# commonly expected directories, fixes ownership, and then runs the requested
# command as the non-root `devbox` user.

SKEL=/etc/skel
HOME_DIR=/home/devbox
USER_NAME=devbox

echo "[init-devbox] checking home..."

if [ ! -e "$HOME_DIR/.initialized" ]; then
  echo "[init-devbox] populating $HOME_DIR from $SKEL"
  # Copy skel contents but don't overwrite existing files from bind-mounts
  cp -a "$SKEL/." "$HOME_DIR/" 2>/dev/null || true
  mkdir -p "$HOME_DIR/code" "$HOME_DIR/go"
  chown -R $USER_NAME:$USER_NAME "$HOME_DIR"
  touch "$HOME_DIR/.initialized"
else
  echo "[init-devbox] already initialized"
fi

# Ensure directories exist on subsequent starts and have correct ownership
mkdir -p "$HOME_DIR/code" "$HOME_DIR/go"
chown -R $USER_NAME:$USER_NAME "$HOME_DIR"

# If the plugins directory is a container-managed mount and is empty,
# install plugins automatically as the container user. This avoids
# populating host bind-mounted repos with plugin files.
PLUG_DIR="$HOME_DIR/.vim/plugged"
if [ -d "$PLUG_DIR" ]; then
  # Detect if PLUG_DIR is a mountpoint by comparing device numbers with its parent.
  PARENT="$(dirname "$PLUG_DIR")"
  if [ "$(stat -c %d "$PLUG_DIR")" != "$(stat -c %d "$PARENT")" ]; then
    if [ -z "$(ls -A "$PLUG_DIR" 2>/dev/null)" ]; then
      echo "[init-devbox] detected empty container-managed plugin volume at $PLUG_DIR; running PlugInstall"
      runuser -u $USER_NAME -- vim +'PlugInstall --sync' +qa || echo "[init-devbox] PlugInstall failed (non-fatal)"
    else
      echo "[init-devbox] plugin directory $PLUG_DIR already populated; skipping automatic install"
    fi
  else
    echo "[init-devbox] $PLUG_DIR is not a separate mountpoint; skipping automatic plugin install to avoid modifying host files"
  fi
fi

if [ $# -eq 0 ]; then
  exec runuser -u $USER_NAME -- /bin/bash
else
  exec runuser -u $USER_NAME -- "$@"
fi
