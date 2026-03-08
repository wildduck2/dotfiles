return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  event = 'BufReadPost',
  opts = {
    indent = {
      char = '│',
      tab_char = '│',
    },
    scope = {
      enabled = true,
      show_start = false,
      show_end = false,
      highlight = 'IblScope',
    },
    exclude = {
      filetypes = {
        'help', 'NvimTree', 'Trouble', 'lazy', 'mason',
        'toggleterm', 'dashboard', '',
      },
    },
  },
}
