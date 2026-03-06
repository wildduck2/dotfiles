local M = {}

function M.setup()
  -- Fold display settings
  -- '0'=hide, '1'=show fold column (1 char wide)
  vim.o.foldcolumn = '1'
  -- false: start with all folds open
  vim.o.foldenable = false
  -- max nesting depth for folds (99 = effectively all)
  vim.o.foldlevel = 99
  -- foldlevel when opening a buffer (99 = all open)
  vim.o.foldlevelstart = 99
  -- chars for fold markers and diff display
  vim.o.fillchars = [[fold: ,foldopen:-,foldsep:│,diff:⣿]]

  require('ufo').setup {}

  -- Fold keymaps
  vim.keymap.set('n', '<leader>fR', require('ufo').openAllFolds)
  vim.keymap.set('n', '<leader>fM', require('ufo').closeAllFolds)
  -- toggle fold under cursor (open if closed, close if open)
  vim.keymap.set('n', '<leader>fm', function()
    local line = vim.fn.line '.'
    local foldClosed = vim.fn.foldclosed(line)
    if foldClosed == -1 then
      vim.cmd 'normal! zc'
    else
      vim.cmd 'normal! zo'
    end
  end)
end

return M
