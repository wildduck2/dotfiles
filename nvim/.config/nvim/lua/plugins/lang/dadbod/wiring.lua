-- Pushes connection state to the two consumers we drive:
--   * vim-dadbod / dadbod-ui via vim.g.dbs / vim.g.db / b:db.
--   * duck-sqllsp via workspace/didChangeConfiguration whenever the active
--     connection or scope changes. duck-sqllsp consumes the connection
--     list out of `initializationOptions.duckSqllsp.connections` on attach,
--     and accepts the same shape over didChangeConfiguration to update
--     while running.

local store = require('plugins.lang.dadbod.store')
local urls = require('plugins.lang.dadbod.urls')

local M = {}

function M.refresh_dadbod()
  local dbs = {}
  for _, c in ipairs(store.state.connections) do
    table.insert(dbs, { name = c.name, url = urls.to_dadbod(c) })
  end
  vim.g.dbs = dbs
  local active = store.get_active()
  if active then
    local url = urls.to_dadbod(active)
    vim.g.db = url
    pcall(function()
      vim.b.db = url
    end)
  end
end

-- Build the connection list duck-sqllsp accepts. The server reads the
-- shape `{ connections, activeConnection, scope }` so we ship exactly that.
local function build_settings()
  local conns = {}
  for _, c in ipairs(store.state.connections) do
    table.insert(conns, {
      name = c.name,
      driver = c.driver,
      host = c.host,
      port = c.port and tonumber(c.port) or nil,
      user = c.user,
      password = c.password,
      database = c.database,
      schema = c.schema,
    })
  end
  return {
    duckSqllsp = {
      connections = conns,
      activeConnection = store.state.active,
      scope = store.state.scope,
    },
  }
end

function M.refresh_duck_sqllsp()
  local clients = vim.lsp.get_clients({ name = 'duck_sqllsp' })
  if #clients == 0 then
    return false
  end
  local settings = build_settings()
  for _, client in ipairs(clients) do
    client.settings = vim.tbl_deep_extend('force', client.settings or {}, settings)
    client:notify('workspace/didChangeConfiguration', { settings = client.settings })
  end
  return true
end

-- Build the table to pass as initializationOptions when the server starts.
-- Called from lspconfig before the client launches.
function M.initialization_options()
  return build_settings()
end

return M
