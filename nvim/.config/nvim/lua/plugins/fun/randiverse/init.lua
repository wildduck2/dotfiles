return {
  'ty-labs/randiverse.nvim',
  version = '*',
  cmd = 'Randiverse',
  config = function()
    require('plugins.fun.randiverse.config').setup()
  end,
}
