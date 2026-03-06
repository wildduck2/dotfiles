return {
  'vyfor/cord.nvim',
  build = './build',
  event = 'VeryLazy',
  opts = function()
    return require('plugins.fun.cord.config').opts
  end,
}
