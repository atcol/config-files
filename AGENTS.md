# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal Nix home-manager flake. `home.nix` is the entry point and imports the per-tool modules: `packages.nix`, `custom-shell.nix`, `claude-code.nix`, `codex.nix`, `starship.nix`, `neovim.nix`, `tmux.nix`. The flake (`flake.nix`) exposes `home.nix` as `nixosModules.default`. CI (`.github/workflows/`) runs `home-manager switch` against `home.nix` on every push.

The user invokes builds manually — they prefer to run `home-manager switch --flake .` themselves rather than have the agent rebuild.

## Apply / verify

- Apply config: `home-manager switch --flake .` (creates the `result` symlink — do not commit it).
- The activated config currently lives at `result -> /nix/store/<hash>-home-manager-generation`.
- Installed nvim plugins land at `~/.local/share/nvim/site/pack/hm/start/` — use this to verify Nix-managed plugins after a switch.

## Neovim config layout

`neovim.nix` declares plugins via `pkgs.vimPlugins.*` and concatenates lua files from `vim/` in a fixed order via `extraLuaConfig`. `vim/vimrc` is loaded first as `extraConfig`. Order matters: an error in vimrc (e.g. a missing colorscheme) aborts the source command and prevents subsequent lua files from running, which breaks plugin setup including packer command registration.

`vim/packer.lua` exists but plugins should be added via Nix (`neovim.nix`), not packer — packer is only kept as a fallback for plugins not yet available in nixpkgs. The `vim/packer.lua` file still runs `packer.startup(...)` so `:PackerSync` is available, but prefer the Nix path.

## AI tooling integration (`ai/` directory)

The `ai/` tree is the **single source** for AI assistant configuration; per-tool nix modules fan it out:

- `ai/skills/<name>/SKILL.md` — skills. `claude-code.nix` and `codex.nix` each declare a `skillsToCopy` attrset that `cp -rL`s the directory into `~/.claude/skills/` and `~/.codex/skills/` respectively (symlinks don't work — Claude can't read through them). `custom-shell.nix` separately converts selected skills into Gemini TOML commands via the `claudeToGemini` helper.
- `ai/agents/*.md` — registered in `claude-code.nix`'s `programs.claude-code.agents` and `codex.nix`'s `agentsToCopy`.
- `ai/commands/*.md` — registered in `programs.claude-code.commands` (Claude) and converted to `.gemini/commands/*.toml` in `custom-shell.nix`.

When **adding a new skill**: drop `ai/skills/<name>/SKILL.md`, then add an entry to `skillsToCopy` in `claude-code.nix` and/or `codex.nix`. Not every skill is registered everywhere — check existing pattern (e.g. `cpp-cmake` is Claude-only). For Gemini exposure, add a `.gemini/commands/<name>.toml` line to `custom-shell.nix` using `claudeToGemini`.

## MCP servers

`mcp-servers.nix` is the shared source, imported by both `claude-code.nix` and `codex.nix`. For Claude, MCP servers are merged into `~/.claude.json` via a `jq`-based activation script (not overwritten — Claude stores state in that file).

## Conventions

- Commit style: prefix with `feat:` / `fix:` / etc., short subject, body explains "why" not "what". Examples: see `git log`.
- The repo has no test suite or lint step beyond what CI runs (`home-manager switch` itself is the test).
- `Makefile.rust` is a template for new Rust projects (used by the `bootstrap-rust` skill), not for this repo.
