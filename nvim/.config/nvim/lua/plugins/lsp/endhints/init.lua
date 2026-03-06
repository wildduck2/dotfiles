return {
  'chrisgrieser/nvim-lsp-endhints',
  event = 'LspAttach',
  opts = function()
    return require('plugins.lsp.endhints.config').opts
  end,
}
