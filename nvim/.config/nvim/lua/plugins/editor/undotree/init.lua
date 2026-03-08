return {
  'mbbill/undotree',
  lazy = false,
  config = function()
    vim.keymap.set('n', '<leader>u', '<cmd>UndotreeToggle<cr>', { desc = 'Toggle undo tree' })
  end,
}
