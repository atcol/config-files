-- -- Setup nvim-cmp
local cmp = require'cmp'

-- Enable debug logging
--vim.lsp.set_log_level("debug")

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Add tab support
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  }),

  -- Installed sources
  sources = cmp.config.sources({
    { name = 'nvim_lsp', priority = 1000 },
    { name = 'vsnip', priority = 100 },
  }, {
    { name = 'path', priority = 50 },
    { name = 'buffer', priority = 50 },
  }),
})
