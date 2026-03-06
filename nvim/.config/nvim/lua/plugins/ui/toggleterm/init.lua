return {
  'akinsho/toggleterm.nvim',
  version = '*',
  opts = function()
    return require('plugins.ui.toggleterm.config').opts
  end,
}
