return {
  'sindrets/diffview.nvim',
  cmd = {
    'DiffviewOpen',
    'DiffviewClose',
    'DiffviewToggleFiles',
    'DiffviewFocusFiles',
    'DiffviewRefresh',
    'DiffviewFileHistory',
  },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Diffview: open' },
    { '<leader>gD', '<cmd>DiffviewClose<cr>', desc = 'Diffview: close' },
    { '<leader>gh', '<cmd>DiffviewFileHistory<cr>', desc = 'Diffview: repo history' },
    { '<leader>gH', '<cmd>DiffviewFileHistory %<cr>', desc = 'Diffview: current file history' },
    { '<leader>gm', '<cmd>DiffviewOpen main...HEAD<cr>', desc = 'Diffview: diff vs main' },
  },
  config = function()
    require('plugins.git.diffview.config').setup()
  end,
}
