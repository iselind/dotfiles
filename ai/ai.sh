#!/usr/bin/env bash

MODEL_DIR="$HOME/ai/models"
LLAMA="$HOME/ai/llama.cpp/main"

MODEL_SMALL="$MODEL_DIR/small.gguf"

MODEL="$MODEL_SMALL"

PROMPT=""
THREADS=6

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p)
      PROMPT="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

# What is the -t test?
# -t tests if the file descriptor is associated with a terminal. If it returns true, it means that the script is being run interactively and not receiving input from a pipe or file. If it returns false, it means that the script is receiving input from a pipe or file.`
if [ -t 0 ]; then
  INPUT=""
else
  INPUT=$(cat)
fi

FULL_PROMPT="$PROMPT
$INPUT"

$LLAMA \
  -m "$MODEL" \
  -p "$FULL_PROMPT" \
  -c 2048 \
  --threads $THREADS \
  --temp 0 \
  --top-p 1 \
  --repeat-penalty 1 \
  --seed 42
