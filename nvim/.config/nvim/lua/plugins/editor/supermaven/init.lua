return {
  'supermaven-inc/supermaven-nvim',
  enabled = false, -- disabled; set to true to re-enable
  event = 'InsertEnter',
  opts = function()
    return require('plugins.editor.supermaven.config').opts
  end,
}
