# Requires peon-ping passed via extraSpecialArgs:
#   extraSpecialArgs = { inherit (inputs) peon-ping; };
{ config, pkgs, lib, peon-ping, ... }:
{
  imports = [ peon-ping.homeManagerModules.default ];

  programs.peon-ping = {
    enable = true;
    package = peon-ping.packages.${pkgs.system}.default;

    enableBashIntegration = true;
    enableZshIntegration = false;

    settings = {
      default_pack = "peon";
      volume = 0.5;
      enabled = true;
      desktop_notifications = true;
      categories = {
        "session.start" = true;
        "task.complete" = true;
        "task.error" = true;
        "input.required" = true;
        "resource.limit" = true;
        "user.spam" = true;
      };
    };

    installPacks = [ "peon" ];
  };
}
