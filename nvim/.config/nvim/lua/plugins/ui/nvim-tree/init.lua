return {
  'nvim-tree/nvim-tree.lua',
  dependencies = {
    {
      'nvim-tree/nvim-web-devicons',
      opts = require('plugins.ui.nvim-tree.config').devicons_opts,
    },
  },
  cmd = { 'NvimTreeToggle', 'NvimTreeFocus' },
  keys = {
    { '<leader>pv', '<cmd>NvimTreeToggle<CR>', desc = 'Toggle file tree' },
    { '<leader>l', '<cmd>NvimTreeFocus<CR>', desc = 'Focus file tree' },
  },
  init = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.opt.termguicolors = true
  end,
  config = function()
    require('plugins.ui.nvim-tree.config').setup()
  end,
}
