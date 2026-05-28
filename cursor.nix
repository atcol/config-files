{ config, pkgs, lib, ... }:
let
  # Skills exposed as Cursor Rules under ~/.cursor/rules/<name>/
  # Each skill's SKILL.md is converted to <name>.mdc with Cursor frontmatter
  # (description + alwaysApply: false → manual invocation via @<name>).
  # Sibling files in the skill directory are copied verbatim so relative
  # links from the SKILL.md (e.g. ./CONTEXT-FORMAT.md) still resolve.
  skillsToCopy = {
    grill-with-docs = ./ai/skills/grill-with-docs;
  };

  # Convert a Claude-style SKILL.md (YAML frontmatter with name+description)
  # into a Cursor .mdc rule (description + alwaysApply: false).
  skillToCursorRule = name: skillDir: pkgs.runCommand "${name}.mdc" {
    nativeBuildInputs = [ pkgs.gawk ];
  } ''
    src=${skillDir}/SKILL.md

    desc=$(${pkgs.gawk}/bin/awk '
      /^---$/ { count++; next }
      count == 1 && /^description:/ {
        sub(/^description:[[:space:]]*/, "")
        print
        exit
      }
    ' "$src")

    body=$(${pkgs.gawk}/bin/awk '
      /^---$/ { count++; next }
      count >= 2 { print }
    ' "$src")

    {
      echo "---"
      echo "description: $desc"
      echo "alwaysApply: false"
      echo "---"
      echo ""
      echo "$body"
    } > $out
  '';
in
{
  # Copy skill bundles to ~/.cursor/rules/<name>/ and write the rule file.
  # Done via activation (not home.file) so we can drop the whole directory
  # tree from the Nix store and keep referenced files (e.g. ADR-FORMAT.md)
  # alongside the .mdc rule.
  home.activation.copyCursorSkills = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.cursor/rules
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: path: ''
      rm -rf $HOME/.cursor/rules/${name}
      cp -rL ${path} $HOME/.cursor/rules/${name}
      chmod -R u+w $HOME/.cursor/rules/${name}
      cp -L ${skillToCursorRule name path} $HOME/.cursor/rules/${name}/${name}.mdc
      chmod u+w $HOME/.cursor/rules/${name}/${name}.mdc
      rm -f $HOME/.cursor/rules/${name}/SKILL.md
    '') skillsToCopy)}
  '';
}
