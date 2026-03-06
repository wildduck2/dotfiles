return {
  'tpope/vim-fugitive',
  cmd = 'Git',
  keys = {
    { '<leader>gs', '<cmd>Git<cr>', desc = 'Git status (Fugitive)' },
  },
  config = function()
    require('plugins.git.fugitive.config').setup()
  end,
}
