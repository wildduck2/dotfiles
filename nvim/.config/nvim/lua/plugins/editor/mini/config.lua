local M = {}

function M.setup()
  -- enhanced text objects; n_lines = search range for ai/i
  require('mini.ai').setup { n_lines = 500 }
  -- add/delete/change surrounding pairs (brackets, quotes)
  require('mini.surround').setup()

  -- Statusline
  local statusline = require 'mini.statusline'
  -- true: use Nerd Font icons in statusline sections
  statusline.setup { use_icons = vim.g.have_nerd_font }
  ---@diagnostic disable-next-line: duplicate-set-field
  -- override location section to show LINE:COL format
  statusline.section_location = function()
    return '%2l:%-2v'
  end
end

return M
