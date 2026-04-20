return {
  'supermaven-inc/supermaven-nvim',
  event = 'VeryLazy',
  opts = function()
    return require('plugins.editor.supermaven.config').opts
  end,
}
