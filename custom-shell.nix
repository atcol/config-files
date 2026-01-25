{ config, pkgs, lib, ... }:
let
  # Shared MCP server definitions (also used by Claude Code)
  mcpServers = import ./mcp-servers.nix;

  # Convert shared MCP servers to Copilot CLI format
  # Copilot uses "type": "local" for stdio servers and requires "tools" field
  copilotMcpServers = lib.mapAttrs (name: server:
    if server ? type && server.type == "sse" then
      # SSE servers pass through as-is with tools
      server // { tools = ["*"]; }
    else
      # Stdio servers need type: "local"
      server // { type = "local"; tools = ["*"]; }
  ) mcpServers;

  # Generate Copilot mcp-config.json content
  copilotMcpConfig = builtins.toJSON { mcpServers = copilotMcpServers; };

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

  # Convert AI command MD to GitHub Copilot CLI agent format (pure Nix, creates real files)
  # Copilot agents are Markdown with YAML frontmatter: name, description, tools
  mkCopilotAgent = name: defaultDesc: mdFile:
    let
      content = builtins.readFile mdFile;
      lines = lib.splitString "\n" content;
      hasFrontmatter = (builtins.head lines) == "---";

      # Parse frontmatter if present
      parsed = if hasFrontmatter then
        let
          # Find second --- index
          restLines = builtins.tail lines;
          findEnd = idx: lines:
            if lines == [] then idx
            else if (builtins.head lines) == "---" then idx
            else findEnd (idx + 1) (builtins.tail lines);
          endIdx = findEnd 0 restLines;
          frontmatterLines = lib.take endIdx restLines;
          bodyLines = lib.drop (endIdx + 1) restLines;

          # Extract description from frontmatter
          descLine = lib.findFirst (l: lib.hasPrefix "description:" l) null frontmatterLines;
          rawDesc = if descLine != null
            then lib.trim (lib.removePrefix "description:" descLine)
            else "";
          # Use default if description is empty or whitespace-only
          desc = if rawDesc == "" then defaultDesc else rawDesc;
        in { inherit desc; body = lib.concatStringsSep "\n" bodyLines; }
      else
        { desc = defaultDesc; body = content; };
    in ''
      ---
      name: ${name}
      description: ${parsed.desc}
      tools: ["execute", "read", "edit", "search"]
      ---
      ${parsed.body}
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
    # Gemini CLI commands (generated from shared AI command sources)
    ".gemini/commands/commit.toml".source =
      claudeToGemini "commit" "Create git commits for changes made during this session" ./ai/commands/commit.md;
    ".gemini/commands/create-rfc.toml".source =
      claudeToGemini "create-rfc" "Interactive session to write a HashiCorp-style RFC" ./ai/commands/create_rfc.md;
    ".gemini/commands/tdd.toml".source =
      claudeToGemini "tdd" "Test-driven development workflow" ./ai/commands/tdd.md;

    # GitHub Copilot CLI agents (generated from shared AI command sources)
    ".copilot/agents/commit.agent.md".text =
      mkCopilotAgent "commit" "Create git commits for changes made during this session" ./ai/commands/commit.md;
    ".copilot/agents/create-rfc.agent.md".text =
      mkCopilotAgent "create-rfc" "Interactive session to write a HashiCorp-style RFC" ./ai/commands/create_rfc.md;
    ".copilot/agents/tdd.agent.md".text =
      mkCopilotAgent "tdd" "Test-driven development workflow" ./ai/commands/tdd.md;

    # GitHub Copilot CLI MCP servers (shared with Claude Code via mcp-servers.nix)
    ".copilot/mcp-config.json".text = copilotMcpConfig;
  };

  # Copy Copilot files to real files (Copilot CLI can't read symlinks)
  home.activation.copyCopilotFiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.copilot/agents

    # Convert symlinked agent files to real files
    for agent in commit create-rfc tdd; do
      src="$HOME/.copilot/agents/$agent.agent.md"
      if [ -L "$src" ]; then
        cp -L "$src" "$src.tmp"
        rm "$src"
        mv "$src.tmp" "$src"
      fi
    done

    # Convert symlinked mcp-config.json to real file
    mcp="$HOME/.copilot/mcp-config.json"
    if [ -L "$mcp" ]; then
      cp -L "$mcp" "$mcp.tmp"
      rm "$mcp"
      mv "$mcp.tmp" "$mcp"
    fi
  '';
}
