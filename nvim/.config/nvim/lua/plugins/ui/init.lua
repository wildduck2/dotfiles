local configs = require 'plugins.ui.configs'

return {
  {
    'nvim-lualine/lualine.nvim',
    config = configs.setup_lualine,
  },
  { 'nvim-tree/nvim-web-devicons' },
  { 'akinsho/toggleterm.nvim', version = '*', opts = { direction = 'tab' } },
  {
    'folke/zen-mode.nvim',
    config = configs.setup_zenmode,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    config = configs.setup_ibl,
  },
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = configs.setup_which_key,
  },
}
