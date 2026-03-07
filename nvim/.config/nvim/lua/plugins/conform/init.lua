return {
  'stevearc/conform.nvim',
  lazy = false,
  config = function()
    require('plugins.conform.config').setup()
  end,
}
