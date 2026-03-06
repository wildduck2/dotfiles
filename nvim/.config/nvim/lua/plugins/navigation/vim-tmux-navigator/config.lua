local M = {}

function M.setup()
  -- 1=disable default mappings; 0=use defaults (C-hjkl)
  vim.g.tmux_navigator_no_mappings = 1

  -- Custom Shift-based pane navigation (vim + tmux)
  -- <C-U> clears any count prefix before running cmd
  vim.keymap.set('n', '<S-h>', ':<C-U>TmuxNavigateLeft<cr>', { noremap = true, silent = true })
  vim.keymap.set('n', '<S-j>', ':<C-U>TmuxNavigateDown<cr>', { noremap = true, silent = true })
  vim.keymap.set('n', '<S-k>', ':<C-U>TmuxNavigateUp<cr>', { noremap = true, silent = true })
  vim.keymap.set('n', '<S-l>', ':<C-U>TmuxNavigateRight<cr>', { noremap = true, silent = true })
  -- Jump to previously focused pane
  vim.keymap.set('n', '<S-p>', ':<C-U>TmuxNavigatePrevious<cr>', { noremap = true, silent = true })
end

return M
