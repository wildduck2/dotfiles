local M = {}

local function debug_adapter()
  local mason = vim.fn.stdpath('data') .. '/mason/packages/elixir-ls/debug_adapter.sh'
  if vim.fn.executable(mason) == 1 then return mason end
  local exe = vim.fn.exepath('elixir-ls-debug')
  if exe ~= '' then return exe end
  return mason
end

function M.setup()
  local dap = require('dap')

  dap.adapters.mix_task = {
    type = 'executable',
    command = debug_adapter(),
    args = {},
  }

  dap.configurations.elixir = {
    {
      type = 'mix_task',
      name = 'mix test',
      task = 'test',
      taskArgs = { '--trace' },
      request = 'launch',
      startApps = true,
      projectDir = '${workspaceFolder}',
      requireFiles = {
        'test/**/test_helper.exs',
        'test/**/*_test.exs',
      },
    },
    {
      type = 'mix_task',
      name = 'mix test current file',
      task = 'test',
      taskArgs = { '${file}', '--trace' },
      request = 'launch',
      startApps = true,
      projectDir = '${workspaceFolder}',
      requireFiles = { 'test/**/test_helper.exs', '${file}' },
    },
    {
      type = 'mix_task',
      name = 'phx.server',
      task = 'phx.server',
      request = 'launch',
      projectDir = '${workspaceFolder}',
    },
  }
end

return M
