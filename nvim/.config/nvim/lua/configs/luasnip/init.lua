---@diagnostic disable: unused-local
require 'configs.luasnip.snips.init'
local ls = require('luasnip')

-- You can also load snippets from external files (VSCode-style for example)
require('luasnip.loaders.from_vscode').lazy_load() -- loads snippets from your VSCode-style snippet folder

-- Add mappings to trigger snippets
vim.api.nvim_set_keymap('i', '<C-k>', "<cmd>lua require'luasnip'.expand_or_jump()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('s', '<C-k>', "<cmd>lua require'luasnip'.expand_or_jump()<CR>", { noremap = true, silent = true })
