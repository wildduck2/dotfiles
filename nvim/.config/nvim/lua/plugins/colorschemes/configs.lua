local M = {}

function M.colorbuddy()
  vim.cmd.colorscheme 'gruvbuddy'
end

function M.transparent()
  vim.cmd [[colorscheme tokyonight-night]]
end

return M
