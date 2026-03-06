return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    {
      'L3MON4D3/LuaSnip',
      build = (function()
        if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
          return
        end
        return 'make install_jsregexp'
      end)(),
      config = function()
        local ls = require 'luasnip'
        require('luasnip.loaders.from_vscode').lazy_load()
        pcall(require, 'plugins.cmp.snippets')

        vim.keymap.set({ 'i', 's' }, '<C-k>', function()
          ls.expand_or_jump()
        end, { noremap = true, silent = true })
      end,
    },
    { 'neovim/nvim-lspconfig' },
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-cmdline' },
    { 'saadparwaiz1/cmp_luasnip' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-nvim-lua' },
    { 'rafamadriz/friendly-snippets' },
  },
  config = function()
    require('plugins.cmp.config').setup()
  end,
}
