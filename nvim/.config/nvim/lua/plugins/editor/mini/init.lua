return {
  'echasnovski/mini.nvim',
  event = 'BufReadPost',
  config = function()
    require('plugins.editor.mini.config').setup()
  end,
}
