{ config, pkgs, ... }:
let 
  neovim-overlay-commit = "125b7af69ec99e79749877cd820d614f35a64a29";
  imports = [ 
    ./packages.nix
    ./shell.nix
    ./starship.nix
    ./neovim.nix
    ./tmux.nix
  ];
in
{
  inherit imports;

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = "https://github.com/nix-community/neovim-nightly-overlay/archive/${neovim-overlay-commit}.tar.gz";
    }))
  ];

  programs.home-manager.enable = true;
  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "21.05";

  programs.git = {
    enable = true;
  };
}
