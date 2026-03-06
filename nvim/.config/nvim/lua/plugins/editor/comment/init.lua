return {
  'terrortylor/nvim-comment',
  event = 'BufReadPost',
  dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
  config = function()
    require('plugins.editor.comment.config').setup()
  end,
}
