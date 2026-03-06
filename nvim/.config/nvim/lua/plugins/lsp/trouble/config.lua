local M = {}

function M.setup()
  require('trouble').setup {
    -- 'bottom'|'top'|'left'|'right' panel position
    position = 'bottom',
    -- Panel height in rows (when bottom/top)
    height = 10,
    -- Panel width in cols (when left/right)
    width = 50,
    -- Default mode (alt: 'document_diagnostics', etc.)
    mode = 'workspace_diagnostics',
    -- nil = show all severities; can filter to ERROR, etc.
    severity = nil,
    -- Nerd font icons for open/closed fold indicators
    fold_open = '',
    fold_closed = '',
    -- true = group results by file
    group = true,
    -- true = add spacing around items
    padding = true,
    -- true = wrap around when navigating past last item
    cycle_results = true,

    -- Keybindings inside the Trouble window
    action_keys = {
      close = 'q',
      cancel = '<esc>',
      refresh = 'r',
      jump = { '<cr>', '<tab>', '<2-leftmouse>' },
      open_split = { '<c-x>' },
      open_vsplit = { '<c-v>' },
      open_tab = { '<c-t>' },
      -- Jump to item and close Trouble window
      jump_close = { 'o' },
      -- Cycle between workspace/document diagnostics
      toggle_mode = 'm',
      -- Cycle severity filter (error/warn/info/hint)
      switch_severity = 's',
      toggle_preview = 'P',
      hover = 'K',
      preview = 'p',
      -- Open URL from diagnostic code
      open_code_href = 'c',
      close_folds = { 'zM', 'zm' },
      open_folds = { 'zR', 'zr' },
      toggle_fold = { 'zA', 'za' },
      previous = 'k',
      next = 'j',
      help = '?',
    },

    -- true = show multi-line diagnostic messages
    multiline = true,
    -- true = draw indent guide lines in tree view
    indent_lines = true,
    -- Border style (alt: 'rounded','double','none')
    win_config = { border = 'single' },
    -- false = don't open Trouble automatically
    auto_open = false,
    -- false = don't close when no more diagnostics
    auto_close = false,
    -- true = auto-show preview of selected item
    auto_preview = true,
    -- false = don't auto-fold file groups
    auto_fold = false,
    -- Auto-jump to item for these modes (skip list)
    auto_jump = { 'lsp_definitions' },
    -- Include declarations in these LSP result modes
    include_declaration = { 'lsp_references', 'lsp_implementations', 'lsp_definitions' },
    -- Custom nerd font icons per severity level
    signs = {
      error = '', warning = '', hint = '', information = '', other = '',
    },
    -- false = use custom signs above; true = use vim diag
    use_diagnostic_signs = false,
    -- Telescope integration picker theme
    telescope = { theme = 'dropdown' },
  }

  -- Trouble keymaps (normal mode, global)
  vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Diagnostics (Trouble)' })
  vim.keymap.set('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = 'Buffer Diagnostics (Trouble)' })
  vim.keymap.set('n', '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', { desc = 'Symbols (Trouble)' })
  vim.keymap.set('n', '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', { desc = 'LSP Definitions / references /... (Trouble)' })
  vim.keymap.set('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>', { desc = 'Location List (Trouble)' })
  vim.keymap.set('n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', { desc = 'Quickfix List (Trouble)' })
end

return M
