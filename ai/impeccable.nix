{ config, lib, pkgs, ... }:
let
  cfg = config.ai.impeccable;
  package = pkgs.callPackage ./impeccable/package.nix {};
  roots = {
    claude = ".claude";
    codex = ".agents";
    gemini = ".gemini";
  };
  entries = lib.concatMap (harness: [ {
    destination = "${roots.${harness}}/skills/impeccable";
    source = "${package}/share/impeccable/${harness}/skills/impeccable";
  } ] ++ lib.optionals (harness == "claude") (map (name: {
    destination = ".claude/agents/${name}.md";
    source = "${package}/share/impeccable/claude/agents/${name}.md";
  }) [
    "impeccable-asset-producer"
    "impeccable-documenter"
    "impeccable-finish-reviewer"
    "impeccable-manual-edit-applier"
  ])) cfg.harnesses;
  manifest = pkgs.writeText "impeccable-install.json" (builtins.toJSON {
    home = config.home.homeDirectory;
    entries = if cfg.enable then entries else [];
  });
  installer = "${pkgs.python3}/bin/python ${./impeccable/install.py} ${manifest}";
  projectConfig = pkgs.writeText "impeccable-project.json" (builtins.toJSON {
    home = config.home.homeDirectory;
    bundle = "${package}/share/impeccable";
    harnesses = cfg.harnesses;
  });
  projectSetup = pkgs.writeShellScriptBin "impeccable-project" ''
    exec ${pkgs.python3}/bin/python ${./impeccable/project.py} ${projectConfig} "$@"
  '';
in
{
  options.ai.impeccable = {
    enable = lib.mkEnableOption "Impeccable design skills and engine";
    harnesses = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [ "claude" "codex" "gemini" ]);
      default = [ "claude" "codex" "gemini" ];
      description = "Harnesses receiving native Impeccable skills when enabled.";
    };
  };

  config = {
    home.packages = lib.mkIf cfg.enable [ package projectSetup ];

    # Keep the empty-manifest activation when disabled so prior managed copies
    # are removed. It neither fetches nor installs the Impeccable package.
    home.activation.checkImpeccable = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
      ${installer} --check
    '';
    home.activation.copyImpeccable = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${installer}
    '';
  };
}
