#!/bin/bash -e
# Install llama.cpp with model and helper script.

sudo apt update
sudo apt install build-essential git cmake curl -y

mkdir -p ~/ai
cd ~/ai

git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
make -j

mkdir -p ~/ai/models
if [ ! -f "small.gguf" ]; then
    (
        cd ~/ai/models
        echo "Downloading model..."
        wget "https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/blob/main/qwen2.5-3b-instruct-q4_k_m.gguf"
        ln -s "small.gguf" "qwen2.5-3b-instruct-q4_k_m.gguf"
    )
fi

mkdir -p ~/ai/bin
cat > ~/ai/bin/ai <<EOF
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
EOF

chmod +x ~/ai/bin/ai
# shellcheck disable=SC2016
echo 'export PATH="$HOME/ai/bin:$PATH"' >> ~/.bashr
# source ~/.bashrc

# Now we have
# ai -p "Explain this code:" < file.ts

cat >tuning_guide.txt <<EOF
You said you don’t know temp/top-p yet. Quick intuition:

--temp 0 → no creativity, more deterministic

--top-p 1 → no probability truncation

--seed 42 → same output each time

--repeat-penalty 1 → neutral

For code review work, this is good.

We can tune later once it’s running.
EOF

cat > promt-notes.md <<EOF
Right now the prompt is:
\`\`\`
Refactor this
<file content>
\`\`\`
For instruct models, it’s better to explicitly frame the task. Replace:
\`\`\`
FULL_PROMPT="$PROMPT
$INPUT"
\`\`\`
with
\`\`\`
FULL_PROMPT="You are a senior software engineer performing a code review.

Task:
$PROMPT

Code:
$INPUT

Response:"
\`\`\`
This dramatically improves smaller models.
EOF
