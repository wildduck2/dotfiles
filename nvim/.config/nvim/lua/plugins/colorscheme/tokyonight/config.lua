local M = {}

M.opts = {}

function M.setup(_, opts)
  require('tokyonight').setup(opts)
  -- Variants: tokyonight-night | -storm | -day | -moon
  vim.cmd.colorscheme 'tokyonight-night'
end

return M
