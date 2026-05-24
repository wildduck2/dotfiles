local specs = {}
local function add(mod)
  local result = require(mod)
  if result[1] and type(result[1]) == 'string' then
    table.insert(specs, result)
  else
    for _, spec in ipairs(result) do
      table.insert(specs, spec)
    end
  end
end

add 'plugins.lang.treesitter'
add 'plugins.lang.autotag'
-- add 'plugins.lang.rust'
add 'plugins.lang.clangd-extensions'
add 'plugins.lang.package-info'
add 'plugins.lang.dadbod' -- SQL: dadbod engine + UI + db_manager + cmp completion
add 'plugins.lang.markdown'

return specs
