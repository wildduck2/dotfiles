local configs = require 'plugins.utils.configs'

return {
  { 'nvim-lua/plenary.nvim' },
  {
    'mbbill/undotree',
    config = configs.setup_undotree,
  },
  {
    'christoomey/vim-tmux-navigator',
    lazy = false,
    config = configs.setup_tmux,
  },
  {
    'echasnovski/mini.nvim',
    config = configs.setup_mini,
  },
  { 'kevinhwang91/promise-async' },
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    config = configs.setup_ufo,
  },
  {
    'michaelrommel/nvim-silicon',
    lazy = true,
    cmd = 'Silicon',
  },
}
