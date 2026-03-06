return {
  'lewis6991/gitsigns.nvim',
  event = 'BufReadPre',
  config = function()
    require('plugins.git.gitsigns.config').setup()
  end,
}
