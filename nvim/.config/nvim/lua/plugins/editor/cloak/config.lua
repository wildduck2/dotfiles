local M = {}

M.opts = {
  enabled = true,
  -- char shown in place of hidden text (e.g. '*', '•')
  cloak_character = '*',
  -- highlight group for cloaked text styling
  highlight_group = 'Comment',
  patterns = {
    {
      -- files where cloaking is applied
      file_pattern = { '.env*', 'wrangler.toml', '.dev.vars' },
      -- regex: hides everything after '=' (values)
      cloak_pattern = '=.+',
    },
  },
}

return M
