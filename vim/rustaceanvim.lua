-- Set leader key first if not already set
vim.g.mapleader = "\\"

vim.g.rustaceanvim = {
  server = {
    on_attach = function(client, bufnr)

      -- Code actions (supports rust-analyzer's grouping)

      vim.keymap.set(
        "n",
        "<F4>",
        function()
          vim.cmd.RustFmt
        end,
        { silent = true, buffer = bufnr, desc = "Rust format" }
      )

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
    end,
  },
}
