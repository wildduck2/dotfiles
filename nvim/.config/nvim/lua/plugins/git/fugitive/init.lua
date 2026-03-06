return {
  'tpope/vim-fugitive',
  cmd = 'Git',
  config = function()
    require('plugins.git.fugitive.config').setup()
  end,
}
