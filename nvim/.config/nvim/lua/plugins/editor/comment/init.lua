return {
  'terrortylor/nvim-comment',
  lazy = false,
  dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
  config = function()
    require('plugins.editor.comment.config').setup()
  end,
}
