local M = {}

function M.setup()
  -- toggle undo history tree panel with <leader>u
  vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
end

return M
