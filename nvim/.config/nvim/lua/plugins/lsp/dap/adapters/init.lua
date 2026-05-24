local M = {}

function M.setup()
  require('plugins.lsp.dap.adapters.js').setup()
  require('plugins.lsp.dap.adapters.codelldb').setup()
  require('plugins.lsp.dap.adapters.elixir').setup()
  require('plugins.lsp.dap.adapters.go').setup()
  require('plugins.lsp.dap.adapters.python').setup()
end

return M
