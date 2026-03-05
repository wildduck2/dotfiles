local configs = require 'plugins.trouble.configs'

return {
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    config = configs.setup,
  },
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
}
