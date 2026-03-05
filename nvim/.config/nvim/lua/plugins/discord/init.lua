local configs = require 'plugins.discord.configs'

return {
  'vyfor/cord.nvim',
  build = './build',
  event = 'VeryLazy',
  config = configs.setup,
}
