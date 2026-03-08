local M = {}

M.opts = {
  size = 12, -- height (horizontal) or width (vertical) in rows/cols
  shade_filetypes = {}, -- filetypes to shade; empty = none
  hide_numbers = true, -- true: hide line numbers in terminal
  shade_terminals = true, -- true: dim terminal background
  insert_mappings = true, -- true: toggle keymaps work in insert mode
  terminal_mappings = true, -- true: toggle keymaps work in terminal mode
  start_in_insert = true, -- true: open terminal in insert mode
  persist_size = true, -- true: remember terminal size across toggles
  persist_mode = true, -- true: remember insert/normal mode across toggles
  close_on_exit = true, -- true: auto-close when shell process exits
  clear_env = false, -- true: clear environment variables in terminal
  direction = 'tab', -- 'horizontal' | 'vertical' | 'float' | 'tab'
  shading_factor = -30, -- darkness of shaded terminal; negative = darker
  shading_ratio = -3, -- shade ratio relative to Normal background
  shell = vim.o.shell, -- shell to use; defaults to vim's shell option
  autochdir = false, -- true: auto cd terminal to current buffer dir
  auto_scroll = true, -- true: scroll to bottom on output

  -- Window bar at top of terminal buffer
  winbar = {
    enabled = false, -- true: show winbar with terminal name
    name_formatter = function(term) -- formats terminal name in winbar
      return string.format('%d:%s', term.id, term:_display_name())
    end,
  },

  -- Options for floating terminal window
  float_opts = {
    border = 'rounded',
    winblend = 0,
    title_pos = 'left',
  },

  -- Responsive layout switching
  responsiveness = {
    horizontal_breakpoint = 0, -- min cols to use horizontal; 0 = disabled
  },
}

return M
