local M = {}

-- Short display names for each vim mode in statusline
M.mode_map = {
  ['n'] = 'N', ['no'] = 'O-P', ['nov'] = 'O-P', ['noV'] = 'O-P',
  ['niI'] = 'N', ['niR'] = 'N', ['niV'] = 'N', ['nt'] = 'N',
  ['v'] = 'V', ['vs'] = 'V', ['V'] = 'V-L', ['Vs'] = 'V-L',
  ['s'] = 'S', ['S'] = 'S-L',
  ['i'] = 'I', ['ic'] = 'I', ['ix'] = 'I',
  ['R'] = 'R', ['Rc'] = 'R', ['Rx'] = 'R',
  ['Rv'] = 'V-R', ['Rvc'] = 'V-R', ['Rvx'] = 'V-R',
  ['c'] = 'C', ['cv'] = 'EX', ['ce'] = 'EX',
  ['r'] = 'R', ['rm'] = 'MORE', ['r?'] = 'CONFIRM',
  ['!'] = 'SHELL', ['t'] = 'T',
}

function M.setup()
  require('lualine').setup {
    options = {
      icons_enabled = true,
      theme = 'auto', -- auto-detect from colorscheme; or 'gruvbox', etc.
      section_separators = { left = '', right = '' }, -- powerline-style arrows
    },
    sections = {
      -- Section A (far-left): mode indicator
      lualine_a = {
        {
          'mode',
          fmt = function() -- maps vim mode to short label via mode_map
            return M.mode_map[vim.api.nvim_get_mode().mode] or '__'
          end,
        },
      },
      -- Section B: git branch + diagnostics
      lualine_b = {
        {
          'branch',
          icon = '', -- git branch icon
          separator = { left = '', right = '' }, -- sub-section separators
          colored = true, -- true: use highlight colors
          update_in_insert = false, -- false: skip updates in insert mode
          always_visible = false, -- false: hide when no branch
        },
        {
          'diagnostics',
          sources = { 'nvim_diagnostic' }, -- LSP diagnostic provider
          sections = { 'error', 'warn', 'info', 'hint' }, -- severity levels shown
          symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' }, -- text labels
          separator = { left = '', right = '' },
          colored = true, -- true: color by severity level
          update_in_insert = false, -- false: don't refresh in insert mode
          always_visible = false, -- false: hide when no diagnostics
        },
      },
      -- Section C: git diff stats + filename
      lualine_c = {
        {
          'diff',
          colored = true, -- true: color added/modified/removed
          diff_color = { -- highlight groups for each diff type
            added = 'LuaLineDiffAdd',
            modified = 'LuaLineDiffChange',
            removed = 'LuaLineDiffDelete',
          },
          symbols = { added = '+', modified = '~', removed = '-' },
          separator = { left = '', right = '' },
          source = nil, -- nil: auto-detect git diff source
        },
        {
          'filename',
          file_status = true, -- true: show modified/readonly indicator
          newfile_status = true, -- true: show [New] for new files
          path = 1, -- 0=name, 1=relative, 2=absolute, 3=absolute+tilde
          shorting_target = 40, -- trim path if statusline > window width - N
          symbols = { modified = '[+]', readonly = '[-]', unnamed = '[No Name]', newfile = '[New]' },
        },
      },
      -- Section X: filetype with icon
      lualine_x = {
        { 'filetype', colored = true, icon_only = false, icon = { align = 'right' } }, -- icon_only=true hides text
      },
      lualine_y = { 'progress' }, -- % through file
      lualine_z = { 'location' }, -- line:column
    },
    -- Sections shown in unfocused windows
    inactive_sections = {
      lualine_a = {}, lualine_b = {},
      lualine_c = { 'filename' }, lualine_x = { 'location' },
      lualine_y = {}, lualine_z = {},
    },
    tabline = {}, -- top tabline components (empty = disabled)
    winbar = {}, -- per-window top bar (empty = disabled)
    inactive_winbar = {},
    extensions = {}, -- integrations: 'nvim-tree', 'fugitive', etc.
  }
end

return M
