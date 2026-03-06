return {
  'letieu/hacker.nvim',
  cmd = { 'Hack', 'HackFollowAuto' },
  config = function()
    require('plugins.fun.hacker.config').setup()
  end,
}
