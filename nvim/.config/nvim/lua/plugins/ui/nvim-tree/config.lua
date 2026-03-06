local M = {}

-- Custom file icon overrides for nvim-web-devicons
M.devicons_opts = {
  override = { -- per-filetype icon overrides
    zsh = { icon = '', color = '#428850', cterm_color = '65', name = 'Zsh' },
  },
  color_icons = true, -- true: colorize icons; false: monochrome
  default = true, -- true: show default icon for unknown filetypes
  strict = true, -- true: exact filetype match only
  override_by_filename = { -- icon overrides by exact filename
    ['.gitignore'] = { icon = '', color = '#f1502f', name = 'Gitignore' },
  },
  override_by_extension = { -- icon overrides by file extension
    ['log'] = { icon = '', color = '#81e043', name = 'Log' },
  },
}

function M.setup()
  -- Tab management keymaps
  vim.keymap.set('n', '<leader>tn', '<cmd>tabnew<CR>', { desc = 'New tab' })
  vim.keymap.set('n', '<leader>to', '<cmd>tabonly<CR>', { desc = 'Close other tabs' })
  vim.keymap.set('n', '<leader>tc', '<cmd>tabclose<CR>', { desc = 'Close tab' })
  vim.keymap.set('n', '<leader>t.', '<cmd>tabnext<CR>', { desc = 'Next tab' })
  vim.keymap.set('n', '<leader>t,', '<cmd>tabprev<CR>', { desc = 'Previous tab' })

  -- Highlights (lua API, faster than vim.cmd)
  vim.api.nvim_set_hl(0, 'SpellCap', { cterm = {}, sp = nil })
  vim.api.nvim_set_hl(0, 'NvimTreeSpecialFile', { fg = '#ff80ff', underline = true })
  vim.api.nvim_set_hl(0, 'NvimTreeSymlink', { fg = 'Yellow', italic = true })
  vim.api.nvim_set_hl(0, 'NvimTreeImageFile', { link = 'Title' })

  require('nvim-tree').setup {
    sort = { sorter = 'case_sensitive' }, -- 'name', 'case_sensitive', 'modification_time'
    filters = { dotfiles = false }, -- true: hide dotfiles
    disable_netrw = true, -- true: disable built-in file explorer
    hijack_netrw = true, -- true: open nvim-tree instead of netrw
    hijack_cursor = true, -- true: keep cursor on first letter of filename
    hijack_unnamed_buffer_when_opening = false, -- true: open tree in empty buffers
    sync_root_with_cwd = true, -- true: change tree root when :cd changes
    update_focused_file = { enable = true, update_root = false }, -- highlight current file; don't change root
    view = {
      adaptive_size = false, -- true: resize tree to fit content
      side = 'left', -- 'left' | 'right'
      width = 45, -- tree panel width in columns
      preserve_window_proportions = true, -- true: keep window sizes on open/close
    },
    git = { enable = true, ignore = false }, -- ignore=false: show git-ignored files
    filesystem_watchers = { enable = true }, -- true: auto-refresh on fs changes
    actions = { open_file = { resize_window = true } }, -- true: resize tree on file open
    renderer = {
      root_folder_label = false, -- false: hide root folder path label
      highlight_git = true, -- true: color filenames by git status
      highlight_opened_files = 'none', -- 'none' | 'icon' | 'name' | 'all'
      indent_markers = { enable = true }, -- true: show tree indent guides
      icons = {
        show = { file = true, folder = true, folder_arrow = true, git = true },
        glyphs = {
          default = '󰈘',
          symlink = '',
          folder = {
            default = '',
            empty = '󰉖',
            empty_open = '󰷏',
            open = '',
            symlink = '󱅷',
            symlink_open = '󱅸',
            arrow_open = '',
            arrow_closed = '',
          },
          git = {
            unstaged = '',
            staged = '✓',
            unmerged = '',
            renamed = '➜',
            untracked = '',
            deleted = '',
            ignored = '◌',
          },
        },
      },
    },
  }
end

return M
