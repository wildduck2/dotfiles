return {
  'nvim-tree/nvim-tree.lua',
  dependencies = {
    {
      'nvim-tree/nvim-web-devicons',
      opts = function()
        return require('plugins.ui.nvim-tree.config').devicons_opts
      end,
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
    -- termguicolors already set in wild-duck/set.lua
  end,
  config = function()
    require('plugins.ui.nvim-tree.config').setup()
  end,
}
