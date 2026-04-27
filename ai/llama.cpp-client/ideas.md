# LLM File Editing Loop — Ideas & Notes

This document captures design ideas, constraints, and future improvements
for the LLM-driven file editing loop.

The goal is NOT to implement everything at once, but to:
- preserve good ideas
- guide iteration
- avoid rediscovering the same problems

---

## 🚧 Current Goal (v1)

Build a minimal, working loop that can:
- read parts of files
- modify files
- log everything

Focus on:
- correctness over cleverness
- observability over optimization

---

## 🧩 Core Design: HTTP-Inspired Tool Schema

### Philosophy

Separate:
- **control plane** → structured metadata
- **data plane** → raw content

Avoid mixing structured data and file content.

---

## 📦 Tool Call Format (v1)

### Read

```

ACTION: READ
FILE: /absolute/path
START: <int>
END: <int>

```

---

### Replace

```

ACTION: REPLACE
FILE: /absolute/path
START: <int>
END: <int>

CONTENT: <raw text>

```

---

### Insert

```

ACTION: INSERT
FILE: /absolute/path
POSITION: <int> | END

CONTENT: <raw text>

```

---

## 📏 Semantics

### Line Model

- Lines are **1-indexed**
- `START` and `END` are **inclusive**
- A “line” is defined by the system (not the LLM)

---

### Replace

```

START: 5
END: 7

```

→ replaces lines 5, 6, 7

---

### Delete

```

START: 5
END: 7
CONTENT: (empty)

```

→ removes lines 5–7

---

### Insert

```

POSITION: 6

```

→ insert **before line 6**

```

POSITION: END

```

→ append to file

---

## 📄 File Handling Rules

- Use `splitlines(keepends=True)`
- Preserve original newline style (`\n`, `\r\n`, `\r`)
- Normalize inserted content to match file style
- Do NOT strip whitespace unless explicitly intended

---

## 🧠 LLM Interaction Model

- LLM operates on **numbered lines**, not raw text
- LLM must **read before editing**
- Edits are based on the latest known state

---

## 🪵 Logging (High Priority)

Log everything for debugging:

- prompt
- raw LLM response
- parsed tool call
- tool result
- file diff (before/after)

This is critical for:
- debugging failures
- improving prompts
- understanding behavior

---

## ⚠️ Known Limitations (v1)

- No conflict detection
- No protection against stale reads
- No multi-edit batching
- No overview/navigation support
- Inefficient for large files

These are acceptable for v1.

---

## 💡 Future Ideas

### 🔁 Consistency & Safety

- [ ] “pollution” model for tracking modified regions
- [ ] expected-content validation before apply
- [ ] reject edits on stale/polluted ranges
- [ ] versioning / hash-based checks

---

### 📉 Token Optimization

- [ ] remove full-file read capability
- [ ] enforce max N lines per read
- [ ] encourage incremental reads
- [ ] compress empty lines in output

---

### 🧭 Navigation

- [ ] file overview / TOC (heuristic-based)
- [ ] sampling large files
- [ ] anchor-based reads (search-like)

---

### 🧱 Edit Model Improvements

- [ ] support multi-operation batches
- [ ] non-overlapping edit enforcement
- [ ] better insert/replace ergonomics

---

### 🔤 Formatting & Structure

- [ ] indentation awareness
- [ ] language-agnostic block detection
- [ ] newline edge-case handling

---

## ❌ Anti-Patterns (Do NOT Do)

- ❌ Do NOT embed file content inside JSON
- ❌ Do NOT rely on LLM to escape text correctly
- ❌ Do NOT let LLM define line delimiters
- ❌ Do NOT assume LLM can compute hashes correctly
- ❌ Do NOT overfit protocol before observing real failures

---

## ✅ Best Practices

- ✔ keep protocol simple and explicit
- ✔ separate structure from raw content
- ✔ validate inputs strictly
- ✔ fail fast on ambiguity
- ✔ prefer retries over complex correction logic
- ✔ log everything

---

## 🧠 Guiding Principles

- The LLM expresses **intent**
- The system handles **mechanics**
- Simplicity > cleverness
- Observability > optimization
- Correctness > convenience

---

## 🪜 Next Steps

- [ ] implement basic tool loop
- [ ] implement file read/edit operations
- [ ] implement logging
- [ ] test on small real-world edits
- [ ] review logs before adding complexity
