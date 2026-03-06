return {
  'p00f/clangd_extensions.nvim',
  ft = { 'c', 'cpp' },
  opts = function()
    return require('plugins.lang.clangd-extensions.config').opts
  end,
}
