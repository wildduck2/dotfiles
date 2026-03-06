return {
  'nvim-lualine/lualine.nvim',
  config = function()
    require('plugins.ui.lualine.config').setup()
  end,
}
