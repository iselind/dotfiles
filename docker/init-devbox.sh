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

if [ $# -eq 0 ]; then
  exec runuser -u $USER_NAME -- /bin/bash
else
  exec runuser -u $USER_NAME -- "$@"
fi
