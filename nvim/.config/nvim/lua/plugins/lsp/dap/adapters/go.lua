local M = {}

function M.setup()
  -- dap-go wires the delve adapter and configurations (debug, debug_test,
  -- attach, debug_last). Mason installs delve via mason-nvim-dap.
  require('dap-go').setup({
    delve = {
      path = vim.fn.exepath('dlv'),
      initialize_timeout_sec = 20,
      port = '${port}',
      args = {},
      build_flags = '',
    },
  })
end

return M
