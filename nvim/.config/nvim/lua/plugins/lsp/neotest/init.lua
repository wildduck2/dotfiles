-- Eager: pre-discovery signs so the user sees a test exists the moment
-- a rust/cpp/c file opens, without loading the heavy neotest plugin.
-- The autocmd is cheap (regex scan + sign placement).
require('plugins.lsp.neotest.pre_signs').setup()

return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',

      -- Adapters
      'nvim-neotest/neotest-jest',
      'marilari88/neotest-vitest',
      'nvim-neotest/neotest-python',
      'nvim-neotest/neotest-go',
      -- neotest-rust: removed (table index is nil bug at init.lua:414).
      -- Rust tests via DAP directly: <F5> -> "Launch (pick binary)" ->
      -- target/debug/deps/<crate>-<hash> + args like "test_name --exact".
      'jfpedroza/neotest-elixir',
    },
    config = function()
      require('plugins.lsp.neotest.config').setup()
    end,
    keys = {
      { '<leader>Tt', function() require('neotest').run.run(vim.fn.expand('%')) end,                         desc = 'Neotest: run file' },
      { '<leader>TT', function() require('neotest').run.run(vim.uv.cwd()) end,                               desc = 'Neotest: run all files' },
      { '<leader>Tr', function() require('neotest').run.run() end,                                           desc = 'Neotest: run nearest' },
      { '<leader>Tl', function() require('neotest').run.run_last() end,                                      desc = 'Neotest: run last' },
      { '<leader>Td', function() require('neotest').run.run({ strategy = 'dap' }) end,                       desc = 'Neotest: debug nearest (DAP)' },
      { '<leader>TD', function() require('neotest').run.run_last({ strategy = 'dap' }) end,                  desc = 'Neotest: debug last (DAP)' },
      { '<leader>Ts', function() require('neotest').summary.toggle() end,                                    desc = 'Neotest: summary panel' },
      { '<leader>To', function() require('neotest').output.open({ enter = true, auto_close = true }) end,    desc = 'Neotest: output (current)' },
      {
        '<leader>TO',
        function()
          local nt = require('neotest')
          -- Clear the output-panel buffer before opening so the user sees
          -- only the latest run's output, never stale text from prior runs.
          -- Skip clearing when the panel is already visible (don't nuke
          -- output mid-run).
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local name = vim.api.nvim_buf_get_name(buf)
            if name:match('[Nn]eotest [Oo]utput [Pp]anel') or name:match('neotest%-output%-panel') then
              local visible = false
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == buf then visible = true; break end
              end
              if not visible and vim.api.nvim_buf_is_valid(buf) then
                pcall(function()
                  vim.bo[buf].modifiable = true
                  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
                end)
              end
            end
          end
          nt.output_panel.toggle()
        end,
        desc = 'Neotest: output panel (clean reopen)',
      },
      { '<leader>TS', function() require('neotest').run.stop() end,                                          desc = 'Neotest: stop' },
      { '<leader>Tw', function() require('neotest').watch.toggle(vim.fn.expand('%')) end,                    desc = 'Neotest: watch file' },
      { '[t',        function() require('neotest').jump.prev({ status = 'failed' }) end,                     desc = 'Neotest: prev failed' },
      { ']t',        function() require('neotest').jump.next({ status = 'failed' }) end,                     desc = 'Neotest: next failed' },
    },
  },
}
