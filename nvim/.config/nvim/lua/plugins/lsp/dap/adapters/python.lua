local M = {}

function M.setup()
  local mason_debugpy = vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python'
  local python = vim.fn.executable(mason_debugpy) == 1 and mason_debugpy or 'python3'

  -- dap-python registers the 'python' adapter and basic launch configs
  -- (file, file:args, module, attach). pytest helpers come via:
  --   require('dap-python').test_method() / .test_class() / .debug_selection()
  require('dap-python').setup(python)
  require('dap-python').test_runner = 'pytest'
end

return M
