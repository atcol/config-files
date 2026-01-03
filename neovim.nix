{ config, lib, pkgs, ... }:
let
  vim-conf = builtins.readFile ./vim/vimrc;
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      vim-airline
      tagbar
      ctrlp
      vim-gitgutter
      vimproc

      # Languages
      #dhall-vim
      nvim-treesitter
      nvim-treesitter-parsers.smithy
      vim-nix
      haskell-vim
      ghcmod-vim
      neco-ghc
      vim-stylish-haskell
      vim-markdown

      # Fuzzy search
      fzf-vim 

      # Language server
      nvim-lspconfig
      lsp_extensions-nvim
      lsp-status-nvim

      # For completion
      nvim-lspconfig
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      nvim-cmp

      cmp-vsnip
      vim-vsnip
      lspkind-nvim            # icons for LSP completion
      nvim-web-devicons       # actual icon glyphs
      lspkind-nvim

      # End completion

      rustaceanvim

      # Utils
      plenary-nvim    # A buch of utils for Lua
      telescope-nvim  # Fuzzy finder
      FTerm-nvim      # Floating terminal

      # AI
      copilot-vim

      # Package management
      packer-nvim
    ];

    extraConfig = vim-conf;
    extraLuaConfig = lib.concatStringsSep "\n" (map builtins.readFile [
      ./vim/general.lua
      ./vim/cmp.lua
      ./vim/rustaceanvim.lua
      ./vim/packer.lua
    ]);
  };
}
