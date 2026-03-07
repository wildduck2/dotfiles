return {
  'laytan/cloak.nvim',
  lazy = false,
  opts = function()
    return require('plugins.editor.cloak.config').opts
  end,
}
