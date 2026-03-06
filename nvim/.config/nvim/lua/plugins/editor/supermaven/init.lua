return {
  'supermaven-inc/supermaven-nvim',
  event = 'InsertEnter',
  opts = function()
    return require('plugins.editor.supermaven.config').opts
  end,
}
