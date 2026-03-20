# dotfiles
My dotfiles

## Installation

```bash
./setup.sh
```

### Prerequisites
- Bash, Vim, and Git
- For full language support: Python, Go, Node.js

### After installation
After running `setup.sh`, open Vim and run `:PlugInstall` to install plugins.

Open any Go file in Vim and wait a bit so that the gopls setup can complete once. The file doesn't even have to contain any Go code. It will initialize `coc-go`.

### Tooling
Development tooling (linters, formatters, language servers) for Python, Go, JavaScript/TypeScript, Shell, Java, and more is configured in `provisioning/packages/`.

## Claude Code

`setup.sh` symlinks two directories into `~/.claude/` so that Claude Code configuration is version-controlled and portable across machines. Because the dotfiles repo may land at different paths on different machines, the symlinks always point into wherever the repo was cloned — never hardcoded absolute paths.

### `claude-skills/` → `~/.claude/skills`

Skills are prompt files that extend Claude Code with project-specific slash commands (e.g. `/review`, `/extract-adr`). Each skill is a markdown file that gets expanded into a full prompt when invoked.

Skills in this repo are global — they work across all projects.

### `claude-memory/` → `~/.claude/memory`

Memory files give Claude persistent context that survives across conversations. Claude writes to this directory automatically during sessions; commit the changes when they look correct.

There are four memory types:

| Type | Purpose |
|------|---------|
| `user` | Who you are — role, expertise, working style |
| `feedback` | How Claude should behave — corrections and confirmed approaches |
| `project` | In-flight work context: goals, constraints, decisions not visible in the code |
| `reference` | Pointers to external systems (Linear projects, Grafana boards, Slack channels) |

`MEMORY.md` inside the directory is an index file Claude maintains automatically — it lists all memory files with one-line descriptions and is always loaded into context.