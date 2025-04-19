--NOTE: disable guicursor
vim.opt.guicursor = ''

--NOTE: line numbers
vim.opt.number = true
vim.opt.relativenumber = true
--NOTE: mouse support
vim.opt.mouse = 'a'

--NOTE: hide the mode in command line
vim.opt.showmode = false

--NOTE: global clipboard for system clipboard
vim.schedule(function()
  vim.opt.clipboard = ''
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
-- vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.listchars:append 'eol:↴'

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
-- vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.cursorline = true

vim.opt.termguicolors = true

vim.opt.isfname:append '@-@'
vim.opt.scrolljump = 1

vim.opt.textwidth = 100
vim.opt.colorcolumn = '100'
vim.opt.wrap = true
vim.opt.linebreak = true

-- Folding stuff
vim.opt.foldmethod = 'indent'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 23

--[[ That's it. The most useful commands for working with folds are:

    zo opens a fold at the cursor.
    zShift+o opens all folds at the cursor.
    zc closes a fold at the cursor.
    zm increases the foldlevel by one.
    zShift+m closes all open folds.
    zr decreases the foldlevel by one.
    zShift+r decreases the foldlevel to zero -- all folds will be open.
]]

--[[ indent is kind of folding, you can see more from :help foldmethod

'foldmethod' 'fdm'      string (default: "manual")
                        local to window
                        {not in Vi}
                        {not available when compiled without the +folding
                        feature}
        The kind of folding used for the current window.  Possible values:
        fold-manual     manual      Folds are created manually.
        fold-indent     indent      Lines with equal indent form a fold.
        fold-expr       expr        'foldexpr' gives the fold level of a line.
        fold-marker     marker      Markers are used to specify folds.
        fold-syntax     syntax      Syntax highlighting items specify folds.
        fold-diff       diff        Fold text that is not changed.
]]
