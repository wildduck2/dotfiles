return {
  'kevinhwang91/nvim-ufo',
  event = 'BufReadPost',
  dependencies = { 'kevinhwang91/promise-async' },
  init = function()
    vim.o.foldcolumn = '1'
    vim.o.foldenable = false
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.fillchars = [[fold: ,foldopen:-,foldsep:│,diff:⣿]]
  end,
  config = function()
    require('plugins.editor.ufo.config').setup()
  end,
}
