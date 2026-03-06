return {
  'lewis6991/gitsigns.nvim',
  config = function()
    require('plugins.git.gitsigns.config').setup()
  end,
}
