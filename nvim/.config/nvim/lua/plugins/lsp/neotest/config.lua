local M = {}

function M.setup()
  -- Distinct sign glyphs for test status. Render in any terminal.
  vim.api.nvim_set_hl(0, 'NeotestPassed',  { fg = '#98c379' })   -- green
  vim.api.nvim_set_hl(0, 'NeotestFailed',  { fg = '#e06c75' })   -- red
  vim.api.nvim_set_hl(0, 'NeotestRunning', { fg = '#61afef' })   -- blue
  vim.api.nvim_set_hl(0, 'NeotestSkipped', { fg = '#5c6370' })   -- grey

  -- Per-namespace diagnostic config for neotest. Override at the namespace
  -- level so global vim.diagnostic.config (lspconfig owns it) is untouched.
  local ns = vim.api.nvim_create_namespace('neotest')
  vim.diagnostic.config({
    virtual_text = {
      spacing = 4,
      prefix = '■',
      severity = { min = vim.diagnostic.severity.HINT },
      format = function(d)
        return (d.message or ''):gsub('\n', ' '):sub(1, 200)
      end,
    },
    underline = true,
    severity_sort = true,
    signs = false,  -- the test ✗/✓ glyph already lives in the signcolumn
  }, ns)

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
    -- Plain unicode glyphs that render in any font (the nerd-font
    -- codepoints showed up as blank cells in some terminals — defeating
    -- the purpose of having a status sign).
    icons = {
      passed             = '✓',
      failed             = '✗',
      running            = '●',
      skipped            = '○',
      unknown            = '◌',
      running_animated   = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
      child_indent       = '│',
      child_prefix       = '├',
      final_child_indent = ' ',
      final_child_prefix = '╰',
      non_collapsible    = '─',
      collapsed          = '─',
      expanded           = '╮',
      watching           = '◉',
      notify             = '!',
    },
    floating = { border = 'rounded', max_height = 0.8, max_width = 0.8, options = {} },
    diagnostic = { enabled = true, severity = vim.diagnostic.severity.ERROR },
  })

  -- neotest defines neotest_passed/failed/running/skipped internally
  -- from the icons table above; do not override those here (overriding
  -- can race the consumer init and end up with wrong highlights).
  -- 'neotest_ready' is OUR custom sign and is defined by pre_signs.lua.

  -- Debug helper: show what neotest knows about the current buffer.
  vim.api.nvim_create_user_command('NeotestDebug', function()
    local file = vim.api.nvim_buf_get_name(0)
    local nt = require('neotest')
    local lines = { 'file: ' .. file }
    local adapters = nt.state.adapter_ids and nt.state.adapter_ids() or {}
    table.insert(lines, 'adapters loaded: ' .. table.concat(adapters, ', '))

    local results = nt.state.results() or {}
    local count = 0
    for k, v in pairs(results) do
      if k:find(file, 1, true) then
        count = count + 1
        if count <= 5 then table.insert(lines, ('  %s -> %s'):format(k:sub(-60), v.status or '?')) end
      end
    end
    table.insert(lines, ('results for this file: %d'):format(count))

    local signs = vim.fn.sign_getplaced(file, { group = '*' })[1]
    local n = signs and #signs.signs or 0
    table.insert(lines, ('signs placed: %d'):format(n))
    if n > 0 then
      for i = 1, math.min(n, 5) do
        table.insert(lines, ('  line %d -> %s'):format(signs.signs[i].lnum, signs.signs[i].name))
      end
    end

    vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
  end, { desc = 'Dump neotest state for current buffer' })
end

return M
