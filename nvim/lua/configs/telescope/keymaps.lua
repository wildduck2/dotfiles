-- NOTE: read more about the blugin and functions at : https://github.com/nvim-telescope/telescope.nvim
-- See `:help telescope.builtin`
--
local builtin = require 'telescope.builtin'
local trouble = require 'trouble.providers.telescope'

vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set(
  'n',
  '<leader>s.',
  builtin.oldfiles,
  { desc = '[S]earch Recent Files ("." for repeat)' }
)
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

-- NOTE: these for the telescope-ast-grep plugin
vim.keymap.set('n', '<leader>sa', '<cmd>Telescope ast_grep<CR>', { desc = '[S]earch AST' })
vim.keymap.set('n', '<leader>sj', '<cmd>Telescope dumb_jump<CR>', { desc = '[S]earch Jump' })

vim.keymap.set('n', '<leader>su', function()
  require('trouble').toggle { mode = 'document_diagnostics' }
end, { desc = '[S]earch trouble' })

vim.keymap.set('n', '<leader>snd', '<cmd>Telescope diagnostics<cr>', {
  desc = 'Search diagnostics with Telescope',
})
vim.keymap.set('n', '<leader>sd', function()
  require('telescope.builtin').diagnostics { bufnr = 0 }
end, { desc = 'Search document diagnostics (Telescope)' })

-- require("trouble").toggle("workspace_diagnostics")
-- require("trouble").toggle("document_diagnostics")

-- Slightly advanced example of overriding default behavior and theme
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

-- Also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set('n', '<leader>s/', function()
  builtin.live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end, { desc = '[S]earch [/] in Open Files' })

-- Shortcut for searching your neovim configuration files
-- vim.keymap.set('n', '<leader>sn', function()
--   builtin.find_files { cwd = vim.fn.stdpath 'config' }
-- end, { desc = '[S]earch [N]eovim files' })

--NOTE: this is some default keymaps
-- Mappings are fully customizable. Many familiar mapping patterns are set up as defaults.

-- <Mappings>	Action
-- <C-n>/<Down>	 => Next item
-- <C-p>/<Up>	Previous item
-- <j/k> =>	Next/previous (in normal mode)
-- <H/M/L> =>	Select High/Middle/Low (in normal mode)
-- <gg/G> =>	Select the first/last item (in normal mode)
-- <CR> =>	Confirm selection
-- <C-x> =>	Go to file selection as a split
-- <C-v> =>	Go to file selection as a vsplit
-- <C-t> =>	Go to a file in a new tab
-- <C-u> =>	Scroll up in preview window
-- <C-d> =>	Scroll down in preview window
-- <C-f> =>	Scroll left in preview window
-- <C-k> =>	Scroll right in preview window
-- <M-f> =>	Scroll left in results window
-- <M-k> =>	Scroll right in results window
-- <C-/> =>	Show mappings for picker actions (insert mode)
-- <?> =>	Show mappings for picker actions (normal mode)
-- <C-c> =>	Close telescope (insert mode)
-- <Esc> =>	Close telescope (in normal mode)
-- <Tab> =>	Toggle selection and move to next selection
-- <S-Tab> =>	Toggle selection and move to prev selection
-- <C-q> =>	Send all items not filtered to quickfixlist (qflist)
-- <M-q> =>	Send all selected items to qflist
-- <C-r><C-w> =>	Insert cword in original window into prompt (insert mode)
