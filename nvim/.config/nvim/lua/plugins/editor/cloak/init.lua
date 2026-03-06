return {
  'laytan/cloak.nvim',
  event = 'BufReadPre',
  opts = require('plugins.editor.cloak.config').opts,
}
