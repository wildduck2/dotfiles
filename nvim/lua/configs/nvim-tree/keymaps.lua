-- NvimTree keymap
vim.keymap.set("n", "<leader>pv", vim.cmd.NvimTreeToggle)
vim.keymap.set("n", "<leader>l", vim.cmd.NvimTreeFocus)

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
