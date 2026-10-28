return {
  'kevinhwang91/nvim-ufo',
  event = 'BufReadPost',
  dependencies = { 'kevinhwang91/promise-async' },
  init = function()
    vim.o.foldcolumn = '1'
    -- ufo builds no folds while foldenable is off; foldlevel 99 keeps files open
    vim.o.foldenable = true
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.fillchars = [[fold: ,foldopen:-,foldsep:│,diff:⣿]]
  end,
  config = function()
    require('plugins.editor.ufo.config').setup()
  end,
}
