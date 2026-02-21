#!/usr/bin/env bash

MODEL_DIR="$HOME/ai/models"
LLAMA="$HOME/ai/llama.cpp.bin/bin/llama-cli"

# Default model
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
    -m)
        MODEL="${MODEL_DIR}/${2}.gguf"
        shift 2
        ;;
    *)
      shift
      ;;
  esac
done

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
