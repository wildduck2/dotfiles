return {
  'christoomey/vim-tmux-navigator',
  lazy = false,
  config = function()
    require('plugins.navigation.vim-tmux-navigator.config').setup()
  end,
}
