local M = {}

function M.setup()
  require('hacker').setup {
    content = [[ Code want to show.... ]], -- Text to "type" in hacker mode
    filetype = 'lua', -- Syntax highlighting for fake code
    speed = { min = 2, max = 2 }, -- Typing speed range (chars/tick)
    is_popup = false, -- Show in current buf, not a popup
    popup_after = 5, -- Seconds before popup (if is_popup)
  }
  vim.keymap.set('n', '<leader>ha', '<cmd>:HackFollowAuto<cr>', { desc = '[H]ackerFollowAuto' })
  vim.keymap.set('n', '<leader>h', '<cmd>:Hack<cr>', { desc = '[H]acker' })
end

return M
