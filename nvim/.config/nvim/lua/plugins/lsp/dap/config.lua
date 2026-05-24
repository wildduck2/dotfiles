local M = {}

function M.setup()
  local dap = require('dap')
  local dapui = require('dapui')

  require('mason-nvim-dap').setup({
    automatic_installation = true,
    ensure_installed = {
      'codelldb',
      'js-debug-adapter',
      'delve',
      'debugpy',
    },
    handlers = {},
  })

  dapui.setup({
    icons = { expanded = '', collapsed = '', current_frame = '' },
    mappings = {
      expand = { '<CR>', '<2-LeftMouse>' },
      open = 'o',
      remove = 'd',
      edit = 'e',
      repl = 'r',
      toggle = 't',
    },
    layouts = {
      {
        elements = {
          { id = 'scopes', size = 0.30 },
          { id = 'breakpoints', size = 0.15 },
          { id = 'stacks', size = 0.30 },
          { id = 'watches', size = 0.25 },
        },
        size = 50,
        position = 'left',
      },
      {
        elements = {
          { id = 'repl', size = 0.5 },
          { id = 'console', size = 0.5 },
        },
        size = 10,
        position = 'bottom',
      },
    },
    floating = { border = 'rounded', mappings = { close = { 'q', '<Esc>' } } },
    controls = { enabled = true, element = 'repl' },
    render = { max_type_length = nil, max_value_lines = 100 },
  })

  require('nvim-dap-virtual-text').setup({
    enabled = true,
    enabled_commands = true,
    highlight_changed_variables = true,
    highlight_new_as_changed = false,
    show_stop_reason = true,
    commented = false,
    virt_text_pos = 'eol',
    all_frames = false,
    virt_lines = false,
  })

  vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DiagnosticError', linehl = '', numhl = '' })
  vim.fn.sign_define('DapBreakpointCondition', { text = '', texthl = 'DiagnosticWarn', linehl = '', numhl = '' })
  vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'DiagnosticInfo', linehl = '', numhl = '' })
  vim.fn.sign_define('DapStopped', { text = '', texthl = 'DiagnosticOk', linehl = 'Visual', numhl = '' })
  vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DiagnosticError', linehl = '', numhl = '' })

  dap.listeners.before.attach.dapui_config = function() dapui.open() end
  dap.listeners.before.launch.dapui_config = function() dapui.open() end
  dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
  dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

  require('plugins.lsp.dap.adapters').setup()

  -- Register dap-providers so on-demand `.vscode/launch.json` lookups know
  -- which custom adapter types should map to which filetypes. nvim-dap reads
  -- the file automatically when `dap.continue()` runs.
  local ext_vscode = require('dap.ext.vscode')
  for type_name, fts in pairs({
    ['pwa-node'] = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
    ['pwa-chrome'] = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
    codelldb = { 'rust', 'c', 'cpp' },
  }) do
    pcall(ext_vscode.type_to_filetypes, type_name, fts)
  end

  local map = function(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { desc = 'DAP: ' .. desc, silent = true })
  end
  local vmap = function(lhs, rhs, desc)
    vim.keymap.set({ 'n', 'v' }, lhs, rhs, { desc = 'DAP: ' .. desc, silent = true })
  end

  map('<F5>', dap.continue, 'Continue / start')
  map('<F10>', dap.step_over, 'Step over')
  map('<F11>', dap.step_into, 'Step into')
  map('<F12>', dap.step_out, 'Step out')
  map('<S-F5>', dap.terminate, 'Terminate')

  map('<leader>Xc', dap.continue, 'Continue / start')
  map('<leader>Xn', dap.step_over, 'Step over')
  map('<leader>Xi', dap.step_into, 'Step into')
  map('<leader>Xo', dap.step_out, 'Step out')
  map('<leader>Xb', dap.toggle_breakpoint, 'Toggle breakpoint')
  map('<leader>XB', function() dap.set_breakpoint(vim.fn.input('Condition: ')) end, 'Conditional breakpoint')
  map('<leader>Xl', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log message: ')) end, 'Log point')
  map('<leader>XL', dap.run_last, 'Run last')
  map('<leader>Xr', dap.repl.toggle, 'Toggle REPL')
  map('<leader>Xt', dap.terminate, 'Terminate session')
  map('<leader>Xq', function() dap.clear_breakpoints(); dap.terminate() end, 'Clear breakpoints + quit')
  map('<leader>Xu', dapui.toggle, 'Toggle DAP UI')
  map('<leader>Xh', function() dapui.eval(nil, { enter = true }) end, 'Hover eval (under cursor)')
  vmap('<leader>Xe', function() dapui.eval(nil, { enter = true }) end, 'Eval expression')
  map('<leader>Xj', dap.down, 'Stack down')
  map('<leader>Xk', dap.up, 'Stack up')
end

return M
