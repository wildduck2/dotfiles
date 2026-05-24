local M = {}

function M.setup()
  local dap = require('dap')
  local dapui = require('dapui')

  require('mason-nvim-dap').setup({
    automatic_installation = true,
    handlers = {},
  })

  -- Mason-tool-installer is owned by lspconfig and we cannot re-call its
  -- setup without clobbering the LSP list. Use mason-registry directly so
  -- every DAP package is fetched on first nvim load and any time the list
  -- below changes. Runs after VeryLazy so mason itself is ready.
  local dap_packages = {
    'codelldb',          -- rust / c / c++
    'js-debug-adapter',  -- node / chrome (vscode-js-debug)
    'delve',             -- go
    'debugpy',           -- python
    'elixir-ls',         -- elixir (LSP + debug adapter in one package)
  }

  local ok_reg, registry = pcall(require, 'mason-registry')
  if ok_reg then
    local function install_missing()
      for _, name in ipairs(dap_packages) do
        local ok_pkg, pkg = pcall(registry.get_package, name)
        if ok_pkg and not pkg:is_installed() then
          pkg:install()
        end
      end
    end
    if registry.refresh then
      registry.refresh(install_missing)
    else
      install_missing()
    end
  end

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

  -- Use filled-circle glyphs that render in any terminal (no nerd font
  -- needed). Distinct colors per state so you can see at a glance.
  vim.api.nvim_set_hl(0, 'DapBreakpointSign', { fg = '#e06c75' })           -- red
  vim.api.nvim_set_hl(0, 'DapBreakpointCondSign', { fg = '#e5c07b' })       -- yellow
  vim.api.nvim_set_hl(0, 'DapLogPointSign', { fg = '#61afef' })             -- blue
  vim.api.nvim_set_hl(0, 'DapStoppedSign', { fg = '#98c379' })              -- green
  vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#31353f' })              -- subtle line bg
  vim.api.nvim_set_hl(0, 'DapBreakpointRejectedSign', { fg = '#5c6370' })   -- grey

  vim.fn.sign_define('DapBreakpoint',          { text = '●', texthl = 'DapBreakpointSign',         numhl = 'DapBreakpointSign' })
  vim.fn.sign_define('DapBreakpointCondition', { text = '●', texthl = 'DapBreakpointCondSign',     numhl = 'DapBreakpointCondSign' })
  vim.fn.sign_define('DapLogPoint',            { text = '◆', texthl = 'DapLogPointSign',           numhl = 'DapLogPointSign' })
  vim.fn.sign_define('DapStopped',             { text = '▶', texthl = 'DapStoppedSign', linehl = 'DapStoppedLine', numhl = 'DapStoppedSign' })
  vim.fn.sign_define('DapBreakpointRejected',  { text = '○', texthl = 'DapBreakpointRejectedSign', numhl = 'DapBreakpointRejectedSign' })

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
