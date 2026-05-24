local M = {}

function M.setup()
  local mason_root = vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter'
  local mason_bin = vim.fn.stdpath('data') .. '/mason/bin/js-debug-adapter'
  local cmd = vim.fn.executable(mason_bin) == 1 and mason_bin or 'js-debug-adapter'

  require('dap-vscode-js').setup({
    debugger_path = mason_root,
    debugger_cmd = { cmd },
    adapters = {
      'pwa-node', 'pwa-chrome', 'pwa-msedge',
      'node-terminal', 'pwa-extensionHost', 'node',
    },
  })

  local dap = require('dap')
  local filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' }

  for _, ft in ipairs(filetypes) do
    dap.configurations[ft] = {
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch file (node)',
        program = '${file}',
        cwd = '${workspaceFolder}',
        sourceMaps = true,
        resolveSourceMapLocations = { '${workspaceFolder}/**', '!**/node_modules/**' },
      },
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch file (tsx loader)',
        runtimeExecutable = 'node',
        runtimeArgs = { '--import=tsx' },
        program = '${file}',
        cwd = '${workspaceFolder}',
        sourceMaps = true,
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
