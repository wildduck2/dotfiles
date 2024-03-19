vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
--
vim.opt.updatetime = 50
vim.opt.breakindent = true
vim.opt.textwidth = 100
vim.opt.colorcolumn = "100"
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.listchars:append("eol:↴")

-- Folding stuff
vim.opt.foldmethod = "indent"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
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
