-- Set g:tmux_navigator_no_mappings to 1
vim.g.tmux_navigator_no_mappings = 1

-- Define the mappings
vim.api.nvim_set_keymap('n', '<S-h>', ':<C-U>TmuxNavigateLeft<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-j>', ':<C-U>TmuxNavigateDown<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-k>', ':<C-U>TmuxNavigateUp<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-l>', ':<C-U>TmuxNavigateRight<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-p>', ':<C-U>TmuxNavigatePrevious<cr>', { noremap = true, silent = true })

