local configs = require 'plugins.lint.configs'

return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = configs.setup,
}
