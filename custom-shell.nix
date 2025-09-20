{ config, pkgs, ... }:
let
  shellAliases = {
    k = "kubectl";
    cat = "bat";
    we = "watchexec";
    find = "fd";
    cloc = "tokei";
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
    commit                    = ./claude/commands/commit.md;
    create_plan_generic       =  ./claude/commands/create_plan_generic.md;
    create_plan               =  ./claude/commands/create_plan.md;
    create_worktree           =  ./claude/commands/create_worktree.md;
    debug                     =  ./claude/commands/debug.md;
    describe_pr               =  ./claude/commands/describe_pr.md;
    implement_plan            =  ./claude/commands/implement_plan.md;
    research_codebase_generic =  ./claude/commands/research_codebase_generic.md;
    research_codebase         =  ./claude/commands/research_codebase.md;
    validate_plan             =  ./claude/commands/validate_plan.md;
  };
}
