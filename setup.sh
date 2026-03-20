#!/usr/bin/env bash
set -euo pipefail
# Explaining the set flags:
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error and exit immediately.
# -o pipefail: Prevent errors in a pipeline from being masked. If any command in
#              a pipeline fails, that return code will be used as the return code
#              of the whole pipeline.

# set -x # For debugging, see all commands being executed

SCRIPT_PATH="$(realpath "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
DOT_FILES="${SCRIPT_DIR}"

# The options for ln:
# -s: Create symbolic links instead of hard links.
# -f: Remove existing destination files before creating the link.
# -n: Treat the destination as a normal file if it is a symbolic link to a directory.
# -v: Verbose mode, print what is being done.
# Create a symlink, backing up any existing non-symlink target with a timestamp.
# -n is not needed because we explicitly remove any existing symlink before calling ln,
# so ln never sees a symlink-to-directory at the destination and won't dereference it.
# Usage: link_dotfile <source> <target>
link_dotfile() {
    local src="$1"
    local dst="$2"
    if [ -L "$dst" ]; then
        rm -v "$dst"
    elif [ -e "$dst" ]; then
        mv -v "$dst" "${dst}.bak$(date +%s)"
    fi
    ln -sv "$src" "$dst"
}

link_dotfile "${DOT_FILES}/vim" ~/.vim
link_dotfile "${DOT_FILES}/screenrc" ~/.screenrc

mkdir -p ~/.claude
link_dotfile "${DOT_FILES}/claude-skills" ~/.claude/skills
link_dotfile "${DOT_FILES}/claude-memory" ~/.claude/memory

# Install shell configuration files by sourcing them from the dotfiles repo.
# We can't just symlink them because the user might have customizations.
# Instead, we append a source line to the user's existing config if not already there.
for config in bashrc profile bash_profile; do
    home_config="${HOME}/.${config}"
    touch "$home_config" # Ensure the file exists before grepping
    if ! grep -q "source ${DOT_FILES}/shell/${config}" "$home_config" 2>/dev/null; then
        echo "[ -f ${DOT_FILES}/shell/${config} ] && source ${DOT_FILES}/shell/${config}" >> "$home_config"
    fi
done

# Make sure the binaries we expect are in place
./provisioning/install.sh
