local configs = require 'plugins.conform.configs'

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  config = configs.setup,
}
