return {
  'stevearc/conform.nvim',
  event = { 'BufWritePost' },
  cmd = { 'ConformInfo' },
  config = function()
    require('plugins.conform.config').setup()
  end,
}
