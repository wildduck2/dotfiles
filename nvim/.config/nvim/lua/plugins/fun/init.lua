local configs = require 'plugins.fun.configs'

return {
  {
    'letieu/hacker.nvim',
    config = configs.setup_hacker,
  },
  {
    'ty-labs/randiverse.nvim',
    version = '*',
    config = configs.setup_randiverse,
  },
  { 'eandrju/cellular-automaton.nvim' },
}
