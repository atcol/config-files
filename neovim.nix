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

    extraFiles = {
        extraFiles = {
          "after/ftplugin/rust.lua" = {
            text = ''
              vim.g.mapleader = "\\"

              local bufnr = vim.api.nvim_get_current_buf()

              -- Code actions (supports rust-analyzer's grouping)
              vim.keymap.set(
                "n", 
                "<F5>", 
                function()
                  vim.cmd.RustLsp('codeAction')
                end,
                { silent = true, buffer = bufnr, desc = "Code Action" }
              )

              -- Hover actions (override K)
              vim.keymap.set(
                "n", 
                "<leader>ca",
                function()
                  vim.cmd.RustLsp({'hover', 'actions'})
                end,
                { silent = true, buffer = bufnr, desc = "Hover Actions" }
              )

              -- Run/Debug
              vim.keymap.set(
                "n",
                "<leader>rr",
                function()
                  vim.cmd.RustLsp('runnables')
                end,
                { silent = true, buffer = bufnr, desc = "Runnables" }
              )

              -- Testing
              vim.keymap.set(
                "n",
                "<leader>rt",
                function()
                  vim.cmd.RustLsp('testables')
                end,
                { silent = true, buffer = bufnr, desc = "Testables" }
              )
            '';
        };

    };
  };
}
