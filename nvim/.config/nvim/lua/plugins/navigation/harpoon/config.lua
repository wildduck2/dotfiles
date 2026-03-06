local M = {}

function M.setup()
  local harpoon = require 'harpoon'
  harpoon:setup {
    settings = {
      -- true=persist list when menu closes; false=discard
      save_on_toggle = true,
      -- true=save list when UI window closes
      sync_on_ui_close = true,
      -- Scope harpoon lists per working directory
      key = function()
        return vim.uv.cwd()
      end,
    },
  }

  -- noremap=no recursive mapping, silent=no cmdline echo
  local opts = { noremap = true, silent = true }
  -- Add current file to harpoon list
  vim.keymap.set('n', '<leader>a', function()
    harpoon:list():add()
  end, opts)
  -- Toggle harpoon quick menu
  vim.keymap.set('n', '<C-e>', function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
  end, opts)
  -- Jump to harpoon slot 1
  vim.keymap.set('n', '<C-t>', function()
    harpoon:list():select(1)
  end, opts)
  -- Jump to harpoon slot 2 (avoid <C-u> — conflicts with scroll-up)
  vim.keymap.set('n', '<C-y>', function()
    harpoon:list():select(2)
  end, opts)
  -- Jump to harpoon slot 3
  vim.keymap.set('n', '<C-n>', function()
    harpoon:list():select(3)
  end, opts)
  -- Jump to harpoon slot 4
  vim.keymap.set('n', '<C-s>', function()
    harpoon:list():select(4)
  end, opts)
end

return M
