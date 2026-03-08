return {
  'laytan/cloak.nvim',
  event = 'BufReadPost',
  opts = function()
    return require('plugins.editor.cloak.config').opts
  end,
}
