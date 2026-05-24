-- Persistent connection store.
--
-- Two JSON files under stdpath('data'):
--   db_connections.json  list of {name, driver, host, port, user, password, database, schema}
--   db_active.json       { active = name, scope = 'all'|'db'|'schema' }
--
-- Connections file holds plaintext credentials; chmod'd to 0600.

local M = {}

local uv = vim.uv or vim.loop

M.connections_path = vim.fn.stdpath('data') .. '/db_connections.json'
M.active_path = vim.fn.stdpath('data') .. '/db_active.json'

M.state = {
  connections = {},
  active = nil,
  scope = 'all',
}

local function read_json(path)
  local fd = io.open(path, 'r')
  if not fd then return nil end
  local raw = fd:read('*a')
  fd:close()
  if not raw or raw == '' then return nil end
  local ok, decoded = pcall(vim.json.decode, raw)
  if not ok then return nil end
  return decoded
end

local function write_json(path, value, mode)
  local raw = vim.json.encode(value)
  local fd = io.open(path, 'w')
  if not fd then return false end
  fd:write(raw)
  fd:close()
  if mode and uv and uv.fs_chmod then
    pcall(uv.fs_chmod, path, mode)
  end
  return true
end

function M.load()
  local conns = read_json(M.connections_path)
  if type(conns) == 'table' then M.state.connections = conns end
  local active = read_json(M.active_path)
  if type(active) == 'table' then
    M.state.active = active.active
    M.state.scope = active.scope or 'all'
  end
end

function M.persist()
  -- 384 == 0o600 (owner read/write only). Passwords live here.
  write_json(M.connections_path, M.state.connections, 384)
  write_json(M.active_path, { active = M.state.active, scope = M.state.scope })
end

function M.get_active()
  if not M.state.active then return nil end
  for _, c in ipairs(M.state.connections) do
    if c.name == M.state.active then return c end
  end
  return nil
end

function M.is_unique(name)
  for _, c in ipairs(M.state.connections) do
    if c.name == name then return false end
  end
  return true
end

return M
