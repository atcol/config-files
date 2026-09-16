local use = require('packer').use
require('packer').startup(function()
  use 'wbthomason/packer.nvim' -- Package manager
  use 'sainnhe/sonokai'
  use 'folke/which-key.nvim'
  -- use 'github/copilot.vim'  -- Disabled: conflicts with rust-analyzer

end)
