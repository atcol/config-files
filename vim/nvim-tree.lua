-- Disable netrw before nvim-tree loads (recommended by upstream).
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('nvim-tree').setup({
  view = {
    width = 35,
    side = 'right',
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
  },
})

vim.keymap.set('n', '<C-n>', '<CMD>NvimTreeToggle<CR>', { desc = 'Toggle nvim-tree' })
vim.keymap.set('n', '<leader>e', '<CMD>NvimTreeFocus<CR>', { desc = 'Focus nvim-tree' })
