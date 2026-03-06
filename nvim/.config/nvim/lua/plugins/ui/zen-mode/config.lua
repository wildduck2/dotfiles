local M = {}

function M.setup()
  require('zen-mode').setup {
    window = {
      backdrop = 0.95, -- 0-1; shade level for non-zen area
      width = 120, -- zen window width in columns; <1 = percentage
      height = 1, -- 1 = full height; <1 = percentage of screen
      options = {}, -- vim options to set in zen window
    },
    plugins = {
      -- Vim UI options to disable in zen mode
      options = { enabled = true, ruler = false, showcmd = false, laststatus = 0 }, -- laststatus 0 hides statusline
      twilight = { enabled = true }, -- true: dim inactive code with Twilight
      gitsigns = { enabled = false }, -- true: disable gitsigns in zen mode
      tmux = { enabled = false }, -- true: hide tmux statusbar in zen
      kitty = { enabled = false, font = '+4' }, -- font: size adjustment for kitty
      alacritty = { enabled = false, font = '14' }, -- font: absolute size for alacritty
      wezterm = { enabled = false, font = '+4' }, -- font: size adjustment for wezterm
    },
    on_open = function(win) end, -- callback when zen mode opens
    on_close = function() end, -- callback when zen mode closes
  }

  -- Zen with line numbers, 105-col wide
  vim.keymap.set('n', '<leader>zz', function()
    require('zen-mode').setup { window = { width = 105, options = {} } }
    require('zen-mode').toggle()
    vim.wo.wrap = false -- disable line wrapping
    vim.wo.number = true -- show absolute line numbers
    vim.wo.rnu = true -- show relative line numbers
  end)
  -- Minimal zen: no line numbers, 80-col wide
  vim.keymap.set('n', '<leader>zZ', function()
    require('zen-mode').setup { window = { width = 80, options = {} } }
    require('zen-mode').toggle()
    vim.wo.wrap = false
    vim.wo.number = false -- hide line numbers
    vim.wo.rnu = false -- hide relative numbers
    vim.opt.colorcolumn = '0' -- hide color column
  end)
end

return M
