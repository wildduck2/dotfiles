return {
  'tpope/vim-fugitive',
  config = function()
    require('plugins.git.fugitive.config').setup()
  end,
}
