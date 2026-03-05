local M = {}

M.peek = {
  auto_load = true,
  close_on_bdelete = true,
  syntax = true,
  theme = 'dark',
  update_on_change = true,
  app = 'browser',
  filetype = { 'markdown' },
  throttle_at = 200000,
  throttle_time = 'auto',
}

function M.setup_peek()
  local peek = require 'peek'
  peek.setup(M.peek)

  vim.api.nvim_create_user_command('PeekOpen', function()
    if not peek.is_open() and vim.bo[vim.api.nvim_get_current_buf()].filetype == 'markdown' then
      vim.fn.system 'i3-msg split horizontal'
      peek.open()
    end
  end, {})

  vim.api.nvim_create_user_command('PeekClose', function()
    if peek.is_open() then
      peek.close()
      vim.fn.system 'i3-msg move left'
    end
  end, {})
end

return M
