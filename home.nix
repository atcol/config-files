{ config, pkgs, ... }:
let 
  # 0.7
  #neovim-overlay-commit = "184a46c1fc32d0b3c1a5aaad26249f1a970e4d3c";

  imports = [ 
    ./packages.nix
    ./custom-shell.nix
    ./starship.nix
    ./neovim.nix
    ./tmux.nix
  ];
in
{
  inherit imports;

  programs.home-manager.enable = true;
  home.username = "atc";
  home.homeDirectory = "/home/atc";
  home.stateVersion = "24.05";

  programs.git = {
    enable = true;
  };
  programs.fish = {
    enable = true;
    shellInit = ''
      starship init fish | source
      export EDITOR=nvim
      eval "$(direnv hook bash)"
    '';
    plugins = [
    ];
    shellAliases = {
      ls = "exa -G  --color auto --icons -a -s type";
      ll = "exa -l --color always --icons -a -s type";
      cat = "bat -pp --theme=Nord";
    };
  };
}
