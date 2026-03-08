return {
  'tpope/vim-fugitive',
  lazy = false,
  config = function()
    vim.keymap.set('n', '<leader>gs', '<cmd>Git<cr>', { desc = 'Git status (Fugitive)' })
    require('plugins.git.fugitive.config').setup()
  end,
}
