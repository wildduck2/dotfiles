return {
  'folke/which-key.nvim',
  event = 'VimEnter',
  opts = function()
    return require('plugins.ui.which-key.config').opts
  end,
}
