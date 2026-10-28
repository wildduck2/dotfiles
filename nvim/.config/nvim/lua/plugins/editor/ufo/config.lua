local M = {}

function M.setup()
  require('ufo').setup({
    open_fold_hl_timeout = 150,
    close_fold_kinds_for_ft = {},
    provider_selector = function()
      return { 'treesitter', 'indent' }
    end,
  })

  -- native zR/zM rewrite foldlevel, which ufo needs left at 99
  vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
  vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
end

return M
