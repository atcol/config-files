{ config, pkgs, ... }:
let 

  imports = [
    ./packages.nix
    ./custom-shell.nix
    ./claude-code.nix
    ./codex.nix
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
