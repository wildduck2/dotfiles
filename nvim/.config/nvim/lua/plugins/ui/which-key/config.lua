local M = {}

M.opts = {
  win = {
    border = 'rounded',
    padding = { 1, 2 },
  },
  icons = {
    mappings = vim.g.have_nerd_font, -- true: use nerd font icons for groups
    keys = vim.g.have_nerd_font and {} or { -- text fallbacks when no nerd font
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
  -- Keybinding group labels shown in which-key popup
  spec = {
    { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } }, -- normal + visual
    { '<leader>d', group = '[D]elete/Document' },
    { '<leader>e', group = '[E]rror diagnostics' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } }, -- normal + visual
    { '<leader>p', group = '[P]roject' },
    { '<leader>q', group = '[Q]uickfix' },
    { '<leader>r', group = '[R]ename/[R]ust' },
    { '<leader>s', group = '[S]earch' },
    { '<leader>t', group = '[T]oggle/Tab' },
    { '<leader>v', group = '[V]im config' },
    { '<leader>w', group = '[W]orkspace' },
    { '<leader>x', group = 'Trouble/E[x]ecute' },
    { '<leader>y', group = '[Y]ank to clipboard' },
  },
}

return M
