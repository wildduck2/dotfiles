local configs = require 'plugins.harpoon.configs'

return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = configs.setup,
}
