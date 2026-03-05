-- NvimTree keymaps
vim.keymap.set('n', '<leader>pv', vim.cmd.NvimTreeToggle, { desc = 'Toggle file tree' })
vim.keymap.set('n', '<leader>l', vim.cmd.NvimTreeFocus, { desc = 'Focus file tree' })

-- Tab management
vim.keymap.set('n', '<leader>tn', '<cmd>tabnew<CR>', { desc = 'New tab' })
vim.keymap.set('n', '<leader>to', '<cmd>tabonly<CR>', { desc = 'Close other tabs' })
vim.keymap.set('n', '<leader>tc', '<cmd>tabclose<CR>', { desc = 'Close tab' })
vim.keymap.set('n', '<leader>t.', '<cmd>tabnext<CR>', { desc = 'Next tab' })
vim.keymap.set('n', '<leader>t,', '<cmd>tabprev<CR>', { desc = 'Previous tab' })

-- Fix underline on file names in nvim-tree
vim.cmd [[
    :hi SpellCap cterm=NONE gui=NONE guisp=NONE
    :hi      NvimTreeSpecialFile guifg=#ff80ff gui=underline
    :hi      NvimTreeSymlink     guifg=Yellow  gui=italic
    :hi link NvimTreeImageFile   Title
]]
