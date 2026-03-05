local configs = require 'plugins.languages.configs'

return {
  {
    'rust-lang/rust.vim',
    ft = 'rust',
    init = function()
      vim.g.rustfmt_autosave = 1
    end,
  },
  { 'mrcjkb/rustaceanvim', version = '^4', ft = { 'rust' } },
  {
    'p00f/clangd_extensions.nvim',
    config = configs.setup_clangd,
  },
  {
    'vuki656/package-info.nvim',
    dependencies = 'MunifTanjim/nui.nvim',
    config = configs.setup_package_info,
  },
  {
    'kndndrj/nvim-dbee',
    dependencies = { 'MunifTanjim/nui.nvim' },
    build = function()
      require('dbee').install()
    end,
  },
}
