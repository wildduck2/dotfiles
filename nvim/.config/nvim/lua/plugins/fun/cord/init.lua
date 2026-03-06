return {
  'vyfor/cord.nvim',
  build = './build',
  event = 'VeryLazy',
  opts = require('plugins.fun.cord.config').opts,
}
