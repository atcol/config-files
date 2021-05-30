{ config, pkgs, ... }:
let 
  neovim-overlay-commit = "125b7af69ec99e79749877cd820d614f35a64a29";
  vim-conf = builtins.readFile ./vim/vimrc;
in
{

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = "https://github.com/nix-community/neovim-nightly-overlay/archive/${neovim-overlay-commit}.tar.gz";
    }))
  ];

  programs.home-manager.enable = true;
  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "21.05";

  home.packages = [
    pkgs.htop
    pkgs.watchexec
    pkgs.ripgrep
    pkgs.cargo-watch
    pkgs.cargo-edit
    pkgs.cargo-tarpaulin
    pkgs.cargo-audit
    pkgs.cargo-outdated
    pkgs.cargo-release
    pkgs.cargo-udeps
    pkgs.exa
    pkgs.tokei
    pkgs.bat
    pkgs.fd
    pkgs.terraform
    pkgs.gperftools
    pkgs.wrk
    pkgs.valgrind
    pkgs.xh
    pkgs.zenith
    pkgs.rust-analyzer
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    package = pkgs.neovim-nightly;

    plugins = with pkgs.vimPlugins; [
      vim-airline
      vim-misc
      vim-fugitive
      tagbar
      ctrlp
      vim-gitgutter
      vimproc
      dhall-vim
      vim-nix
      sparkup
      haskell-vim
      ghcmod-vim
      neco-ghc
      vim-stylish-haskell
      rust-vim
      vim-markdown
      fzf-vim # Fuzzy search
      nvim-lspconfig
      lsp_extensions-nvim
      lsp-status-nvim
      completion-nvim
    ];

    extraConfig = vim-conf;
  };

}
