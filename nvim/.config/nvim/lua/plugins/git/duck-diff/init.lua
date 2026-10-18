return {
  -- Private repo, so lazy.nvim clones it over ssh; release downloads use `gh auth token`.
  'gentleeduck/duck-diff',
  url = 'git@github.com:gentleeduck/duck-diff.git',
  cmd = 'DuckDiff',
  keys = {
    { '<leader>gv', '<cmd>DuckDiff<cr>', desc = 'duck-diff: local changes' },
    { '<leader>gV', '<cmd>DuckDiff main<cr>', desc = 'duck-diff: branch against main' },
  },
  opts = {},
}
