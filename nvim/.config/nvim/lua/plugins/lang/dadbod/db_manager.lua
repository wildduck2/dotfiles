-- DB Manager orchestrator.
--
-- Sub-modules:
--   store.lua     persistent connections + active state on disk
--   urls.lua      dadbod URL + duck-sqllsp connection spec builders
--   wiring.lua    push state into vim-dadbod / duck-sqllsp LSP
--   ui.lua        notify, picker, prompt-chain, list modal
--   commands.lua  :DB* user commands and keymaps
--
-- Completion / hover / format / diagnostics for SQL come from the
-- duck-sqllsp language server (binary expected at `duck-sqllsp` in PATH).
-- See docs/plugins/lang/dadbod/README.md for the full setup.

local store = require 'plugins.lang.dadbod.store'
local wiring = require 'plugins.lang.dadbod.wiring'
local commands = require 'plugins.lang.dadbod.commands'

local M = {}

function M.setup()
  store.load()
  commands.register()

  -- Make sure duck-sqllsp gets the connection list as soon as it launches.
  -- vim.lsp.config merges with the base config registered in lspconfig.
  pcall(vim.lsp.config, 'duck_sqllsp', {
    init_options = wiring.initialization_options(),
  })

  -- Push connections into dadbod-ui at startup so the sidebar shows them
  -- on first open. Deferred to keep startup itself synchronous-cheap.
  vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = function()
      vim.defer_fn(function() wiring.refresh_dadbod() end, 0)
    end,
  })

  -- Each time duck-sqllsp attaches to a buffer, re-push the connection
  -- list so the server's catalog reflects DBAdd/Edit/Switch changes
  -- made before the LSP started.
  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client and client.name == 'duck_sqllsp' then
        wiring.refresh_duck_sqllsp()
      end
    end,
  })
end

return M
