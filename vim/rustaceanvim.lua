-- Configure rustaceanvim
-- Set leader key first if not already set
vim.g.mapleader = "\\"

local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.offsetEncoding = { "utf-16" }

vim.g.rustaceanvim = {
  server = {
    capabilities = capabilities,
    settings = {
      ['rust-analyzer'] = {
        completion = {
          postfix = {
            enable = false
          }
        }
      }
    },
    on_attach = function(client, bufnr)
      -- vim.g.rustaceanvim.tools.code_actions.ui_select_fallback = true

      -- Code actions (supports rust-analyzer's grouping)

      vim.keymap.set(
        "n",
        "<F4>",
        function()
          vim.cmd.RustFmt()
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

      -- Explain error
      vim.keymap.set(
        "n",
        "<leader>re",
        function()
          vim.cmd.RustLsp('explainError')
        end,
        { silent = true, buffer = bufnr, desc = "Explain Error" }
      )

      -- Quick documentation (Ctrl+Q in IntelliJ)
      vim.keymap.set("n", "K", function()
        vim.cmd.RustLsp({'hover', 'actions'})
      end, { silent = true, buffer = bufnr, desc = "Hover Actions" })

      -- Rename (Shift+F6 in IntelliJ)
      vim.keymap.set("n", "<F2>", function()
        vim.lsp.buf.rename()
      end, { silent = true, buffer = bufnr, desc = "Rename" })

      -- Go to definition (Ctrl+B in IntelliJ)
      vim.keymap.set("n", "gd", function()
        vim.lsp.buf.definition()
      end, { silent = true, buffer = bufnr, desc = "Go to Definition" })

      -- Go to implementation (Ctrl+Alt+B in IntelliJ)
      vim.keymap.set("n", "gi", function()
        vim.lsp.buf.implementation()
      end, { silent = true, buffer = bufnr, desc = "Go to Implementation" })

      -- Find usages (Alt+F7 in IntelliJ)
      vim.keymap.set("n", "gr", function()
        vim.lsp.buf.references()
      end, { silent = true, buffer = bufnr, desc = "Find References" })
    end,
  },
}
