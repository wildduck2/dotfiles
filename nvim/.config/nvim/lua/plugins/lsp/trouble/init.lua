return {
  'folke/trouble.nvim',
  cmd = 'Trouble',
  config = function()
    require('plugins.lsp.trouble.config').setup()
  end,
}
