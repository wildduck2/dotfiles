local M = {}

M.opts = {
  keymaps = {
    accept_suggestion = '<Tab>',
    clear_suggestion = '<C-]>',
    accept_word = '<C-j>',
  },
  ignore_filetypes = {},
  color = { cterm = 244 },
  log_level = 'info',
  disable_inline_completion = false,
  disable_keymaps = false,
}

function M.setup()
  require('supermaven-nvim').setup(M.opts)
end

return M
