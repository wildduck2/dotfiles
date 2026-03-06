return {
  'folke/snacks.nvim',
  opts = function()
    return require('plugins.ui.snacks.config').opts
  end,
}
