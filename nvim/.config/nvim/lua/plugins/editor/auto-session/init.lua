-- Plain `nvim` in a folder reopens the files and splits it last had, which is also what tmux-resurrect starts.
return {
  'rmagatti/auto-session',
  lazy = false,
  init = function()
    vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
  end,
  opts = {
    suppressed_dirs = { '~/', '~/Downloads', '/' },
    -- Tool windows come back as empty buffers, so they are closed before the session is written.
    close_filetypes_on_save = { 'checkhealth', 'NvimTree', 'undotree', 'diff', 'toggleterm', 'DiffviewFiles', 'fugitive' },
  },
}
