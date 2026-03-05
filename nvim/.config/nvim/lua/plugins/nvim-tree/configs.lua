local M = {}

M.devicons = {
  override = {
    zsh = { icon = '', color = '#428850', cterm_color = '65', name = 'Zsh' },
  },
  color_icons = true,
  default = true,
  strict = true,
  override_by_filename = {
    ['.gitignore'] = { icon = '', color = '#f1502f', name = 'Gitignore' },
  },
  override_by_extension = {
    ['log'] = { icon = '', color = '#81e043', name = 'Log' },
  },
}

M.tree = {
  sort = { sorter = 'case_sensitive' },
  filters = { dotfiles = false },
  disable_netrw = true,
  hijack_netrw = true,
  hijack_cursor = true,
  hijack_unnamed_buffer_when_opening = false,
  sync_root_with_cwd = true,
  update_focused_file = { enable = true, update_root = false },
  view = {
    adaptive_size = false,
    side = 'left',
    width = 45,
    preserve_window_proportions = true,
  },
  git = { enable = true, ignore = false },
  filesystem_watchers = { enable = true },
  actions = { open_file = { resize_window = true } },
  renderer = {
    root_folder_label = false,
    highlight_git = true,
    highlight_opened_files = 'none',
    indent_markers = { enable = true },
    icons = {
      show = { file = true, folder = true, folder_arrow = true, git = true },
      glyphs = {
        default = '󰈚',
        symlink = '',
        folder = {
          default = '',
          empty = '',
          empty_open = '',
          open = '',
          symlink = '',
          symlink_open = '',
          arrow_open = '',
          arrow_closed = '',
        },
        git = {
          unstaged = '✗',
          staged = '✓',
          unmerged = '',
          renamed = '➜',
          untracked = '★',
          deleted = '',
          ignored = '◌',
        },
      },
    },
  },
}

function M.setup_keymaps()
  -- Tab management
  vim.keymap.set('n', '<leader>tn', '<cmd>tabnew<CR>', { desc = 'New tab' })
  vim.keymap.set('n', '<leader>to', '<cmd>tabonly<CR>', { desc = 'Close other tabs' })
  vim.keymap.set('n', '<leader>tc', '<cmd>tabclose<CR>', { desc = 'Close tab' })
  vim.keymap.set('n', '<leader>t.', '<cmd>tabnext<CR>', { desc = 'Next tab' })
  vim.keymap.set('n', '<leader>t,', '<cmd>tabprev<CR>', { desc = 'Previous tab' })
end

function M.setup_highlights()
  vim.cmd [[
    :hi SpellCap cterm=NONE gui=NONE guisp=NONE
    :hi      NvimTreeSpecialFile guifg=#ff80ff gui=underline
    :hi      NvimTreeSymlink     guifg=Yellow  gui=italic
    :hi link NvimTreeImageFile   Title
  ]]
end

function M.early_setup()
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1
  vim.opt.termguicolors = true
end

function M.setup()
  M.setup_keymaps()
  M.setup_highlights()
  require('nvim-tree').setup(M.tree)
end

return M
