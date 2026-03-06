return {
  'folke/tokyonight.nvim',
  lazy = false,
  priority = 1000,
  opts = require('plugins.colorscheme.tokyonight.config').opts,
  config = function(_, opts)
    require('plugins.colorscheme.tokyonight.config').setup(_, opts)
  end,
}
