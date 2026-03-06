return {
  'folke/zen-mode.nvim',
  keys = {
    { '<leader>zz', desc = 'Zen mode (with line numbers)' },
    { '<leader>zZ', desc = 'Zen mode (minimal)' },
  },
  config = function()
    require('plugins.ui.zen-mode.config').setup()
  end,
}
