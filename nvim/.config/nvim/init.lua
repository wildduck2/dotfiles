require 'wild-duck'

-- One-shot suppression of lspconfig startup messages
-- Restores original vim.notify after startup completes
local orig_notify = vim.notify
vim.notify = function(msg, level, opts)
  if type(msg) == 'string' and msg:match 'lspconfig' then
    return
  end
  return orig_notify(msg, level, opts)
end
vim.defer_fn(function()
  vim.notify = orig_notify
end, 1000)
