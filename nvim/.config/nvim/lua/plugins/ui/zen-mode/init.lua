return {
  'folke/zen-mode.nvim',
  config = function()
    require('plugins.ui.zen-mode.config').setup()
  end,
}
