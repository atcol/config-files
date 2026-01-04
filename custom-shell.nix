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
      desc="${defaultDesc}"
      body="$content"
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

  # Convert Claude MD command to GitHub Copilot CLI agent format
  # Copilot agents are Markdown with YAML frontmatter: name, description, tools
  claudeToCopilotAgent = name: defaultDesc: mdFile: pkgs.runCommand "${name}.md" {
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
      desc="${defaultDesc}"
      body="$content"
    fi

    # Use default if description is empty
    if [ -z "$desc" ]; then
      desc="${defaultDesc}"
    fi

    # Write Copilot agent Markdown with new frontmatter
    cat > $out <<AGENT
---
name: ${name}
description: $desc
tools: ["execute", "read", "edit", "search"]
---
$body
AGENT
  '';

  # GitHub Copilot config for JetBrains IDEs
  copilotXml = ''
    <application>
      <component name="github-copilot">
        <languageAllowList>
          <map>
            <entry key="*" value="true" />
            <entry key="yaml" value="false" />
            <entry key="json" value="false" />
          </map>
        </languageAllowList>
      </component>
    </application>
  '';

  # Current JetBrains IDE versions (update when upgrading)
  jetbrainsConfigs = [
    "IntelliJIdea2025.3"
    "PyCharm2025.3"
    "WebStorm2025.3"
    "RustRover2025.3"
  ];
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

  # VS Code with GitHub Copilot
  programs.vscode = {
    enable = true;

    profiles.default.extensions = with pkgs.vscode-extensions; [
      github.copilot
      github.copilot-chat
      vscodevim.vim
    ];

    userSettings = {
      "github.copilot.enable" = {
        "*" = true;
        "yaml" = false;
        "dotenv" = false;
      };
      "github.copilot.editor.enableCodeActions" = true;
    };
  };

  # JetBrains Copilot config files
  home.file = builtins.listToAttrs (map (ide: {
    name = ".config/JetBrains/${ide}/options/github-copilot.xml";
    value = { text = copilotXml; };
  }) jetbrainsConfigs) // {
    # Gemini CLI commands (generated from Claude command source files)
    ".gemini/commands/commit.toml".source =
      claudeToGemini "commit" "Create git commits for changes made during this session" ./claude/commands/commit.md;
    ".gemini/commands/create-rfc.toml".source =
      claudeToGemini "create-rfc" "Interactive session to write a HashiCorp-style RFC" ./claude/commands/create_rfc.md;
    ".gemini/commands/tdd.toml".source =
      claudeToGemini "tdd" "Test-driven development workflow" ./claude/commands/tdd.md;

    # GitHub Copilot CLI agents (generated from Claude command source files)
    ".copilot/agents/commit.md".source =
      claudeToCopilotAgent "commit" "Create git commits for changes made during this session" ./claude/commands/commit.md;
    ".copilot/agents/create-rfc.md".source =
      claudeToCopilotAgent "create-rfc" "Interactive session to write a HashiCorp-style RFC" ./claude/commands/create_rfc.md;
    ".copilot/agents/tdd.md".source =
      claudeToCopilotAgent "tdd" "Test-driven development workflow" ./claude/commands/tdd.md;
  };
}
