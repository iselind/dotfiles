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