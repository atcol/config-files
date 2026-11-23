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
  geminiNativeSkills = mattPocockSkills // {
    inherit (import ./local-skills.nix) socratic-tutor;
  };

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
    # Trim surrounding whitespace. Not `xargs` — it applies shell-style quote
    # parsing, so a description containing an apostrophe (e.g. "a project's
    # domain model") aborts the build with "unmatched single quote".
    desc=$(printf '%s' "$desc" | ${pkgs.gnused}/bin/sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    if [ -z "$desc" ]; then
      desc="${defaultDesc}"
    fi

    # Escape for a TOML basic string: backslashes first, then double quotes.
    # Several descriptions quote their trigger phrases (e.g. "tear apart"),
    # which would otherwise close the string early and emit invalid TOML.
    desc=$(printf '%s' "$desc" | ${pkgs.gnused}/bin/sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')

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
  # Keep supporting references and delegated skills available to Gemini.
  home.activation.copyGeminiNativeSkills = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.gemini/skills
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: path: ''
      rm -rf $HOME/.gemini/skills/${name}
      cp -rL ${path} $HOME/.gemini/skills/${name}
      chmod -R u+w $HOME/.gemini/skills/${name}
    '') geminiNativeSkills)}
  '';

  programs.git = {
    enable = true;
    settings.user = {
      name  = "Alex";
      email = "codeetc@pm.me";
    };
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

  } // lib.mapAttrs' (name: path: lib.nameValuePair
    ".gemini/commands/${name}.toml" {
      source = pkgs.writeText "${name}.toml" ''
        description = "Run the ${name} skill"
        prompt = "Read and follow ~/.gemini/skills/${name}/SKILL.md. Resolve relative references from that skill directory. When a skill asks to call the Skill tool, read and follow the named skill's SKILL.md under ~/.gemini/skills/ instead. User request: {{args}}"
      '';
    }
  ) geminiNativeSkills;
}
