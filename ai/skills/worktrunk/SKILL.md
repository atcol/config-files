---
name: worktrunk
description: >
  Manage Git worktrees with worktrunk (wt) for parallel development and multi-agent
  workflows. Use this skill whenever the user mentions worktrees, parallel branches,
  running multiple Claude instances, "wt", "worktrunk", spinning up agents in parallel,
  managing feature branches side by side, or asks about working on multiple features
  simultaneously. Also trigger when the user says "switch worktree", "create a worktree",
  "merge worktree", "list worktrees", "parallel agents", "run claude in parallel",
  or wants to set up a multi-agent development workflow.
---

# Worktrunk (`wt`) — Git Worktree Manager

## What this skill does

Helps users manage Git worktrees using the `wt` CLI for parallel development — especially
running multiple AI coding agents (like Claude Code) on different features simultaneously.

## When to use this skill

- User wants to work on multiple branches simultaneously
- User wants to run multiple Claude Code instances in parallel
- User asks about Git worktrees or worktree management
- User mentions `wt` or `worktrunk`
- User wants to merge a feature branch back cleanly

## Core commands

### Switch to or create a worktree

```bash
# Switch to existing worktree
wt switch feat

# Create new branch + worktree
wt switch -c feat

# Create and immediately launch Claude Code in it
wt switch -c -x claude feat

# Create with an initial prompt for Claude
wt switch -x claude -c feature-a -- 'Add user authentication'
```

### List worktrees

```bash
# Show all worktrees with status (staged changes, unpushed commits, remote status)
wt list

# Show full details including CI status and diffstat
wt list --full
```

The current worktree is marked with `@`.

### Merge a feature branch

```bash
# From the feature worktree: squash, rebase, merge, and clean up
wt merge
```

This is a single command that squashes commits, rebases onto the base branch,
merges, and removes the worktree. By default it squashes — disable with
`wt merge --no-squash`.

### Remove a worktree

```bash
wt remove feat
```

Deletes the worktree and its associated branch.

## Parallel agent workflow

The primary use case is spinning up multiple Claude instances on different features:

```bash
# Terminal 1: work on auth
wt switch -x claude -c auth -- 'Implement OAuth2 login flow'

# Terminal 2: work on pagination
wt switch -x claude -c pagination -- 'Fix pagination bug in /api/users'

# Terminal 3: work on tests
wt switch -x claude -c tests -- 'Add integration tests for checkout'
```

Each agent works in its own directory with its own branch — no conflicts.

When a feature is done, merge it back:

```bash
wt switch auth
wt merge
```

## Configuration

Worktrunk uses TOML configuration at two levels:

| Scope | Path | Purpose |
|-------|------|---------|
| User | `~/.config/worktrunk/config.toml` | Personal preferences (not committed) |
| Project | `.config/wt.toml` | Team settings (committed to repo) |

### Common user config

```toml
# Where to create worktrees (relative to repo root)
worktree-path = ".worktrees/{{ branch | sanitize }}"

[merge]
squash = true
rebase = true
remove = true

[commit]
stage = "all"
```

### Build cache sharing

Create a `.worktreeinclude` file in the repo root to copy build artifacts between
worktrees (these paths must also be gitignored):

```
# .worktreeinclude
target/
node_modules/
build/
.direnv
```

This avoids redundant rebuilds when creating new worktrees.

### Project hooks

Define in `.config/wt.toml`:

```toml
[[hooks]]
on = "post-create"
run = "direnv allow"

[[hooks]]
on = "post-create"
run = "npm install"
```

Available hooks: `pre-switch`, `post-start`, `post-create`, `post-switch`,
`pre-commit`, `pre-merge`, `post-merge`, `pre-remove`, `post-remove`.

## Shell setup

After installing worktrunk, the shell function must be installed for `wt switch`
to change directories:

```bash
wt config shell install
```

This adds a shell function to the user's shell config.

## Important notes

- `wt switch` without the shell function only prints the path — it cannot `cd`
- Worktrees share the same `.git` — commits on one branch are visible to all
- `wt merge` defaults to squash merge — the feature branch history collapses into one commit
- Project hooks require one-time approval on first run (security measure)
- The binary is `wt` on macOS/Linux, `git-wt` on Windows
