return {
  'vyfor/cord.nvim',
  event = 'VeryLazy',
  opts = function()
    return require('plugins.fun.cord.config').opts
  end,
}
