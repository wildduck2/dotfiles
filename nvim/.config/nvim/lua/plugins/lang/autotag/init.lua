return {
  'windwp/nvim-ts-autotag',
  event = 'InsertEnter',
  config = function()
    require('plugins.lang.autotag.config').setup()
  end,
}
