require('FTerm').setup({
    border = 'double',
    dimensions  = {
        height = 0.9,
        width = 0.9,
    },
})

-- Example keybindings
vim.keymap.set('n', '<F1>', '<CMD>lua require("FTerm").toggle()<CR>')
