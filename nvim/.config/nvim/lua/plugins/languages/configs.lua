local M = {}

M.clangd_extensions = {
  ast = {
    role_icons = {
      type = '', declaration = '', expression = '',
      specifier = '', statement = '', ['template argument'] = '',
    },
    kind_icons = {
      Compound = '', Recovery = '', TranslationUnit = '',
      PackExpansion = '', TemplateTypeParm = '',
      TemplateTemplateParm = '', TemplateParamObject = '',
    },
    highlights = { detail = 'Comment' },
  },
  memory_usage = { border = 'none' },
  symbol_info = { border = 'none' },
}

function M.setup_clangd()
  require('clangd_extensions').setup(M.clangd_extensions)
end

M.package_info = {
  highlights = {
    up_to_date = { fg = '#3C4048' },
    outdated = { fg = '#d19a66' },
    invalid = { fg = '#ee4b2b' },
  },
  icons = {
    enable = true,
    style = { up_to_date = '|  ', outdated = '|  ', invalid = '|  ' },
  },
  notifications = true,
  autostart = true,
  hide_up_to_date = false,
  hide_unstable_versions = false,
  package_manager = 'pnpm',
}

function M.setup_package_info()
  require('package-info').setup(M.package_info)

  local pi = require 'package-info'
  local opts = { silent = true, noremap = true }
  vim.keymap.set('n', '<LEADER>ns', pi.show, opts)
  vim.keymap.set('n', '<LEADER>nc', pi.hide, opts)
  vim.keymap.set('n', '<LEADER>nt', pi.toggle, opts)
  vim.keymap.set('n', '<LEADER>nu', pi.update, opts)
  vim.keymap.set('n', '<LEADER>nd', pi.delete, opts)
  vim.keymap.set('n', '<LEADER>ni', pi.install, opts)
  vim.keymap.set('n', '<LEADER>np', pi.change_version, opts)
end

return M
