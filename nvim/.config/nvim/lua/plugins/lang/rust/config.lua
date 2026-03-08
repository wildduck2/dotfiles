local M = {}

function M.setup()
  vim.g.rustaceanvim = {
    -- Rust-specific tooling settings
    tools = {
      -- how to run runnables (terminal | background | toggleterm)
      executor = 'toggleterm',
      -- how to run tests (background shows failures as diagnostics)
      test_executor = 'background',
      -- auto-focus the hover actions window
      hover_actions = { auto_focus = true },
      -- use grouped code actions with fallback to vim.ui.select
      code_actions = { ui_select_fallback = true },
    },
    -- rust-analyzer LSP server settings
    server = {
      -- runs when rust-analyzer attaches to a buffer
      on_attach = function(_, bufnr)
        local opts = function(desc)
          return { buffer = bufnr, silent = true, desc = 'Rust: ' .. desc }
        end
        -- Rust-specific keymaps (only active in rust buffers)
        vim.keymap.set('n', '<leader>ca', function() vim.cmd.RustLsp 'codeAction' end, opts '[C]ode [A]ction (grouped)')
        vim.keymap.set('n', 'K', function() vim.cmd.RustLsp { 'hover', 'actions' } end, opts 'Hover actions')
        vim.keymap.set('n', '<leader>rd', function() vim.cmd.RustLsp 'debuggables' end, opts '[R]ust [D]ebuggables')
        vim.keymap.set('n', '<leader>rr', function() vim.cmd.RustLsp 'runnables' end, opts '[R]ust [R]unnables')
        vim.keymap.set('n', '<leader>rt', function() vim.cmd.RustLsp 'testables' end, opts '[R]ust [T]estables')
        vim.keymap.set('n', '<leader>rm', function() vim.cmd.RustLsp 'expandMacro' end, opts '[R]ust expand [M]acro')
        vim.keymap.set('n', '<leader>rc', function() vim.cmd.RustLsp 'openCargo' end, opts '[R]ust open [C]argo.toml')
        vim.keymap.set('n', '<leader>rp', function() vim.cmd.RustLsp 'parentModule' end, opts '[R]ust [P]arent module')
        vim.keymap.set('n', '<leader>rj', function() vim.cmd.RustLsp 'joinLines' end, opts '[R]ust [J]oin lines')
        vim.keymap.set('n', '<leader>re', function() vim.cmd.RustLsp 'explainError' end, opts '[R]ust [E]xplain error')
        vim.keymap.set('n', '<leader>rD', function() vim.cmd.RustLsp 'renderDiagnostic' end, opts '[R]ust render [D]iagnostic')
        vim.keymap.set('n', '<leader>rk', function() vim.cmd.RustLsp { 'moveItem', 'up' } end, opts '[R]ust move item up')
        vim.keymap.set('n', '<leader>rl', function() vim.cmd.RustLsp { 'moveItem', 'down' } end, opts '[R]ust move item down')
        vim.keymap.set('n', '<leader>rH', function() vim.cmd.RustLsp { 'view', 'hir' } end, opts '[R]ust view [H]IR')
        vim.keymap.set('n', '<leader>rM', function() vim.cmd.RustLsp { 'view', 'mir' } end, opts '[R]ust view [M]IR')
      end,
      -- rust-analyzer configuration
      default_settings = {
        ['rust-analyzer'] = {
          -- show all compiler warnings
          diagnostics = { enable = true },
          -- run clippy on save instead of check (stricter linting)
          checkOnSave = true,
          check = { command = 'clippy' },
          -- enable proc macro support
          procMacro = { enable = true },
          -- show inlay hints for types, params, chaining, etc.
          inlayHints = {
            chainingHints = { enable = true },
            typeHints = { enable = true },
            parameterHints = { enable = true },
          },
          cargo = {
            -- build with all features enabled
            allFeatures = true,
            -- load out-of-tree crates (e.g. path deps)
            loadOutDirsFromCheck = true,
          },
        },
      },
    },
  }
end

return M
