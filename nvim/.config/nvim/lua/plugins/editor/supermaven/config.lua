local M = {}

M.opts = {
  -- Keymaps for AI completion suggestions
  keymaps = {
    accept_suggestion = '<Tab>',
    clear_suggestion = '<C-]>',
    -- accept only the next word of the suggestion
    accept_word = '<C-j>',
  },
  -- list of filetypes to skip (e.g. { "markdown" })
  ignore_filetypes = {},
  -- true: hide inline ghost text completions
  disable_inline_completion = false,
  -- true: don't register any keymaps above
  disable_keymaps = false,
  -- return true to disable supermaven conditionally
  condition = function()
    return false
  end,
  -- ghost text color; cterm 244 = medium grey
  color = { cterm = 244 },
  -- 'info' | 'debug' | 'warn' | 'error'
  log_level = 'info',
}

return M
