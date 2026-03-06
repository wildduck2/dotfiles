local M = {}

function M.setup()
  require('package-info').setup {
    -- Colors for version status in virtual text
    highlights = {
      up_to_date = { fg = '#3C4048' }, -- Dim gray for current versions
      outdated = { fg = '#d19a66' }, -- Orange for outdated versions
      invalid = { fg = '#ee4b2b' }, -- Red for invalid versions
    },
    icons = {
      enable = true, -- Show status icons next to packages
      style = { up_to_date = '|  ', outdated = '|  ', invalid = '|  ' },
    },
    notifications = true, -- Show notification on actions
    autostart = false, -- false: don't fetch on open (use <leader>ns to show)
    hide_up_to_date = false, -- Show even if version is current
    hide_unstable_versions = false, -- Include pre-release versions
    package_manager = 'pnpm', -- npm | yarn | pnpm
  }

  -- Keymaps for package.json management
  local pi = require 'package-info'
  local opts = { silent = true, noremap = true }
  vim.keymap.set('n', '<LEADER>ns', pi.show, opts) -- Show version info
  vim.keymap.set('n', '<LEADER>nc', pi.hide, opts) -- Hide version info
  vim.keymap.set('n', '<LEADER>nt', pi.toggle, opts) -- Toggle version display
  vim.keymap.set('n', '<LEADER>nu', pi.update, opts) -- Update package
  vim.keymap.set('n', '<LEADER>nd', pi.delete, opts) -- Delete package
  vim.keymap.set('n', '<LEADER>ni', pi.install, opts) -- Install new package
  vim.keymap.set('n', '<LEADER>np', pi.change_version, opts) -- Pick version
end

return M
