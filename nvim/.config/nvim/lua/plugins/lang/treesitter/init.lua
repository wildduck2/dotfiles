return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
  },
  {
    'MeanderingProgrammer/treesitter-modules.nvim',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter', branch = 'main' },
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      require('plugins.lang.treesitter.config').setup()
    end,
  },
}
