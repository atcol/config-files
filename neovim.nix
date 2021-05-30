{ config, lib, pkgs, ... }:
let
  vim-conf = builtins.readFile ./vim/vimrc;
in
{
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
