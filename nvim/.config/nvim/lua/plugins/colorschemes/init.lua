local configs = require 'plugins.colorschemes.configs'

return {
  { 'tjdevries/colorbuddy.nvim', priority = 1001, config = configs.colorbuddy },
  { 'tjdevries/gruvbuddy.nvim' },
  { 'catppuccin/nvim', priority = 1000 },
  { 'folke/tokyonight.nvim', lazy = false, priority = 1000, opts = {} },
  { 'rose-pine/neovim', name = 'rose-pine' },
  { 'navarasu/onedark.nvim', name = 'onedark' },
  { 'rebelot/kanagawa.nvim', name = 'kanagawa' },
  { 'xiyaowong/transparent.nvim', config = configs.transparent },
}
