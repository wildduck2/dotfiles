return {
  'mfussenegger/nvim-lint',
  event = 'BufReadPost',
  config = function()
    require('plugins.lsp.lint.config').setup()
  end,
}
