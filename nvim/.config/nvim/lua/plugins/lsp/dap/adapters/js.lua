local M = {}

function M.setup()
  local mason_bin = vim.fn.stdpath('data') .. '/mason/bin/js-debug-adapter'
  local cmd = vim.fn.executable(mason_bin) == 1 and mason_bin or 'js-debug-adapter'

  local dap = require('dap')

  -- Direct adapter wiring (no dap-vscode-js). js-debug-adapter speaks DAP
  -- over a server socket; dap interpolates ${port} on launch.
  for _, type_name in ipairs({
    'pwa-node',
    'pwa-chrome',
    'pwa-msedge',
    'node-terminal',
    'pwa-extensionHost',
    'node',
  }) do
    dap.adapters[type_name] = {
      type = 'server',
      host = 'localhost',
      port = '${port}',
      executable = {
        command = cmd,
        args = { '${port}' },
      },
    }
  end
  local filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' }

  -- Path is resolved by node relative to ${workspaceFolder} (cwd). Each
  -- project gets its own pinned tsx via local node_modules.
  local tsx_cli = './node_modules/tsx/dist/cli.mjs'

  local skip = {
    '<node_internals>/**',
    '**/node_modules/**',
  }

  for _, ft in ipairs(filetypes) do
    dap.configurations[ft] = {
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch TS (tsx CLI)',
        runtimeExecutable = 'node',
        runtimeArgs = { tsx_cli, '--no-warnings' },
        program = '${file}',
        cwd = '${workspaceFolder}',
        console = 'integratedTerminal',
        sourceMaps = true,
        resolveSourceMapLocations = { '${workspaceFolder}/**', '!**/node_modules/**' },
        skipFiles = skip,
      },
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch TS (tsx CLI, stop on entry)',
        runtimeExecutable = 'node',
        runtimeArgs = { tsx_cli, '--no-warnings' },
        program = '${file}',
        cwd = '${workspaceFolder}',
        console = 'integratedTerminal',
        stopOnEntry = true,
        sourceMaps = true,
        resolveSourceMapLocations = { '${workspaceFolder}/**', '!**/node_modules/**' },
        skipFiles = skip,
      },
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch file (node, plain JS)',
        program = '${file}',
        cwd = '${workspaceFolder}',
        console = 'integratedTerminal',
        sourceMaps = true,
        resolveSourceMapLocations = { '${workspaceFolder}/**', '!**/node_modules/**' },
      },
      {
        type = 'pwa-node',
        request = 'attach',
        name = 'Attach to process',
        processId = require('dap.utils').pick_process,
        cwd = '${workspaceFolder}',
      },
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Debug Jest current file',
        runtimeExecutable = 'node',
        runtimeArgs = {
          './node_modules/jest/bin/jest.js',
          '--runInBand',
          '${file}',
        },
        rootPath = '${workspaceFolder}',
        cwd = '${workspaceFolder}',
        console = 'integratedTerminal',
        internalConsoleOptions = 'neverOpen',
      },
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Debug Vitest current file',
        autoAttachChildProcesses = true,
        skipFiles = { '<node_internals>/**', '**/node_modules/**' },
        runtimeExecutable = 'node',
        runtimeArgs = {
          './node_modules/vitest/vitest.mjs',
          'run',
          '${file}',
        },
        cwd = '${workspaceFolder}',
        smartStep = true,
        console = 'integratedTerminal',
      },
      {
        type = 'pwa-chrome',
        request = 'launch',
        name = 'Chrome: http://localhost:3000',
        url = 'http://localhost:3000',
        webRoot = '${workspaceFolder}',
        sourceMaps = true,
        sourceMapPathOverrides = {
          ['webpack:///./~/*'] = '${workspaceFolder}/node_modules/*',
          ['webpack:///./*'] = '${workspaceFolder}/*',
          ['webpack:///*'] = '*',
        },
      },
    }
  end
end

return M
