local configs = require 'plugins.lsp.configs'

return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'MunifTanjim/prettier.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = configs.setup,
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
  { 'hedyhli/outline.nvim' },
  { 'VidocqH/lsp-lens.nvim' },
}
