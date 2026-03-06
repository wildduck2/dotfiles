return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    require('plugins.lsp.lint.config').setup()
  end,
}
