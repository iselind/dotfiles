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
ln -sfnv "${DOT_FILES}/vim" ~/.vim
ln -sfnv "${DOT_FILES}/screenrc" ~/.screenrc

mkdir -p ~/.claude
# If skills is already a symlink, we want to remove it before creating a new one. If it's a directory, we want to back it up before creating the symlink.
if [ -L ~/.claude/skills ]; then
    rm -v ~/.claude/skills
elif [ -d ~/.claude/skills ]; then
    mv -v ~/.claude/skills "$HOME/.claude/skills.bak$(date +%s)" 2>/dev/null || true  # Backup existing skills if they exist
fi
ln -sfv "${DOT_FILES}/claude-skills" ~/.claude/skills  # This is a directory, so we don't use -n

exit 0
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
