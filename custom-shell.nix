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

  programs.vscode = {
    enable = true;

    profiles.default.extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
    ];
  };

  home.file = {
    # Gemini CLI commands (generated from shared AI command sources)
    ".gemini/commands/commit.toml".source =
      claudeToGemini "commit" "Create git commits for changes made during this session" ./ai/commands/commit.md;
    ".gemini/commands/create-rfc.toml".source =
      claudeToGemini "create-rfc" "Interactive session to write a HashiCorp-style RFC" ./ai/commands/create_rfc.md;
    ".gemini/commands/tdd.toml".source =
      claudeToGemini "tdd" "Test-driven development workflow" ./ai/skills/tdd/SKILL.md;
  };
}
