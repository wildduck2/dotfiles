return {
  'windwp/nvim-ts-autotag',
  config = function()
    require('plugins.lang.autotag.config').setup()
  end,
}
