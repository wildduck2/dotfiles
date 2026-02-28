vim.o.foldcolumn = '1' -- '0' is not bad
vim.o.foldenable = false -- disable folding by default
vim.o.foldlevel = 99 -- not strictly necessary
vim.o.foldlevelstart = 99 -- prevents auto folding on buffer load
vim.o.fillchars = [[fold: ,foldopen:-,foldsep:│,diff:⣿]]

require('ufo').setup {
  -- open_fold_hl_timeout = 150,
  -- close_fold_kinds_for_ft = {
  --   default = { 'imports', 'comment' },
  -- },
  -- close_fold_current_line_for_ft = {
  --   default = true,
  -- },
  -- preview = {
  --   win_config = {
  --     border = { '', '─', '', '', '', '─', '', '' },
  --     winhighlight = 'Normal:Folded',
  --     winblend = 0,
  --   },
  --   mappings = {
  --     scrollU = '<C-u>',
  --     scrollD = '<C-d>',
  --     jumpTop = '[',
  --     jumpBot = ']',
  --   },
  -- },

  -- provider_selector = function(bufnr, filetype, buftype)
  --   return { 'treesitter', 'indent' }
  -- end,
  -- provider_selector = function(bufnr, filetype, buftype)
  --   -- if you prefer treesitter provider rather than lsp,
  --   -- return ftMap[filetype] or {'treesitter', 'indent'}
  --   return ftMap[filetype]
  --
  --   -- refer to ./doc/example.lua for detail
  -- end,
}
vim.keymap.set('n', '<leader>fR', require('ufo').openAllFolds)
vim.keymap.set('n', '<leader>fM', require('ufo').closeAllFolds)

vim.keymap.set('n', '<leader>fm', function()
  local line = vim.fn.line '.'
  local foldClosed = vim.fn.foldclosed(line) -- -1 if open

  if foldClosed == -1 then
    -- fold is open, close the fold under cursor
    vim.cmd 'normal! zc'
  else
    -- fold is closed, open the fold under cursor
    vim.cmd 'normal! zo'
  end
end)
