local M = {}

function M.setup()
  require('ufo').setup {
    open_fold_hl_timeout = 150,
    close_fold_kinds_for_ft = {},
    provider_selector = function()
      return { 'treesitter', 'indent' }
    end,
  }

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
