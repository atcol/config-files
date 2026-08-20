# config-files

Various configuration files for tools & platforms I use.

## Cloning

This repo has a git submodule ([`mattpocock/skills`](https://github.com/mattpocock/skills)),
so clone it with:

```bash
git clone --recurse-submodules https://github.com/atcol/config-files
```

In an existing checkout: `git submodule update --init`. The Nix expressions
reference the submodule by path, so `home-manager switch` fails to evaluate if
it hasn't been checked out.

## AI tooling

Four AI tools are configured here, sharing one set of source files under `ai/`:

| Tool | Configured in | Gets |
| --- | --- | --- |
| **Claude Code** | `claude-code.nix` | skills, agents, commands, MCP servers, permissions |
| **Codex CLI** | `codex.nix` | skills, agents, commands, MCP servers |
| **Gemini CLI** | `custom-shell.nix` | commands (skills converted to Gemini's TOML format) |
| **Neovim** | `neovim.nix` | `claudecode-nvim`, driving Claude Code from the editor |

MCP servers (GitHub, Linear, Slack, Supabase, Kraken) are defined once in
`mcp-servers.nix` and translated per tool — JSON into `~/.claude.json`, TOML
into `~/.codex/config.toml`.

Skills are **copied** rather than symlinked into `~/.claude/skills` and
`~/.codex/skills`, because Claude can't read through symlinks to a skill's
asset files.

### Matt Pocock's skills

[`mattpocock/skills`](https://github.com/mattpocock/skills) (MIT) is pinned as a
submodule at `ai/vendor/matt-pocock-skills`, and the subset we install is listed
in `matt-pocock-skills.nix`. Vendoring the upstream repo rather than copying the
prompts in means his fixes arrive with a pin bump instead of a manual re-copy.

Two entry points, both user-invoked only (upstream marks them
`disable-model-invocation`, so they run when you ask for them and never
because the model felt like it):

- **`/grill-me`** — a relentless interview that walks the design tree of a plan
  a round of questions at a time, each with a recommended answer, until nothing
  is left silently assumed. Facts it can look up itself, it looks up.
- **`/wayfinder`** — for work too big to fit in one agent session. Charts the
  effort as a map issue on your tracker (labelled `wayfinder:map`) with child
  *decision* tickets, then resolves them one per session until the route to the
  destination is clear. It plans; it doesn't build.

The rest of the installed set exists because those two delegate to it at
runtime — `grilling` (the interview primitive behind `grill-me`),
`domain-modeling`, `research`, and `prototype`. Installing an entry point
without its delegates leaves it half-broken.

`setup-matt-pocock-skills` is also installed. It's not a dependency, but
`/wayfinder` reads a per-repo `docs/agents/issue-tracker.md` that only this
skill knows how to scaffold.

#### Usage

Run once per repo you want to use `/wayfinder` in, to tell it where issues live
(GitHub, GitLab, or local markdown under `.scratch/`):

```
/setup-matt-pocock-skills
```

Then, in Claude Code or Codex:

```
/grill-me            # stress-test a plan in one session
/wayfinder           # chart a multi-session effort as a map
/wayfinder <map-url> # work the next ticket on an existing map
```

Never resolve more than one `/wayfinder` ticket per session — the map is the
memory, the session isn't.

**Gemini CLI** has no Skill tool, so skills can't delegate to each other there.
Every command has to be self-contained, which changes two things:

- `/grill-me` is generated from the **`grilling`** body, not from upstream's
  `grill-me` — the latter is one line (`Call the Skill tool with "grilling"`)
  and would flatten to a no-op.
- `/wayfinder` still names the skills it hands off to, so `/domain-modeling` and
  `/research` are installed as commands to invoke by hand at that point.
  `prototype` is not: its `SKILL.md` is only a router to `LOGIC.md` and `UI.md`,
  which a single flattened file can't carry. Use Claude Code or Codex for that.

#### Updating

```bash
git submodule update --remote ai/vendor/matt-pocock-skills
git commit -am "chore: bump matt-pocock-skills"
```

Upstream reorganises skills between releases, so check that the paths in
`matt-pocock-skills.nix` still resolve after a bump — CI does verify this.
