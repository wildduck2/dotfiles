-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

---@diagnostic disable-next-line: missing-fields
require('lazy').setup('plugins', {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
  -- Skip rarely-used built-in plugins. Saves ~5-10ms at startup and
  -- prevents netrw from re-hijacking after :Lazy reload.
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
        'netrwPlugin',
        'matchit',
        'matchparen',
        'spellfile',
      },
    },
  },
  checker = { enabled = true, frequency = 86400, notify = false },
  change_detection = { notify = false },
})
