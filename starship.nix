{ config, lib, pkgs, ... }:
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    # Configuration written to ~/.config/starship.toml
    settings = {
      # add_newline = false;

      # character = {
      #   success_symbol = "[➜](bold green)";
      #   error_symbol = "[➜](bold red)";
      # };
      aws = {
        disabled = true;
      };

      memory_usage = {
        disabled = false;
        threshold = -1;
      };

      kubernetes = {
        disabled = false;
      };

      # package.disabled = true;
    };
  };
}

