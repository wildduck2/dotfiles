local configs = require 'plugins.treesitter.configs'

return {
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/playground',
    },
    config = configs.setup,
  },
  {
    'windwp/nvim-ts-autotag',
    config = configs.setup_autotag,
  },
}
