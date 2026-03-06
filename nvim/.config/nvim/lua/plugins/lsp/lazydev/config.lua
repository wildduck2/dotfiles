local M = {}

M.opts = {
  -- Extra type libraries loaded on demand
  library = {
    -- Load luv types when 'vim.uv' is referenced
    { path = 'luvit-meta/library', words = { 'vim%.uv' } },
  },
}

return M
