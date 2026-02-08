## Overview

This repo is a personal "dotfiles" collection that configures a development environment and editor (Vim + COC). Key goals for an AI coding agent working here:
- avoid unintentional edits to vendored plugins under `vim/plugged`
- prefer small, focused changes to configuration files and clear guidance when adding new tools
- keep the simple setup process maintainable

**Quick context:** The repository is Linux-focused with a straightforward setup script. It contains vendored Vim configuration under `vim/` (including `plug.vim` and `plugged/`), shell configurations, and a package installer.

## Key Files & Where to Make Changes
- `README.md`: top-level install notes. The canonical quick-start for users.
- `setup.sh`: main installation script. Symlinks vim and screenrc, sources shell configs, then runs the package installer.
- `shell/`: shell configuration files (`bashrc`, `bash_profile`, `profile`). These are sourced from user's shell config via `setup.sh` to avoid conflicts with user customizations.
- `provisioning/install.sh`: installs packages from `provisioning/packages/` directory (apt.txt, npm.txt, go.txt, python.txt).
- `vim/vimrc`: main Vim config. Add or modify plugin declarations using `Plug 'owner/repo'` inside the `plug#begin`/`plug#end` block.
- `vim/after/ftplugin/`: language-specific per-filetype tweaks — preferred place for language scoping (examples: `python.vim`, `go.vim`).
- `vim/plugged/`: vendored plugin copies (e.g., `coc.nvim`). Avoid editing these files unless intentionally updating a vendored plugin; prefer changing `vim/vimrc` or `vim/after/` files.
- `vim/python/lib/`: small helper code used by plugin integrations (formatters/linters). Modify only when implementing editor tooling changes.

## Installation & Usage
- **Install dotfiles**: Run `./setup.sh` in the repo root. This will:
  - Symlink `vim/` to `~/.vim`
  - Symlink `screenrc` to `~/.screenrc`
  - Source shell configs from the repo in user's shell profiles
  - Install packages from `simplification/packages/`
- **Package lists**: Edit files in `provisioning/packages/` (apt.txt, npm.txt, go.txt, python.txt) to customize what gets installed.
- **Manual verification**: After changes, run `setup.sh` and verify Vim opens correctly and plugins are available via `:PlugStatus` in Vim.

## Editor & Plugin Management Patterns
- Plugin management: `vim/vimrc` uses vim-plug. After changing `vim/vimrc` plugins, run `:PlugInstall` inside Vim (or `vim +'PlugInstall --sync' +qa` in a headless flow).
- PYTHONPATH: `vim/vimrc` sets `$PYTHONPATH` to `~/.vim/python/lib`. When adding Python helper code, place it under `vim/python/lib` so plugins can import it.
- Filetype overrides: Use `vim/after/ftplugin/<lang>.vim` for language-specific mappings and settings to avoid touching global `vimrc`.

## Project-Specific Conventions & Notes
- Vendored plugins: `vim/plugged/` contains a copy of `coc.nvim` and related files. Treat this directory as read-only for routine changes.
- Setup strategy: `setup.sh` symlinks top-level configs (vim, screenrc) but sources shell configs to avoid overwriting user customizations. Follow this pattern when adding new configurations.
- Shell config sourcing: Instead of symlinking bashrc/profile, `setup.sh` appends source lines to user's existing config files. This prevents conflicts with user customizations.
- No formal test suite: Validate changes manually by running `setup.sh` and testing Vim. Document verification steps when making changes.

## Typical Tasks & Examples
- **Add a new Vim plugin**:
  - Edit `vim/vimrc` and add `Plug 'owner/new-plugin'` inside the `plug#begin`/`plug#end` block.
  - Run `./setup.sh` (or manually run `:PlugInstall` in Vim).

- **Add packages to install**:
  - Add package names to the appropriate file in `provisioning/packages/` (e.g., apt.txt for apt packages).
  - Run `./setup.sh` to install them.

- **Update shell configuration**:
  - Edit files in `shell/` (bashrc, bash_profile, profile).
  - Run `./setup.sh` to source them into user profiles (non-destructively).

## What Not To Do
- Don't modify `vim/plugged/*` to change behavior — update `vim/vimrc` or `vim/after/ftplugin` instead.
- Don't add Docker, DevBox, or other infrastructure that doesn't currently exist without an explicit owner request.
- Avoid large or opinionated refactors across many dotfiles without an explicit owner request; prefer small incremental changes and document why.
- Don't use `ln -s` (symlinks) for shell config files; `setup.sh` sources them instead to avoid overwriting user customizations.

## PR + Commit Guidance
- Keep commits focused (one concern per commit). Prefer short descriptions and reference which platform is affected (Linux/Windows).
- Create a new commit when we have reached a better state to bookmark the progress.

## Where to Look for More Context
- `README.md` — installation quick-start.
- `setup.sh` — main installation orchestration.
- `vim/vimrc`, `vim/after/ftplugin/`, `vim/python/` — editor configuration and helper code.
- `provisioning/install.sh` — package installation logic.
- `provisioning/packages/` — package lists for different package managers.