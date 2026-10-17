---
name: Home setup has no NVIDIA GPU
description: User's home laptops lack NVIDIA GPUs; LLM inference at home requires Vulkan via llama.cpp on Windows host. Relevant when recommending local model runtimes, server setups, or WSL2 architectures.
type: user
---

User's home laptops do not have NVIDIA GPUs. CUDA-only runtimes are not viable for GPU inference at home, and mainline Ollama builds (which lack Vulkan) likewise do not work — only Vulkan-capable runtimes such as llama.cpp built with `GGML_VULKAN=ON` give them GPU acceleration.

**Why:** Without GPU acceleration the user is stuck with CPU-only inference, which is too slow for iterative LLM workflows. WSL2 does not surface Vulkan to Linux userspace, so the inference server runs on the Windows host even though the rest of their dev environment lives in WSL2 Debian.

**How to apply:** When recommending local model runtimes for home use, default to llama.cpp + Vulkan on the Windows host, with aider (or whatever client) in WSL2 connecting via the OpenAI-compat shim. Do not default-recommend Ollama for the home setup. At work this constraint does not apply — they have access to Claude (Code) there.
