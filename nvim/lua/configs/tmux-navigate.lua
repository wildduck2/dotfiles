-- Set g:tmux_navigator_no_mappings to 1
vim.g.tmux_navigator_no_mappings = 1

-- Define the mappings
vim.api.nvim_set_keymap('n', '<silent>{Left-Mapping}', ':<C-U>TmuxNavigateLeft<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<silent>{Down-Mapping}', ':<C-U>TmuxNavigateDown<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<silent>{Up-Mapping}', ':<C-U>TmuxNavigateUp<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<silent>{Right-Mapping}', ':<C-U>TmuxNavigateRight<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<silent>{Previous-Mapping}', ':<C-U>TmuxNavigatePrevious<cr>', { noremap = true })

