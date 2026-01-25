{ config, pkgs, lib, ... }:
let
  # Shared MCP server definitions (also used by Copilot CLI)
  mcpServers = import ./mcp-servers.nix;

  # Skills that need to be copied (not symlinked) for Claude to read assets
  skillsToCopy = {
    generate-smithy = ./ai/skills/generate-smithy;
    api-to-proto    = ./ai/skills/api-to-proto;
    bootstrap-rust  = ./ai/skills/bootstrap-rust;
    tdd             = ./ai/skills/tdd;
  };
in
{
  programs.claude-code.enable = true;

  # Copy skills with assets (Claude can't read symlinked files)
  home.activation.copyClaudeSkills = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.claude/skills
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: path: ''
      rm -rf $HOME/.claude/skills/${name}
      cp -rL ${path} $HOME/.claude/skills/${name}
      chmod -R u+w $HOME/.claude/skills/${name}
    '') skillsToCopy)}
  '';

  programs.claude-code.agents = {
    codebase-analyzer       = ./claude/agents/codebase-analyzer.md;
    codebase-locator        = ./claude/agents/codebase-locator.md;
    codebase-pattern-finder = ./claude/agents/codebase-pattern-finder.md;
    thoughts-analyzer       = ./claude/agents/thoughts-analyzer.md;
    thoughts-locator        = ./claude/agents/thoughts-locator.md;
    web-search-researcher   = ./claude/agents/web-search-researcher.md;
  };

  programs.claude-code.commands = {
    commit             = ./ai/commands/commit.md;
    create-rfc         = ./ai/commands/create_rfc.md;
  };

  # Skills are copied via home.activation.copyClaudeSkills above
  # (Claude can't read symlinked files, so we copy instead)
  programs.claude-code.skills = {};

  programs.claude-code.settings = {
    includeCoAuthoredBy = false;

    # MCP Servers - imported from shared mcp-servers.nix
    inherit mcpServers;

    permissions = {

      allow = [
        "Task"
        "Bash(git diff:*)"
        "Bash(git remote:*)"
        "Bash(git pull:*)"
        "Bash(git checkout:*)"
        "Bash(gh:*)"
        "Bash(pnpm:*)"
        "Bash(npm:*)"
        "Bash(yarn:*)"
        "Bash(bun:*)"
        "Bash(node:*)"
        "Bash(python:*)"
        "Bash(pip:*)"
        "Bash(uv:*)"
        "Bash(poetry:*)"
        "Bash(docker:*)"
        "Bash(cargo build:*)"
        "Bash(cargo test:*)"
        "Bash(curl:*)"
        "Bash(find:*)"
        "Bash(grep:*)"
        "Bash(rg:*)"
        "Bash(ls:*)"
        "Bash(tree:*)"
        "Bash(time:*)"
        "Bash(timeout:*)"
        "Bash(cat:*)"
        "Bash(head:*)"
        "Bash(tail:*)"
        "Bash(cd:*)"
        "Bash(diff:*)"
        "Bash(sed:*)"
        "Bash(cut:*)"
        "Bash(awk:*)"
        "Bash(sort:*)"
        "Bash(uniq:*)"
        "Bash(test:*)"
        "Bash(wc:*)"
        "Bash(which:*)"
        "Bash(where:*)"
        "Bash(whoami)"
        "Bash(pwd)"
        "Bash(echo:*)"
        "Bash(printf:*)"
        "Bash(true)"
        "Bash(nix:*)"
        "Glob"
        "Grep"
        "Read"
        "Edit"
        "Write"
        "TodoWrite"
        "WebFetch"
        "WebSearch"
        "WebFetch(domain:github.com)"
        "WebFetch(domain:api.github.com)"
        "WebFetch(domain:raw.githubusercontent.com)"
        "WebFetch(domain:registry.npmjs.org)"
      ];

    };

  };
}
