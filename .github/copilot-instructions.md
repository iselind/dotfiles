## Overview

This repo is a personal "dotfiles" collection that configures a development environment and editor (Vim + COC). Key goals for an AI coding agent working here:
- help keep platform-specific scripts and configs consistent (Linux/Windows)
- avoid unintentional edits to vendored plugins under `vim/plugged`
- prefer small, focused changes to configuration files and clear guidance when adding new tools

**Quick context:** The repository contains a Docker-based DevBox (Dockerfile + `docker-compose.yml`), vendored Vim configuration under `vim/` (including `plug.vim` and `plugged/`), and platform helper scripts in `bin/`.

## Key Files & Where to Make Changes
- `README.md`: top-level install notes and symlink examples used by the owner. Use this as the canonical quick-start.
- `Dockerfile` and `docker-compose.yml`: define the DevBox. Changes here affect local development images and volumes.
- `bin/windows/*.cmd` and `bin/linux/*`: platform-specific helper scripts. Add platform-specific helpers in the appropriate subfolder.
  - When adding helper scripts, prefer reusing the existing helpers rather than calling the corresponding raw commands directly.
  - Keep Linux and Windows helpers in sync: when adding or changing a script under `bin/linux`, add or update the corresponding `bin/windows` script (and vice versa). Maintain the same command interface where possible.
- `vim/vimrc`: the main Vim config. Add or modify plugin declarations here using `Plug 'owner/repo'` inside the `plug#begin`/`plug#end` block.
- `vim/after/ftplugin/`: language-specific per-filetype tweaks — preferred place for language scoping (examples: `python.vim`, `go.vim`).
- `vim/plugged/`: vendored plugin copies (e.g., `coc.nvim`). Avoid editing these files unless intentionally updating a vendored plugin; prefer changing `vim/vimrc` or `vim/after/` files.
- `vim/python/lib/`: small helper code used by plugin integrations (formatters/linters). Modify only when implementing editor tooling changes.

## DevBox / Build / Run Conventions
- Build image: Windows helper `./bin/rebuild-devbox.cmd` runs `docker compose build`. On Linux/macOS use `docker compose build` in repo root.
- Start container and open a shell: `./bin/start-devbox.cmd` (Windows). Equivalently on Linux/macOS:

```
docker compose up -d --no-recreate
docker exec -it devbox /bin/bash
```

- Stop container: `./bin/stop-devbox.cmd` (Windows) or `docker compose down`.
- The `docker-compose.yml` expects a host-mounted home folder (uses `${USER_HOME}` variable in the compose file). Keep changes to volumes in mind — they affect what files are visible inside the container.

## Editor & Plugin Management Patterns
- Plugin management: `vim/vimrc` uses vim-plug. After changing `vim/vimrc` plugins, run `:PlugInstall` inside Vim (or `vim +'PlugInstall --sync' +qa` in a headless flow).
- PYTHONPATH: `vim/vimrc` sets `$PYTHONPATH` to `~/.vim/python/lib`. When adding Python helper code, place it under `vim/python/lib` so plugins can import it.
- Filetype overrides: Use `vim/after/ftplugin/<lang>.vim` for language-specific mappings and settings to avoid touching global `vimrc`.

## Project-Specific Conventions & Notes
- Cross-platform scripts: Windows helper scripts live in `bin/windows` as `.cmd` files and assume `docker`/`docker compose` are available. Linux tools are under `bin/linux` (sh scripts).
- Avoid Powershell scripts: the owner prefers `.cmd` for Windows compatibility, simplicity, and to avoid the corporate requirement of signed scripts.
- Vendored plugins: `vim/plugged/` contains a copy of `coc.nvim` and related files. Treat vendor directory as read-only for routine changes.
- Symlink-based install: `README.md` shows how the owner installs dotfiles via `ln -s ${PWD}/vim ~/.vim` etc. When adding new top-level config directories, update `README.md` to include symlink guidance.
- No formal test suite: there are no automated tests in this repo. Validate changes manually (e.g., start DevBox and open Vim) and document manual verification steps in `README.md` or in the PR description.

## Typical Tasks & Examples
- Add a new Vim plugin:
  - Edit `vim/vimrc` and add `Plug 'owner/new-plugin'` inside the `plug#begin` block.
  - In a running environment (host or devbox) open Vim and run `:PlugInstall`.

- Update DevBox packages:
  - Edit `Dockerfile` and rebuild: `rebuild-debbox.cmd`.
  - Stop any running containers: `stop-devbox.cmd`.
  - Start devbox: `start-devbox.cmd`.

## What Not To Do
- Don't modify `vim/plugged/*` to change behavior — update `vim/vimrc` or `vim/after/ftplugin` instead.
- Avoid large or opinionated refactors across many dotfiles without an explicit owner request; prefer small incremental changes and document why.

## PR + Commit Guidance
- Keep commits focused (one concern per commit). Prefer short descriptions and reference which platform is affected (Linux/Windows)
- Create a new commit when we have reached a better state to bookmark the progress.

## Where to Look for More Context
- `README.md` (repo root) — installation and DevBox notes.
- `Dockerfile`, `docker-compose.yml` — DevBox definitions and environment variables.
- `vim/vimrc`, `vim/after/ftplugin/`, `vim/python/` — editor configuration and helper code.
- `bin/windows/*`, `bin/linux/*` — platform helper scripts; use them as canonical examples.