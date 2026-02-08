#!/usr/bin/env bash
set -euo pipefail
# Explaining the set flags:
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error and exit immediately.
# -o pipefail: Prevent errors in a pipeline from being masked. If any command in
#              a pipeline fails, that return code will be used as the return code
#              of the whole pipeline.

SCRIPT_DIR="$(dirname "$0")"
DOT_FILES="${SCRIPT_DIR}"

ln -sf ${DOT_FILES}/vim ~/.vim
ln -sf ${DOT_FILES}/screenrc ~/.screenrc

# Make sure the binaries we expect are in place
./packages/install.sh

# How do we install the bashrc? We can't just symlink it, because the user might have customizations. Instead, we can append a source line to the user's existing .bashrc if it's not already there.
touch ~/.bashrc # Ensure the file exists before grepping
if ! grep -q "source ${DOT_FILES}/shell/bashrc" ~/.bashrc 2>/dev/null; then
    echo "source ${DOT_FILES}/shell/bashrc" >> ~/.bashrc
fi

# Let's do the corresponding thing for the profile, which is sourced at login. This is where we want to put session-wide exports and PATH updates.
touch ~/.profile # Ensure the file exists before grepping
if ! grep -q "source ${DOT_FILES}/shell/profile" ~/.profile 2>/dev/null; then
    echo "source ${DOT_FILES}/shell/profile" >> ~/.profile
fi

# Bash login shell configuration (bash_profile). This file sources ~/.profile and is used by bash for login shells.
touch ~/.bash_profile # Ensure the file exists before grepping
if ! grep -q "source ${DOT_FILES}/shell/bash_profile" ~/.bash_profile 2>/dev/null; then
    echo "source ${DOT_FILES}/shell/bash_profile" >> ~/.bash_profile
fi