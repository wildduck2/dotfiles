return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', opts = {} },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    {
      'j-hui/fidget.nvim',
      opts = {
        notification = {
          window = {
            -- Avoid the nvim-tree sidebar so fidget never overlaps it.
            -- Replaces the implicit integration that fidget plans to remove.
            avoid = { 'NvimTree' },
          },
        },
      },
    },
  },
  config = function()
    require('plugins.lsp.lspconfig.config').setup()
  end,
}
