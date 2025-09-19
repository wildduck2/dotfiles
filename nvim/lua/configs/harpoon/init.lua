local harpoon = require 'harpoon'

-- REQUIRED
harpoon:setup {
  settings = {
    save_on_toggle = true,
    sync_on_ui_close = true,
    key = function()
      return vim.loop.cwd()
    end,
  },
}
-- REQUIRED

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>a', function()
  harpoon:list():add()
end, opts)

vim.keymap.set('n', '<C-e>', function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, opts)

vim.keymap.set('n', '<C-t>', function()
  harpoon:list():select(1)
end, opts)

vim.keymap.set('n', '<C-u>', function()
  harpoon:list():select(2)
end, opts)

vim.keymap.set('n', '<C-n>', function()
  harpoon:list():select(3)
end, opts)

vim.keymap.set('n', '<C-s>', function()
  harpoon:list():select(4)
end, opts)

-- vim.keymap.set('n', '<C-a>', function()
--   harpoon:list():select(5)
-- end, opts)
