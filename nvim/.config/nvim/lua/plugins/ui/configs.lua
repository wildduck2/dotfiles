local M = {}

-- Lualine mode map
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

function M.setup_lualine()
  require('lualine').setup {
    options = {
      icons_enabled = true,
      theme = 'auto',
      section_separators = { left = '', right = '' },
    },
    sections = {
      lualine_a = {
        {
          'mode',
          fmt = function()
            return M.mode_map[vim.api.nvim_get_mode().mode] or '__'
          end,
        },
      },
      lualine_b = {
        {
          'branch',
          separator = { left = '', right = '' },
          colored = true,
          update_in_insert = false,
          always_visible = false,
        },
        {
          'diagnostics',
          sources = { 'nvim_diagnostic', 'coc' },
          sections = { 'error', 'warn', 'info', 'hint' },
          symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' },
          separator = { left = '', right = '' },
          colored = true,
          update_in_insert = false,
          always_visible = false,
        },
      },
      lualine_c = {
        {
          'diff',
          colored = true,
          diff_color = {
            added = 'LuaLineDiffAdd',
            modified = 'LuaLineDiffChange',
            removed = 'LuaLineDiffDelete',
          },
          symbols = { added = '+', modified = '~', removed = '-' },
          separator = { left = '', right = '' },
          source = nil,
        },
        {
          'filename',
          file_status = true,
          newfile_status = true,
          path = 1,
          shorting_target = 40,
          symbols = { modified = '[+]', readonly = '[-]', unnamed = '[No Name]', newfile = '[New]' },
        },
      },
      lualine_x = {
        { 'filetype', colored = true, icon_only = false, icon = { align = 'right' } },
      },
      lualine_y = { 'progress' },
      lualine_z = { 'location' },
    },
    inactive_sections = {
      lualine_a = {}, lualine_b = {},
      lualine_c = { 'filename' }, lualine_x = { 'location' },
      lualine_y = {}, lualine_z = {},
    },
    tabline = {}, winbar = {}, inactive_winbar = {}, extensions = {},
  }
end

function M.setup_zenmode()
  require('zen-mode').setup {
    window = {
      backdrop = 0.95,
      width = 120,
      height = 1,
      options = {},
    },
    plugins = {
      options = { enabled = true, ruler = false, showcmd = false, laststatus = 0 },
      twilight = { enabled = true },
      gitsigns = { enabled = false },
      tmux = { enabled = false },
      kitty = { enabled = false, font = '+4' },
      alacritty = { enabled = false, font = '14' },
      wezterm = { enabled = false, font = '+4' },
    },
    on_open = function(win) end,
    on_close = function() end,
  }

  vim.keymap.set('n', '<leader>zz', function()
    require('zen-mode').setup { window = { width = 105, options = {} } }
    require('zen-mode').toggle()
    vim.wo.wrap = false
    vim.wo.number = true
    vim.wo.rnu = true
  end)
  vim.keymap.set('n', '<leader>zZ', function()
    require('zen-mode').setup { window = { width = 80, options = {} } }
    require('zen-mode').toggle()
    vim.wo.wrap = false
    vim.wo.number = false
    vim.wo.rnu = false
    vim.opt.colorcolumn = '0'
  end)
end

M.ibl = {
  whitespace = { highlight = { 'Whitespace', 'NonText' } },
  indent = { smart_indent_cap = true, repeat_linebreak = true },
  scope = {
    enabled = true,
    show_start = true,
    show_end = true,
    highlight = 'Function',
    priority = 500,
  },
}

function M.setup_ibl()
  require('ibl').setup(M.ibl)
end

M.which_key = {
  icons = {
    mappings = vim.g.have_nerd_font,
    keys = vim.g.have_nerd_font and {} or {
      Up = '<Up> ', Down = '<Down> ', Left = '<Left> ', Right = '<Right> ',
      C = '<C-…> ', M = '<M-…> ', D = '<D-…> ', S = '<S-…> ',
      CR = '<CR> ', Esc = '<Esc> ', ScrollWheelDown = '<ScrollWheelDown> ',
      ScrollWheelUp = '<ScrollWheelUp> ', NL = '<NL> ', BS = '<BS> ',
      Space = '<Space> ', Tab = '<Tab> ',
      F1 = '<F1>', F2 = '<F2>', F3 = '<F3>', F4 = '<F4>',
      F5 = '<F5>', F6 = '<F6>', F7 = '<F7>', F8 = '<F8>',
      F9 = '<F9>', F10 = '<F10>', F11 = '<F11>', F12 = '<F12>',
    },
  },
  spec = {
    { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
    { '<leader>d', group = '[D]elete/Document' },
    { '<leader>e', group = '[E]rror diagnostics' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    { '<leader>p', group = '[P]roject' },
    { '<leader>q', group = '[Q]uickfix' },
    { '<leader>r', group = '[R]ename' },
    { '<leader>s', group = '[S]earch' },
    { '<leader>t', group = '[T]oggle/Tab' },
    { '<leader>v', group = '[V]im config' },
    { '<leader>w', group = '[W]orkspace' },
    { '<leader>x', group = 'Trouble/E[x]ecute' },
    { '<leader>y', group = '[Y]ank to clipboard' },
  },
}

function M.setup_which_key()
  require('which-key').setup(M.which_key)
end

return M
