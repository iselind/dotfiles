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

ln -s ${DOT_FILES}/vim ~/.vim
ln -s ${DOT_FILES}/screenrc ~/.screenrc