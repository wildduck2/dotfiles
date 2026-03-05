local configs = require 'plugins.editing.configs'

return {
  {
    'terrortylor/nvim-comment',
    lazy = false,
    dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
    config = configs.setup_comment,
  },
  {
    'ThePrimeagen/refactoring.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'laytan/cloak.nvim',
    config = configs.setup_cloak,
  },
}
