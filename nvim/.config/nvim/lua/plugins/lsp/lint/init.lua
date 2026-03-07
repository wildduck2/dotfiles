return {
  'mfussenegger/nvim-lint',
  lazy = false,
  config = function()
    require('plugins.lsp.lint.config').setup()
  end,
}
