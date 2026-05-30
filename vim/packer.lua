local use = require('packer').use
require('packer').startup(function()
  use 'wbthomason/packer.nvim' -- Package manager
  use 'sainnhe/sonokai'
  -- use 'github/copilot.vim'  -- Disabled: conflicts with rust-analyzer

end)
