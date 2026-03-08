local M = {}

function M.setup()
  require('gitsigns').setup {
    -- Sign column symbols for each diff type
    signs = {
      add = { text = '+' }, -- new lines
      change = { text = '~' }, -- modified lines
      delete = { text = '_' }, -- removed lines
      topdelete = { text = '‾' }, -- deleted at file start
      changedelete = { text = '~' }, -- changed then deleted
    },
    -- true=show signs for staged hunks too
    signs_staged_enable = true,
    -- true=show signs in sign column; false=hide them
    signcolumn = true,
    -- true=highlight line numbers for changed lines
    numhl = false,
    -- true=highlight full line background for changes
    linehl = false,
    -- true=highlight cursorline sign column
    culhl = false,
    -- true=show virtual lines for deleted text
    show_deleted = false,
    -- Higher value=shown over lower-priority signs
    sign_priority = 6,
    -- true=auto attach to git-tracked buffers
    auto_attach = true,
    -- true=show signs for untracked (new) files
    attach_to_untracked = false,
    -- ms delay before updating signs after change
    update_debounce = 100,
    -- Disable gitsigns for files exceeding this many lines
    max_file_length = 40000,
    -- true=highlight individual word diffs inline
    word_diff = false,
    -- true=show blame for current line as virtual text
    current_line_blame = false,

    -- Inline blame display options
    current_line_blame_opts = {
      -- true=render as virtual text; false=disable
      virt_text = true,
      -- 'eol'|'overlay'|'right_align' position of text
      virt_text_pos = 'eol',
      -- Higher=shown over lower-priority virtual text
      virt_text_priority = 100,
      -- ms before blame appears after cursor move
      delay = 1000,
      -- true=only show blame when window is focused
      use_focus = true,
    },
    -- Format string for blame; placeholders: author, time, summary
    current_line_blame_formatter = ' <author>, <author_time:%R> - <summary> ',
    -- Format when cursor is not on a committed line
    current_line_blame_formatter_nc = ' <author>',

    -- Floating preview window style for hunk previews
    preview_config = {
      border = 'rounded',
      style = 'minimal',
      relative = 'cursor',
      row = 0,
      col = 1,
    },

    -- Watch .git dir for external changes (e.g. CLI)
    watch_gitdir = {
      -- true=auto refresh signs on .git dir changes
      enable = true,
      -- true=update when file is moved/renamed
      follow_files = true,
    },
    -- Runs when gitsigns attaches to a buffer
    on_attach = function(bufnr)
      local gitsigns = require 'gitsigns'
      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation: jump between hunks (or diff changes)
      map('n', ']c', function()
        if vim.wo.diff then
          -- Use native diff jump in diff mode
          vim.cmd.normal { ']c', bang = true }
        else
          gitsigns.nav_hunk 'next'
        end
      end)
      map('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal { '[c', bang = true }
        else
          gitsigns.nav_hunk 'prev'
        end
      end)

      -- Actions: stage, reset, preview, blame, diff
      map('n', '<leader>hs', gitsigns.stage_hunk) -- stage hunk under cursor
      map('n', '<leader>hr', gitsigns.reset_hunk) -- discard hunk under cursor
      -- Visual mode: stage/reset selected line range
      map('v', '<leader>hs', function()
        gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end)
      map('v', '<leader>hr', function()
        gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end)
      map('n', '<leader>hS', gitsigns.stage_buffer) -- stage entire buffer
      map('n', '<leader>hu', gitsigns.undo_stage_hunk) -- unstage last staged hunk
      map('n', '<leader>hR', gitsigns.reset_buffer) -- discard all changes in buffer
      map('n', '<leader>hp', gitsigns.preview_hunk) -- floating preview of hunk diff
      -- Show full commit blame for current line
      map('n', '<leader>hb', function()
        gitsigns.blame_line { full = true }
      end)
      map('n', '<leader>tb', gitsigns.toggle_current_line_blame) -- toggle inline blame
      map('n', '<leader>hd', gitsigns.diffthis) -- diff buffer vs index (staged)
      -- Diff buffer vs previous commit (~)
      map('n', '<leader>hD', function()
        gitsigns.diffthis '~'
      end)
      map('n', '<leader>td', gitsigns.toggle_deleted) -- toggle deleted lines display
      -- Text object: select hunk (for operators/visual)
      map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    end,
  }
end

return M
