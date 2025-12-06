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

      # For completion
      nvim-cmp
      cmp-nvim-lsp
      cmp-vsnip
      cmp-path
      cmp-buffer
      cmp-nvim-lsp      # LSP completion
      cmp-buffer        # Buffer words
      cmp-path          # File paths
      cmp-cmdline       # Command line
      
      # Snippet engine (required by nvim-cmp)
      luasnip
      cmp_luasnip
      
      # icons
      lspkind-nvim

      # End completion

      # Utils
      popup-nvim
      plenary-nvim
      telescope-nvim
      FTerm-nvim

      # Package management
      packer-nvim
    ];

    extraConfig = vim-conf;
    extraLuaConfig = lib.concatStringsSep "\n" (map builtins.readFile [./vim/rustaceanvim.lua ./vim/cmp.lua]);
  };
}
