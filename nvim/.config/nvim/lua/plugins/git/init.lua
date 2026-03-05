local configs = require 'plugins.git.configs'

return {
  {
    'tpope/vim-fugitive',
    config = configs.setup_fugitive,
  },
  {
    'lewis6991/gitsigns.nvim',
    config = configs.setup_gitsigns,
  },
}
