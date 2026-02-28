local M = {}

M.n = {
  'branch',

  separator = { left = '', right = '' }, -- Determines what separator to use for the component.
  colored = true,                        -- Displays diagnostics status in color if set to true.
  update_in_insert = false,              -- Update diagnostics in insert mode.
  always_visible = false,                -- Show diagnostics even if there are none.
}

return M
