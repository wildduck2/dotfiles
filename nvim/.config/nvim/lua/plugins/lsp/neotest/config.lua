local M = {}

function M.setup()
  -- Distinct sign glyphs for test status. Render in any terminal.
  vim.api.nvim_set_hl(0, 'NeotestPassed',  { fg = '#98c379' })   -- green
  vim.api.nvim_set_hl(0, 'NeotestFailed',  { fg = '#e06c75' })   -- red
  vim.api.nvim_set_hl(0, 'NeotestRunning', { fg = '#61afef' })   -- blue
  vim.api.nvim_set_hl(0, 'NeotestSkipped', { fg = '#5c6370' })   -- grey

  vim.diagnostic.config({
    virtual_text = {
      format = function(diagnostic)
        return diagnostic.message
      end,
    },
  }, vim.api.nvim_create_namespace('neotest'))

  require('neotest').setup({
    adapters = {
      require('neotest-jest')({
        jestCommand = 'npx jest --',
        jestConfigFile = function()
          local file = vim.fn.expand('%:p')
          if string.find(file, '/packages/') then
            return string.match(file, '(.-/[^/]+/)src') .. 'jest.config.ts'
          end
          return vim.fn.getcwd() .. '/jest.config.js'
        end,
        env = { CI = true },
        cwd = function() return vim.fn.getcwd() end,
      }),
      require('neotest-vitest')({
        filter_dir = function(name) return name ~= 'node_modules' end,
      }),
      require('neotest-python')({
        runner = 'pytest',
        dap = { justMyCode = false },
      }),
      require('neotest-go'),
      require('neotest-elixir'),
      require('plugins.lsp.neotest.adapters.gtest')({
        -- binary = function(file) return ... end,  -- override here per project
      }),
      require('plugins.lsp.neotest.adapters.rust')({}),
    },

    -- Test discovery + summary panel layout
    discovery = { enabled = true, concurrent = 1 },
    running = { concurrent = true },
    summary = {
      enabled = true,
      animated = true,
      follow = true,
      expand_errors = true,
      mappings = {
        attach = 'a',
        clear_marked = 'M',
        clear_target = 'T',
        debug = 'd',
        debug_marked = 'D',
        expand = { '<CR>', '<2-LeftMouse>' },
        expand_all = 'e',
        jumpto = 'i',
        mark = 'm',
        next_failed = 'J',
        output = 'o',
        prev_failed = 'K',
        run = 'r',
        run_marked = 'R',
        short = 'O',
        stop = 'u',
        target = 't',
        watch = 'w',
      },
    },
    output = { enabled = true, open_on_run = false },
    output_panel = { enabled = true, open = 'botright split | resize 15' },
    quickfix = { enabled = true, open = false },

    -- signs = gutter glyph (left side). virtual_text=false avoids the
    -- extra × at end-of-line; diagnostic (below) already shows the error
    -- message inline.
    status = { enabled = true, signs = true, virtual_text = false },
    icons = {
      passed = '✓',
      failed = '✗',
      running = '◍',
      skipped = '○',
      unknown = '?',
      running_animated = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
      child_indent = '│',
      child_prefix = '├',
      final_child_indent = ' ',
      final_child_prefix = '╰',
      non_collapsible = '─',
      collapsed = '─',
      expanded = '╮',
      watching = '👁',
      notify = '',
    },
    floating = { border = 'rounded', max_height = 0.8, max_width = 0.8, options = {} },
    diagnostic = { enabled = true, severity = vim.diagnostic.severity.ERROR },
  })

  -- Pretty sign glyphs that match the icons table above
  vim.fn.sign_define('neotest_passed',  { text = '✓', texthl = 'NeotestPassed',  numhl = 'NeotestPassed' })
  vim.fn.sign_define('neotest_failed',  { text = '✗', texthl = 'NeotestFailed',  numhl = 'NeotestFailed' })
  vim.fn.sign_define('neotest_running', { text = '◍', texthl = 'NeotestRunning', numhl = 'NeotestRunning' })
  vim.fn.sign_define('neotest_skipped', { text = '○', texthl = 'NeotestSkipped', numhl = 'NeotestSkipped' })
end

return M
