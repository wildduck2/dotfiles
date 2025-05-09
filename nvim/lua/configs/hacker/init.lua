-- default config
require('hacker').setup {
  content = [[ Code want to show.... ]], -- The code snippet that show when typing
  filetype = 'lua',                      -- filetype of code snippet
  speed = {                              -- characters insert each time, random from min -> max
    min = 2,
    max = 2,
  },
  is_popup = false, -- show random float window when typing
  popup_after = 5,
}

vim.keymap.set('n', '<leader>ha', '<cmd>:HackFollowAuto<cr>', { desc = '[H]ackerFollowAuto' })
vim.keymap.set('n', '<leader>h', '<cmd>:Hack<cr>', { desc = '[H]acker' })
