return {
  'kevinhwang91/nvim-ufo',
  event = 'BufReadPost',
  dependencies = { 'kevinhwang91/promise-async' },
  config = function()
    require('plugins.editor.ufo.config').setup()
  end,
}
