local M = {}

function M.setup()
  require('tokyonight').setup()
  -- Variants: tokyonight-night | -storm | -day | -moon
  vim.cmd.colorscheme 'tokyonight-night'
end

return M
