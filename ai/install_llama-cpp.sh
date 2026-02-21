#!/bin/bash -ex
# Install llama.cpp with model and helper script.

SCRIPT_PATH="$(realpath "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

sudo apt update
sudo apt install build-essential git cmake curl -y

mkdir -p "$HOME/ai"
cd "$HOME/ai"

if [ ! -d "llama.cpp" ]; then
    git clone "https://github.com/ggerganov/llama.cpp"
fi
mkdir -p llama.cpp.bin
cmake -S llama.cpp -B llama.cpp.bin  \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLAMA_BUILD_EXAMPLES=OFF
cmake --build llama.cpp.bin --parallel=2

mkdir -p "$HOME/ai/models"
if [ ! -f "$HOME/ai/models/small.gguf" ]; then
    cd "$HOME/ai/models"
    echo "Downloading model..."
    wget "https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/blob/main/qwen2.5-3b-instruct-q4_k_m.gguf"
    n -s "qwen2.5-3b-instruct-q4_k_m.gguf" "small.gguf"
fi

mkdir -p "$HOME/ai/bin"
cp "$SCRIPT_DIR/ai.sh" "$HOME/ai/bin/ai"
chmod +x "$HOME/ai/bin/ai"

# shellcheck disable=SC2016
echo 'export PATH="$HOME/ai/bin:$PATH"' >> "$HOME/.bashrc"

# Now we have
# ai -p "Explain this code:" < file.ts
