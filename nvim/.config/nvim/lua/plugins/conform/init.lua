return {
  'stevearc/conform.nvim',
  event = 'BufReadPost',
  config = function()
    require('plugins.conform.config').setup()
  end,
}
