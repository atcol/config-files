-- C++ LSP: clangd + cmake-language-server (Neovim 0.11+ native API)
local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.offsetEncoding = { "utf-16" }

vim.lsp.config('clangd', {
  capabilities = capabilities,
})

vim.lsp.config('cmake', {
  capabilities = capabilities,
})

vim.lsp.enable({ 'clangd', 'cmake' })

-- Keybindings scoped to clangd/cmake (avoids overriding rustaceanvim bindings)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or (client.name ~= 'clangd' and client.name ~= 'cmake') then
      return
    end

    local bufnr = args.buf
    local opts = function(desc)
      return { silent = true, buffer = bufnr, desc = desc }
    end

    vim.keymap.set("n", "<F4>", vim.lsp.buf.format, opts("Format"))
    vim.keymap.set("n", "<F5>", vim.lsp.buf.code_action, opts("Code Action"))
    vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts("Rename"))
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Go to Definition"))
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("Go to Implementation"))
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("Find References"))
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover Docs"))

    if client.name == 'clangd' then
      vim.keymap.set("n", "<leader>ch", function()
        local params = { uri = vim.uri_from_bufnr(bufnr) }
        client:request('textDocument/switchSourceHeader', params, function(err, result)
          if result then vim.cmd.edit(vim.uri_to_fname(result)) end
        end, bufnr)
      end, opts("Switch Header/Source"))
    end
  end,
})
