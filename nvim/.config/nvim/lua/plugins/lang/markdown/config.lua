local M = {}

function M.setup_peek()
  local peek = require 'peek'
  peek.setup {
    auto_load = false, -- Manual preview with :PeekOpen
    close_on_bdelete = true, -- Close preview when buffer deleted
    syntax = true, -- Syntax highlighting in preview
    theme = 'dark', -- Preview theme: 'dark' | 'light'
    update_on_change = true, -- Live-update on buffer change
    app = 'browser', -- Open in browser (vs 'webview')
    filetype = { 'markdown' }, -- Filetypes to enable preview for
    throttle_at = 200000, -- Throttle updates above this size
    throttle_time = 'auto', -- Throttle interval: 'auto' | ms
  }

  -- Open preview in a horizontal i3 split
  vim.api.nvim_create_user_command('PeekOpen', function()
    if not peek.is_open() and vim.bo[vim.api.nvim_get_current_buf()].filetype == 'markdown' then
      vim.system({ 'i3-msg', 'split', 'horizontal' }) -- async i3 IPC
      peek.open()
    end
  end, {})

  -- Close preview and move nvim window back left
  vim.api.nvim_create_user_command('PeekClose', function()
    if peek.is_open() then
      peek.close()
      vim.system({ 'i3-msg', 'move', 'left' }) -- async i3 IPC
    end
  end, {})
end

return M
