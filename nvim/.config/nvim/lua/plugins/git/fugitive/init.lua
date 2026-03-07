return {
  'tpope/vim-fugitive',
  lazy = false,
  keys = {
    { '<leader>gs', '<cmd>Git<cr>', desc = 'Git status (Fugitive)' },
  },
  config = function()
    require('plugins.git.fugitive.config').setup()
  end,
}
