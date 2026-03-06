return {
  'vuki656/package-info.nvim',
  dependencies = 'MunifTanjim/nui.nvim',
  config = function()
    require('plugins.lang.package-info.config').setup()
  end,
}
