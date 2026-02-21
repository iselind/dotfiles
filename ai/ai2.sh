#!/usr/bin/env bash

MODEL="qwen-local"
OLLAMA_URL="http://localhost:11434/api/generate"

MODE="explain"
TARGET=""
RANGE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    explain|review|refactor)
      MODE="$1"
      shift
      ;;
    *)
      TARGET="$1"
      shift
      ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "Usage: ai [explain|review|refactor] file[:start-end]"
  exit 1
fi

FILE="${TARGET%%:*}"
RANGE="${TARGET#*:}"

if [[ "$FILE" == "$RANGE" ]]; then
  RANGE=""
fi

if [[ ! -f "$FILE" ]]; then
  echo "File not found: $FILE"
  exit 1
fi

CONTENT=$(cat "$FILE")

FOCUS=""
if [[ -n "$RANGE" ]]; then
  FOCUS="Focus lines: $RANGE"
fi

PROMPT=$(cat <<EOF
You are a deterministic senior code reviewer.

File: $FILE
$FOCUS

--- FILE START ---
$CONTENT
--- FILE END ---

Task: $MODE

Rules:
- Focus primarily on the specified lines if given.
- Use surrounding context only from this file.
- Do not speculate about missing files.
- Be concise.
EOF
)

curl -s "$OLLAMA_URL" \
  -d "{
    \"model\": \"$MODEL\",
    \"prompt\": $(jq -Rs . <<<"$PROMPT"),
    \"stream\": false
  }" | jq -r '.response'
