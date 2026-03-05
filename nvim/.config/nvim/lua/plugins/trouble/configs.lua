local M = {}

M.signs = {
  error = '', warning = '', hint = '', information = '', other = '',
}

M.action_keys = {
  close = 'q',
  cancel = '<esc>',
  refresh = 'r',
  jump = { '<cr>', '<tab>', '<2-leftmouse>' },
  open_split = { '<c-x>' },
  open_vsplit = { '<c-v>' },
  open_tab = { '<c-t>' },
  jump_close = { 'o' },
  toggle_mode = 'm',
  switch_severity = 's',
  toggle_preview = 'P',
  hover = 'K',
  preview = 'p',
  open_code_href = 'c',
  close_folds = { 'zM', 'zm' },
  open_folds = { 'zR', 'zr' },
  toggle_fold = { 'zA', 'za' },
  previous = 'k',
  next = 'j',
  help = '?',
}

function M.setup()
  require('trouble').setup {
    position = 'bottom',
    height = 10,
    width = 50,
    mode = 'workspace_diagnostics',
    severity = nil,
    fold_open = '',
    fold_closed = '',
    group = true,
    padding = true,
    cycle_results = true,
    action_keys = M.action_keys,
    multiline = true,
    indent_lines = true,
    win_config = { border = 'single' },
    auto_open = false,
    auto_close = false,
    auto_preview = true,
    auto_fold = false,
    auto_jump = { 'lsp_definitions' },
    include_declaration = { 'lsp_references', 'lsp_implementations', 'lsp_definitions' },
    signs = M.signs,
    use_diagnostic_signs = false,
    telescope = { theme = 'dropdown' },
  }

  -- Keymaps
  vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Diagnostics (Trouble)' })
  vim.keymap.set('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = 'Buffer Diagnostics (Trouble)' })
  vim.keymap.set('n', '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', { desc = 'Symbols (Trouble)' })
  vim.keymap.set('n', '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', { desc = 'LSP Definitions / references /... (Trouble)' })
  vim.keymap.set('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>', { desc = 'Location List (Trouble)' })
  vim.keymap.set('n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', { desc = 'Quickfix List (Trouble)' })
end

return M
