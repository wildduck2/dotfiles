return {
  {
    'epwalsh/obsidian.nvim',
    version = '*',
    lazy = true,
    ft = 'markdown',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  {
    'davidmh/mdx.nvim',
    ft = 'mdx',
    config = true,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
}
