local M = {}

M.opts = {
  -- enable on startup (toggle with :lua require('lsp-endhints').toggle())
  enabled = true,
  -- label displayed for type hints (e.g. `: string`)
  label = {
    -- prepended before the hint text
    prefix = ' => ',
    -- truncate hints longer than this (0 = no limit)
    truncateAtChars = 40,
  },
  -- only show hints for the current line (reduces visual noise)
  autoEnableHints = true,
}

return M
