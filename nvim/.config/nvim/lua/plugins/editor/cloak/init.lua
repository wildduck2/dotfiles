return {
  'laytan/cloak.nvim',
  event = 'BufReadPre',
  opts = function()
    return require('plugins.editor.cloak.config').opts
  end,
}
