-- NvimTree keymap
vim.keymap.set("n", "<leader>pv", vim.cmd.NvimTreeToggle)
vim.keymap.set("n", "<leader>l", vim.cmd.NvimTreeFocus)
vim.api.nvim_set_keymap('n', '<leader>tn', ':tabnew<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>to', ':tabonly<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>tc', ':tabclose<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>tm', ':tabmove ', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>t.', ':tabnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>t,', ':tabprev<CR>', { noremap = true, silent = true })
--
-- if you face line under the file name in the nvim-tree
vim.cmd([[
    :hi SpellCap cterm=NONE gui=NONE guisp=NONE
    :hi      NvimTreeSpecialFile guifg=#ff80ff gui=underline
    :hi      NvimTreeSymlink     guifg=Yellow  gui=italic
    :hi link NvimTreeImageFile   Title
]])

-- vim.cmd([[
--     :hi     NvimTreeExecFile    gui=none
--     :hi     NvimTreeNormal      guibg=none
--     :hi     NvimTreeExecFile    gui=none
-- ]])
