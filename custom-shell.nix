{ config, pkgs, ... }:
let
  shellAliases = {
    k = "kubectl";
    cat = "bat";
    we = "watchexec";
    find = "fd";
    cloc = "tokei";
    gst = "git status";
    gpu = "git pull --rebase";
    gpus = "git push";
    gpusu = "git push --set-upstream origin ";
    gcom = "git commit ";
  };
in
{
  programs.git = {
    enable = true;
    userName  = "Alex";
    userEmail = "codeetc@pm.me";
  };

  programs.bash = {
    inherit shellAliases;
    enable = true;

    initExtra = ''
      eval "$(starship init bash)"
      set -o vi
    '';
  };

  programs.claude-code.enable = true;

  programs.claude-code.agents = {
    codebase-analyzer       = ./claude/agents/codebase-analyzer.md;
    codebase-locator        = ./claude/agents/codebase-locator.md;
    codebase-pattern-finder = ./claude/agents/codebase-pattern-finder.md;
    thoughts-analyzer       = ./claude/agents/thoughts-analyzer.md;
    thoughts-locator        = ./claude/agents/thoughts-locator.md;
    web-search-researcher   = ./claude/agents/web-search-researcher.md;
  };

  programs.claude-code.commands = {
    commit             = ./claude/commands/commit.md;
    create-rfc         = ./claude/commands/create_rfc.md;
    tdd                = ./claude/commands/tdd.md;
  };

  programs.claude-code.skills = {
    generate-smithy   = ./claude/skills/generate-smithy;
  };

  programs.claude-code.settings = {
    includeCoAuthoredBy = false;

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
        "Bash(git diff:*)"
        "Edit"
      ];

    };

  };
}
