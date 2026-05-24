local M = {}

function M.setup()
  require('tokyonight').setup()
  -- Variants: tokyonight-night | -storm | -day | -moon
  vim.cmd.colorscheme 'tokyonight-night'

  -- Force our local SQL highlights query to be the only one in effect.
  -- The query.set call has to run AFTER the SQL parser has been
  -- registered, so we wire it via FileType so it re-applies every
  -- time a SQL buffer opens (cheap; just a hash lookup after first
  -- load).
  local function load_sql_query()
    local query_path = vim.fn.stdpath('config') .. '/queries/sql/highlights.scm'
    local f = io.open(query_path, 'r')
    if not f then return end
    local src = f:read('*a'); f:close()
    pcall(vim.treesitter.query.set, 'sql', 'highlights', src)
  end
  load_sql_query()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'sql', 'psql', 'plsql' },
    callback = load_sql_query,
  })
end

return M
