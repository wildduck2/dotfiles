return {
  'christoomey/vim-tmux-navigator',
  event = 'VeryLazy',
  config = function()
    require('plugins.navigation.vim-tmux-navigator.config').setup()
  end,
}
