{ config, lib, pkgs, ... }:
let
  vim-conf = builtins.readFile ./vim/vimrc;
  unstable = import <unstable> {};
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    #package = unstable.neovim-unwrapped;

    plugins = with pkgs.vimPlugins; [
      vim-airline
      tagbar
      ctrlp
      vim-gitgutter
      vimproc

      # Languages
      #dhall-vim
      vim-nix
      haskell-vim
      ghcmod-vim
      neco-ghc
      vim-stylish-haskell
      #rust-tools-nvim
      #rust-vim
      vim-markdown
      rustaceanvim

      # Fuzzy search
      fzf-vim 

      # Language server
      nvim-lspconfig
      #luasnip
      #lsp_extensions-nvim
      lsp-status-nvim
      nvim-cmp
      cmp-nvim-lsp
      cmp-vsnip
      cmp-path
      cmp-buffer

      # Utils
      popup-nvim
      plenary-nvim
      telescope-nvim
      FTerm-nvim

      # Package management
      packer-nvim
    ];

    extraConfig = vim-conf;
    extraLuaConfig = builtins.readFile ./vim/rustaceanvim.lua;
  };
}
