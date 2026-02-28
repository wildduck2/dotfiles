local M = {}

M = {
  'diagnostics',

  -- Table of diagnostic sources, available sources are:
  --   'nvim_lsp', 'nvim_diagnostic', 'nvim_workspace_diagnostic', 'coc', 'ale', 'vim_lsp'.
  -- or a function that returns a table as such:
  --   { error=error_cnt, warn=warn_cnt, info=info_cnt, hint=hint_cnt }
  sources = { 'nvim_diagnostic', 'coc' },

  -- Displays diagnostics for the defined severity types
  sections = { 'error', 'warn', 'info', 'hint' },

  -- WARN: removed the because they make diff in colors
  -- diagnostics_color = {
  --     -- Same values as the general color option can be used here.
  --     error = 'DiagnosticError', -- Changes diagnostics' error color.
  --     warn  = 'DiagnosticWarn',  -- Changes diagnostics' warn color.
  --     info  = 'DiagnosticInfo',  -- Changes diagnostics' info color.
  --     hint  = 'DiagnosticHint',  -- Changes diagnostics' hint color.
  -- },
  symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' },
  colored = true, -- Displays diagnostics status in color if set to true.
  update_in_insert = false, -- Update diagnostics in insert mode.
  always_visible = false, -- Show diagnostics even if there are none.
}

return M
