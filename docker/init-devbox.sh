#!/bin/bash
set -euo pipefail

# Initialize the devbox home directory on first start. This script is intended
# to be used as the container entrypoint. It copies any files from /etc/skel
# into the mounted home volume (only when not already present), creates
# commonly expected directories, fixes ownership, and then runs the requested
# command as the non-root `devbox` user.

SKEL=/etc/skel
HOME_DIR=/home/devbox

echo "[init-devbox] checking home..."

# Helper: set ownership of HOME_DIR to the runtime user.
# Prefers the named `ubuntu` user when present, otherwise falls back
# to the current owner of the home directory.
set_home_owner() {
  if getent passwd ubuntu >/dev/null 2>&1; then
    TARGET_UID=$(getent passwd ubuntu | cut -d: -f3)
    TARGET_GID=$(getent passwd ubuntu | cut -d: -f4)
  else
    TARGET_UID=$(stat -c %u "$HOME_DIR" || echo 0)
    TARGET_GID=$(stat -c %g "$HOME_DIR" || echo 0)
  fi

  if [ -n "$TARGET_UID" ] && [ -n "$TARGET_GID" ]; then
    echo "[init-devbox] setting ownership of $HOME_DIR files to UID:$TARGET_UID GID:$TARGET_GID"
    chown -R "$TARGET_UID:$TARGET_GID" "$HOME_DIR" || echo "[init-devbox] chown failed (non-fatal)"
  fi
}

if [ ! -e "$HOME_DIR/.initialized" ]; then
  echo "[init-devbox] populating $HOME_DIR from $SKEL"
  # Copy skel contents but don't overwrite existing files from bind-mounts
  cp "$SKEL/." "$HOME_DIR/" 2>/dev/null || true

  # Create common directories (may be created as root); we'll fix
  # ownership below so they end up owned by the non-root runtime user.
  mkdir -p "$HOME_DIR/code" "$HOME_DIR/go"

  # Fix ownership to runtime user
  set_home_owner

  # If the plugins directory is empty and managed by the container, do not
  # attempt to run PlugInstall here (we must not demote from root in the
  # init script). Instead, inform the user how to install plugins as the
  # non-root `ubuntu` user after the container starts.
  PLUG_DIR="$HOME_DIR/.vim/plugged"
  if [ -d "$PLUG_DIR" ]; then
    if [ -z "$(ls -A "$PLUG_DIR" 2>/dev/null)" ]; then
      echo "[init-devbox] plugin directory $PLUG_DIR is empty. To install plugins, run as ubuntu:"
      echo "  docker compose exec --user ubuntu devbox vim +'PlugInstall --sync' +qa"
    else
      echo "[init-devbox] plugin directory $PLUG_DIR already populated; skipping automatic install"
    fi
  fi

  touch "$HOME_DIR/.initialized"
else
  echo "[init-devbox] already initialized"
fi

# Ensure directories exist on subsequent starts and have correct ownership
mkdir -p "$HOME_DIR/code" "$HOME_DIR/go"
if [ "$(id -u)" -eq 0 ]; then
  # If we're root, make sure the directories are owned by the runtime user
  # and then keep the container alive. We do NOT drop to the runtime user
  # here — interactive shells or commands should be started explicitly
  # via `docker compose exec --user ubuntu ...` (see `bin/linux/start-devbox`).
  set_home_owner || true
  echo "[init-devbox] initialization complete; keeping container alive (PID 1)"
  exec tail -f /dev/null
else
  if [ $# -eq 0 ]; then
    exec /bin/bash
  else
    exec "$@"
  fi
fi
