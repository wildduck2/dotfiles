-- User commands and keymaps for the DB manager.
--
-- Side effects live in store + wiring; this module just stitches them
-- together with the picker UI in ui.lua. Completion / hover / format
-- are now provided by duck-sqllsp over LSP; we only push the connection
-- list to that server here.

local store = require 'plugins.lang.dadbod.store'
local wiring = require 'plugins.lang.dadbod.wiring'
local ui = require 'plugins.lang.dadbod.ui'

local M = {}

function M.add()
  local drivers = { 'postgresql', 'mysql', 'sqlite3' }
  vim.ui.select(drivers, { prompt = 'Driver:' }, function(driver)
    if not driver then return end
    local steps = { { key = 'name', prompt = 'Connection name: ' } }
    if driver == 'sqlite3' then
      table.insert(steps, { key = 'database', prompt = 'SQLite file path: ' })
    else
      table.insert(steps, { key = 'host', prompt = 'Host: ', default = '127.0.0.1' })
      table.insert(steps, { key = 'port', prompt = 'Port: ', default = driver == 'mysql' and '3306' or '5432' })
      table.insert(steps, { key = 'user', prompt = 'User: ' })
      table.insert(steps, { key = 'password', prompt = 'Password: ', hidden = true, optional = true })
      table.insert(steps, { key = 'database', prompt = 'Database: ' })
      table.insert(steps, { key = 'schema', prompt = 'Default schema (optional): ', optional = true })
    end
    ui.prompt_chain(steps, function(acc)
      if not acc.name or acc.name == '' then return end
      if not store.is_unique(acc.name) then
        ui.error_modal({ 'Name already exists: ' .. acc.name })
        return
      end
      acc.driver = driver
      table.insert(store.state.connections, acc)
      store.persist()
      wiring.refresh_dadbod()
      wiring.refresh_duck_sqllsp()
      ui.info('Added connection ' .. acc.name)
    end)
  end)
end

function M.edit()
  ui.pick_connection('Edit connection:', function(conn, idx)
    local steps = {}
    local function add(key, label, hidden)
      table.insert(steps, {
        key = key,
        prompt = label .. ' [' .. (conn[key] or '') .. ']: ',
        default = conn[key] or '',
        optional = true,
        hidden = hidden,
      })
    end
    add('name', 'Name')
    if conn.driver ~= 'sqlite3' and conn.driver ~= 'sqlite' then
      add('host', 'Host')
      add('port', 'Port')
      add('user', 'User')
      add('password', 'Password', true)
      add('database', 'Database')
      add('schema', 'Schema')
    else
      add('database', 'SQLite file')
    end
    ui.prompt_chain(steps, function(acc)
      for k, v in pairs(acc) do
        if v ~= nil and v ~= '' then conn[k] = v end
      end
      store.state.connections[idx] = conn
      store.persist()
      wiring.refresh_dadbod()
      wiring.refresh_duck_sqllsp()
      ui.info('Updated ' .. conn.name)
    end)
  end)
end

function M.delete()
  ui.pick_connection('Delete connection:', function(_, idx)
    local name = store.state.connections[idx].name
    table.remove(store.state.connections, idx)
    if store.state.active == name then store.state.active = nil end
    store.persist()
    wiring.refresh_dadbod()
    wiring.refresh_duck_sqllsp()
    ui.info('Deleted ' .. name)
  end)
end

function M.switch()
  ui.pick_connection('Switch active connection:', function(conn)
    store.state.active = conn.name
    store.persist()
    wiring.refresh_dadbod()
    local pushed = wiring.refresh_duck_sqllsp()
    local target = conn.database and (' -> ' .. conn.database) or ''
    local extra = pushed and ' (duck-sqllsp updated)' or ' (open a .sql buffer to attach LSP)'
    ui.info('Active: ' .. conn.name .. target .. extra)
  end)
end

function M.set_scope()
  local choices = {
    { 'all', 'All connections, all schemas (broadest completion)' },
    { 'db', 'Active connection database only' },
    { 'schema', 'Active connection default schema only (narrowest)' },
  }
  local labels = {}
  for _, p in ipairs(choices) do table.insert(labels, p[1] .. '  -- ' .. p[2]) end
  vim.ui.select(labels, { prompt = 'Completion scope:' }, function(_, idx)
    if not idx then return end
    store.state.scope = choices[idx][1]
    store.persist()
    wiring.refresh_duck_sqllsp()
    ui.info('Scope: ' .. store.state.scope)
  end)
end

function M.refresh()
  store.load()
  wiring.refresh_dadbod()
  wiring.refresh_duck_sqllsp()
  ui.info('Reloaded from disk')
end

function M.register()
  vim.api.nvim_create_user_command('DBAdd',     M.add,         { desc = 'DB: add connection' })
  vim.api.nvim_create_user_command('DBEdit',    M.edit,        { desc = 'DB: edit connection' })
  vim.api.nvim_create_user_command('DBDelete',  M.delete,      { desc = 'DB: delete connection' })
  vim.api.nvim_create_user_command('DBSwitch',  M.switch,      { desc = 'DB: switch active connection' })
  vim.api.nvim_create_user_command('DBList',    ui.list_modal, { desc = 'DB: list connections' })
  vim.api.nvim_create_user_command('DBScope',   M.set_scope,   { desc = 'DB: set completion scope' })
  vim.api.nvim_create_user_command('DBRefresh', M.refresh,     { desc = 'DB: reload + re-push' })

  vim.keymap.set('n', '<leader>dba', M.add,         { desc = 'DB: [a]dd connection' })
  vim.keymap.set('n', '<leader>dbe', M.edit,        { desc = 'DB: [e]dit connection' })
  vim.keymap.set('n', '<leader>dbd', M.delete,      { desc = 'DB: [d]elete connection' })
  vim.keymap.set('n', '<leader>dbs', M.switch,      { desc = 'DB: [s]witch connection' })
  vim.keymap.set('n', '<leader>dbl', ui.list_modal, { desc = 'DB: [l]ist connections' })
  vim.keymap.set('n', '<leader>dbc', M.set_scope,   { desc = 'DB: [c]ompletion scope' })
end

return M
