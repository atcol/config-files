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
  home.stateVersion = "23.11";

  programs.git = {
    enable = true;
  };
  programs.fish = {
    enable = true;
    shellInit = ''
      starship init fish | source
      export EDITOR=nvim

      set fish_greeting ""
      fish_add_path --path ~/go/bin
      fish_add_path --path ~/.cargo/bin
      fish_add_path --path ~/.local/bin
      #export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
    '';
    plugins = [
      {
        name = "fzf.fish";
        src = pkgs.fetchFromGitHub { 
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "6d8e962f3ed84e42583cec1ec4861d4f0e6c4eb3";
          sha256 = "0lv2gl9iylllqp9v0wqib3rll2ii1sm2xkjfzlqhybvkhbrdvffj";
        };
      }
    ];
    shellAliases = {
      ls = "exa -G  --color auto --icons -a -s type";
      ll = "exa -l --color always --icons -a -s type";
      cat = "bat -pp --theme=Nord";
    };
  };
}
