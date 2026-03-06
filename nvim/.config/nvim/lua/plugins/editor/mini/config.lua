local M = {}

function M.setup()
  -- enhanced text objects; n_lines = search range for ai/i
  require('mini.ai').setup { n_lines = 500 }
  -- add/delete/change surrounding pairs (brackets, quotes)
  require('mini.surround').setup()
  -- NOTE: mini.statusline removed — lualine handles the statusline
end

return M
