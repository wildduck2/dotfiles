return {
  -- Private repo, so lazy.nvim clones it over ssh; release downloads use `gh auth token`.
  'gentleeduck/duck-diff',
  url = 'git@github.com:gentleeduck/duck-diff.git',
  -- Work in progress lives here until it merges; drop this line to follow main again.
  branch = 'feat/fast-open',
  cmd = 'DuckDiff',
  keys = {
    { '<leader>gv', '<cmd>DuckDiff<cr>', desc = 'duck-diff: local changes' },
    { '<leader>gV', '<cmd>DuckDiff main<cr>', desc = 'duck-diff: branch against main' },
  },
  opts = {},
}
