{ config, pkgs, lib, ... }:
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

  # Matt Pocock's skills, vendored as a pinned git submodule.
  # See ./matt-pocock-skills.nix.
  mattPocockSkills = import ./matt-pocock-skills.nix;

  # Convert Claude MD command to Gemini TOML format
  # Handles both files with and without YAML frontmatter
  claudeToGemini = name: defaultDesc: mdFile: pkgs.runCommand "${name}.toml" {
    nativeBuildInputs = [ pkgs.gnused pkgs.gawk ];
  } ''
    content=$(cat ${mdFile})

    # Check if file has YAML frontmatter (starts with ---)
    if echo "$content" | head -1 | grep -q '^---$'; then
      # Extract description from frontmatter
      desc=$(echo "$content" | ${pkgs.gawk}/bin/awk '
        /^---$/ { count++; next }
        count == 1 && /^description:/ { gsub(/^description:[[:space:]]*/, ""); print; exit }
      ')
      # Extract body after second ---
      body=$(echo "$content" | ${pkgs.gawk}/bin/awk '
        /^---$/ { count++; next }
        count >= 2 { print }
      ')
    else
      # No frontmatter - use default description, entire file is body
      desc=""
      body="$content"
    fi

    # Use default if description is empty or whitespace-only
    desc=$(echo "$desc" | xargs)  # trim whitespace
    if [ -z "$desc" ]; then
      desc="${defaultDesc}"
    fi

    # Replace $ARGUMENTS with {{args}}
    body=$(echo "$body" | ${pkgs.gnused}/bin/sed 's/\$ARGUMENTS/{{args}}/g')

    # Write TOML output
    cat > $out <<TOML
description = "$desc"
prompt = """
$body
"""
TOML
  '';
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

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };


  home.file = {
    # Gemini CLI commands (generated from shared AI command sources)
    ".gemini/commands/commit.toml".source =
      claudeToGemini "commit" "Create git commits for changes made during this session" ./ai/commands/commit.md;
    ".gemini/commands/create-rfc.toml".source =
      claudeToGemini "create-rfc" "Interactive session to write a HashiCorp-style RFC" ./ai/commands/create_rfc.md;
    ".gemini/commands/tdd.toml".source =
      claudeToGemini "tdd" "Test-driven development workflow" ./ai/skills/tdd/SKILL.md;
    ".gemini/commands/epic-decomposer.toml".source =
      claudeToGemini "epic-decomposer" "Decompose epics into well-structured stories for any project management tool" ./ai/skills/epic-decomposition/SKILL.md;
    ".gemini/commands/adversarial-code-review.toml".source =
      claudeToGemini "adversarial-code-review" "Adversarial code review — blunt, thorough critique of code or PRs" ./ai/skills/adversarial-code-review/SKILL.md;
    ".gemini/commands/adversarial-prd-review.toml".source =
      claudeToGemini "adversarial-prd-review" "Adversarial review of PRDs and product specs" ./ai/skills/adversarial-prd-review/SKILL.md;
    ".gemini/commands/adversarial-rfc-review.toml".source =
      claudeToGemini "adversarial-rfc-review" "Adversarial review of RFCs and technical design documents" ./ai/skills/adversarial-rfc-review/SKILL.md;
    ".gemini/commands/thermo-nuclear-code-quality-review.toml".source =
      claudeToGemini "thermo-nuclear-code-quality-review" "Extremely strict maintainability review for abstraction quality, giant files, and spaghetti-condition growth" ./ai/skills/thermo-nuclear-code-quality-review/SKILL.md;

    # Matt Pocock's skills. Gemini CLI has no Skill tool, so a skill can't
    # delegate to another one the way it does under Claude Code and Codex;
    # every command below has to carry a body Gemini can run on its own.
    #
    # That is why /grill-me points at `grilling` rather than at upstream's
    # `grill-me`, whose entire body is "Call the Skill tool with grilling" and
    # would flatten to a no-op here.
    ".gemini/commands/grill-me.toml".source =
      claudeToGemini "grill-me" "Grill the user relentlessly about a plan, decision, or idea, a round of questions at a time" "${mattPocockSkills.grilling}/SKILL.md";

    # /wayfinder still names the skills it delegates to, so the three it can
    # reach are installed below as commands you invoke by hand at that point.
    # `prototype` is deliberately absent: its SKILL.md is only a router to
    # LOGIC.md and UI.md, which a flattened single-file command can't carry.
    ".gemini/commands/wayfinder.toml".source =
      claudeToGemini "wayfinder" "Plan a large multi-session effort as a shared map of decision tickets on your issue tracker" "${mattPocockSkills.wayfinder}/SKILL.md";
    ".gemini/commands/domain-modeling.toml".source =
      claudeToGemini "domain-modeling" "Build and sharpen a project's domain model, glossary, and ADRs" "${mattPocockSkills.domain-modeling}/SKILL.md";
    ".gemini/commands/research.toml".source =
      claudeToGemini "research" "Investigate a question against primary sources and capture the findings as Markdown" "${mattPocockSkills.research}/SKILL.md";
  };
}
