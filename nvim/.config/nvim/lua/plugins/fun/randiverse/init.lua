return {
  'ty-labs/randiverse.nvim',
  version = '*',
  config = function()
    require('plugins.fun.randiverse.config').setup()
  end,
}
