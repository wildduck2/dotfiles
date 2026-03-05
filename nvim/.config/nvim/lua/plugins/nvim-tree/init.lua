local configs = require 'plugins.nvim-tree.configs'

return {
  'nvim-tree/nvim-tree.lua',
  dependencies = {
    {
      'nvim-tree/nvim-web-devicons',
      opts = configs.devicons,
    },
  },
  cmd = { 'NvimTreeToggle', 'NvimTreeFocus' },
  keys = {
    { '<leader>pv', '<cmd>NvimTreeToggle<CR>', desc = 'Toggle file tree' },
    { '<leader>l', '<cmd>NvimTreeFocus<CR>', desc = 'Focus file tree' },
  },
  init = configs.early_setup,
  config = configs.setup,
}
