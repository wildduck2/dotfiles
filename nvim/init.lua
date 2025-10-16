require 'wild-duck'
require 'configs'

local orig_notify = vim.notify
vim.notify = function(msg, level, opts)
  if type(msg) == 'string' and msg:match 'lspconfig' then
    vim.schedule(function()
      orig_notify('(suppressed) ' .. msg, vim.log.levels.DEBUG, opts)
    end)
    return
  end
  return orig_notify(msg, level, opts)
end
