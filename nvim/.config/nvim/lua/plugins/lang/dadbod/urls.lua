-- URL builders for the two consumers of a connection object:
--   * dadbod (engine + UI) wants a single URL like `postgres://u:p@h:port/db`.
--   * sqls (LSP) wants a struct: { alias, driver, dataSourceName }.

local M = {}

-- Map our internal driver names to the dadbod URL scheme.
local DADBOD_SCHEME = {
  postgresql = 'postgres',
  postgres = 'postgres',
  mysql = 'mysql',
  mariadb = 'mysql',
  sqlite3 = 'sqlite',
  sqlite = 'sqlite',
}

function M.to_dadbod(conn)
  if conn.dsn and conn.dsn:match('^%w+://') then
    return conn.dsn
  end
  local scheme = DADBOD_SCHEME[conn.driver] or conn.driver
  if scheme == 'sqlite' then
    return 'sqlite:' .. (conn.database or '')
  end
  local userinfo = conn.user or ''
  if conn.password and conn.password ~= '' then
    userinfo = userinfo .. ':' .. conn.password
  end
  local host = conn.host or 'localhost'
  if conn.port and conn.port ~= '' then
    host = host .. ':' .. conn.port
  end
  return string.format('%s://%s@%s/%s', scheme, userinfo, host, conn.database or '')
end

function M.to_sqls(conn)
  local driver = conn.driver
  if driver == 'postgres' then
    driver = 'postgresql'
  end
  local dsn
  if driver == 'postgresql' then
    local parts = {}
    if conn.host then
      table.insert(parts, 'host=' .. conn.host)
    end
    if conn.port and conn.port ~= '' then
      table.insert(parts, 'port=' .. conn.port)
    end
    if conn.user and conn.user ~= '' then
      table.insert(parts, 'user=' .. conn.user)
    end
    if conn.password and conn.password ~= '' then
      table.insert(parts, 'password=' .. conn.password)
    end
    if conn.database and conn.database ~= '' then
      table.insert(parts, 'dbname=' .. conn.database)
    end
    if conn.schema and conn.schema ~= '' then
      table.insert(parts, 'search_path=' .. conn.schema)
    end
    table.insert(parts, 'sslmode=disable')
    dsn = table.concat(parts, ' ')
  elseif driver == 'mysql' or driver == 'mariadb' then
    dsn = string.format(
      '%s:%s@tcp(%s:%s)/%s',
      conn.user or '',
      conn.password or '',
      conn.host or 'localhost',
      conn.port ~= '' and conn.port or '3306',
      conn.database or ''
    )
  elseif driver == 'sqlite3' or driver == 'sqlite' then
    driver = 'sqlite3'
    dsn = conn.database or ''
  else
    return nil
  end
  return { alias = conn.name, driver = driver, dataSourceName = dsn }
end

return M
