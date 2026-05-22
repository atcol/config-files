require('claudecode').setup()

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

map('n', '<leader>ac', '<CMD>ClaudeCode<CR>',             'Toggle Claude terminal')
map('n', '<leader>af', '<CMD>ClaudeCodeFocus<CR>',        'Focus Claude window')
map('n', '<leader>ar', '<CMD>ClaudeCode --resume<CR>',    'Resume previous Claude session')
map('n', '<leader>aC', '<CMD>ClaudeCode --continue<CR>',  'Continue current Claude task')
map('n', '<leader>am', '<CMD>ClaudeCodeSelectModel<CR>',  'Select Claude model')
map('n', '<leader>ab', '<CMD>ClaudeCodeAdd %<CR>',        'Add current buffer to Claude context')
map('v', '<leader>as', '<CMD>ClaudeCodeSend<CR>',         'Send selection to Claude')
map('n', '<leader>aa', '<CMD>ClaudeCodeDiffAccept<CR>',   'Accept Claude diff')
map('n', '<leader>ad', '<CMD>ClaudeCodeDiffDeny<CR>',     'Reject Claude diff')
