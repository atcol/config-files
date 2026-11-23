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
| **Gemini CLI** | `custom-shell.nix` | native Matt Pocock skills and TOML commands |
| **Neovim** | `neovim.nix` | `claudecode-nvim`, driving Claude Code from the editor |

MCP servers (GitHub, Linear, Slack, Supabase, Kraken) are defined once in
`mcp-servers.nix` and translated per tool — JSON into `~/.claude.json`, TOML
into `~/.codex/config.toml`.

Skills are **copied** rather than symlinked into `~/.claude/skills` and
`~/.codex/skills`, because Claude can't read through symlinks to a skill's
asset files.

### Impeccable

`ai/impeccable.nix` (also exported as `homeManagerModules.impeccable`) provides optional [Impeccable](https://github.com/pbakaus/impeccable)
design skills. The module defaults to **off**. Enable it in the consuming home
configuration with:

```nix
ai.impeccable = {
  enable = true;
  harnesses = [ "claude" "codex" "gemini" ]; # these are the defaults
};
```

The `ai.impeccable.enable = true;` line in this checkout's `home.nix` is a local
opt-in; leave that line out when committing the shared integration.

On activation, complete native bundles are copied to `~/.claude/skills/impeccable`,
`~/.agents/skills/impeccable` (Codex), and `~/.gemini/skills/impeccable`. Claude's
companion agents are installed too. Gemini uses native skills here, not the
Markdown-to-TOML command converter; use a Gemini CLI with native skill support.
Neovim's Claude integration uses the same Claude installation.

The source revision is pinned in `flake.lock`; the package reads that pin even
when `home.nix` is imported without flake inputs. Upstream's committed provider
bundles are used directly. The matching engine is fetched with a fixed hash,
and the launchers execute it from the Nix store without downloading at runtime.
Use Home Manager to update these files, rather than `impeccable install/update`.

Restart your harness after activation. In Claude, try `/impeccable init`; in
Codex, select `$impeccable`; in Gemini, check `/skills list`. The terminal also
gets `impeccable`, for example `impeccable detect src`.

Project hooks are optional and never installed by activation. From a project:

```bash
impeccable-project                    # register hooks for the selected harnesses
impeccable hooks on                   # enable checks and record local consent
impeccable-project --harness claude   # or register just one harness
impeccable-project --remove           # remove only this helper's hooks
```

The helper preserves unrelated settings and hooks, saves existing settings as
`*.pre-impeccable`, and refuses to overwrite another Impeccable hook install.
Review the generated project settings before committing: their commands point
at your home directory, so they are local configuration. Complete any hook trust
prompt in the harness. Product/design context remains specific to each project.

Disabling the module or removing a harness removes only the skill/agent paths
recorded in `~/.local/state/nix-impeccable/installed.json`. An existing unmanaged
installation must be moved aside before activation. Project hooks left behind
become no-ops when their global launcher is removed.

To update, run `nix flake update impeccable`, then check the pinned source's
`ENGINE_VERSION` and provider layout. Update the engine version, release hashes,
and skill package version in `ai/impeccable/package.nix` together; the package
checks the engine version during installation. Apply with your normal manual
Home Manager workflow.

The skills written in this repo live under `ai/skills/`, and the set to install
is listed once in `local-skills.nix`, which both `claude-code.nix` and
`codex.nix` import. Adding a skill means adding the directory and one line
there — CI fails if the two tools end up with different sets.

### Matt Pocock's skills

[`mattpocock/skills`](https://github.com/mattpocock/skills) (MIT) is pinned as a
submodule at `ai/vendor/matt-pocock-skills`, and the subset we install is listed
in `matt-pocock-skills.nix`. Vendoring the upstream repo rather than copying the
prompts in means his fixes arrive with a pin bump instead of a manual re-copy.

Four entry points, all user-invoked only (upstream marks them
`disable-model-invocation`, so they run when you ask for them and never
because the model felt like it):

- **`/grill-me`** — a relentless interview that walks the design tree of a plan
  a round of questions at a time, each with a recommended answer, until nothing
  is left silently assumed. Facts it can look up itself, it looks up.
- **`/grill-with-docs`** — the interview plus domain modeling, recording glossary
  entries and ADRs as decisions emerge.
- **`/retro`** — review a coding session and suggest improvements to the agent
  environment, using the `writing-for-agents` style guide.
- **`/wayfinder`** — for work too big to fit in one agent session. Charts the
  effort as a map issue on your tracker (labelled `wayfinder:map`) with child
  *decision* tickets, then resolves them one per session until the route to the
  destination is clear. It plans; it doesn't build.

The rest of the installed set exists because the entry points delegate to it at
runtime — `grilling` (the interview primitive behind `grill-me`),
`domain-modeling`, `research`, `prototype`, and `writing-for-agents`. Installing
an entry point without its delegates leaves it half-broken.

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
/grill-with-docs     # stress-test a plan and capture glossary entries and ADRs
/retro               # review a coding session for environment improvements
/grill-me            # stress-test a plan in one session
/wayfinder           # chart a multi-session effort as a map
/wayfinder <map-url> # work the next ticket on an existing map
```

Never resolve more than one `/wayfinder` ticket per session — the map is the
memory, the session isn't.

**Gemini CLI** installs the same complete Matt Pocock skill directories under
`~/.gemini/skills/`, including supporting references and runtime dependencies.
Matching TOML slash commands load each installed `SKILL.md` and tell Gemini how
to follow named skill dependencies. This includes `/grill-with-docs`, `/retro`,
`/prototype`, and `/setup-matt-pocock-skills` as well as the existing commands.

#### Updating

```bash
git submodule update --remote ai/vendor/matt-pocock-skills
git commit -am "chore: bump matt-pocock-skills"
```

Upstream reorganises skills between releases, so check that the paths in
`matt-pocock-skills.nix` still resolve after a bump — CI does verify this.

### Jane Street's Socratic tutor

[`janestreet/agent_skills`](https://github.com/janestreet/agent_skills) (MIT) is
pinned at `ai/vendor/jane-street-agent-skills`. `local-skills.nix` registers
`socratic-tutor` for Claude and Codex; Gemini installs the same complete skill
and exposes `/socratic-tutor` as a command. Ask it to “teach me” or “quiz me” on
a topic to start a structured tutoring session.

Update the pin with:

```bash
git submodule update --remote ai/vendor/jane-street-agent-skills
```

Then commit the submodule pointer and apply your Home Manager configuration.
