return {
  'vuki656/package-info.nvim',
  event = { 'BufRead package.json' },
  dependencies = 'MunifTanjim/nui.nvim',
  config = function()
    require('plugins.lang.package-info.config').setup()
  end,
}
