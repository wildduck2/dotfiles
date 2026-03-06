return {
  'folke/lazydev.nvim',
  ft = 'lua',
  opts = function()
    return require('plugins.lsp.lazydev.config').opts
  end,
}
