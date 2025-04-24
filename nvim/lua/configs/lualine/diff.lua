local M = {}

M.n = {
  'diff',
  colored = true, -- Displays a colored diff status if set to true
  diff_color = {
    -- Same color values as the general color option can be used here.
    added = 'LuaLineDiffAdd',                               -- Changes the diff's added color
    modified = 'LuaLineDiffChange',                         -- Changes the diff's modified color
    removed = 'LuaLineDiffDelete',                          -- Changes the diff's removed color you
  },
  symbols = { added = '+', modified = '~', removed = '-' }, -- Changes the symbols used by the diff.

  separator = { left = '', right = '' },                    -- Determines what separator to use for the component.
  source = nil,                                             -- A function that works as a data source for diff.
  -- It must return a table as such:
  --   { added = add_count, modified = modified_count, removed = removed_count }
  -- or nil on failure. count <= 0 won't be displayed.
}

return M
