{ config, pkgs, ... }:
let 
  # 0.7
  neovim-overlay-commit = "184a46c1fc32d0b3c1a5aaad26249f1a970e4d3c";

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

  #nixpkgs.overlays = [
  #  (import (builtins.fetchTarball {
  #    url = "https://github.com/nix-community/neovim-nightly-overlay/archive/${neovim-overlay-commit}.tar.gz";
  #  }))
  #];

  programs.home-manager.enable = true;
  home.username = "atc";
  home.homeDirectory = "/home/atc";
  home.stateVersion = "21.05";

  programs.git = {
    enable = true;
  };
}
