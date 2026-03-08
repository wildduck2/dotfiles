return {
  'chrisgrieser/nvim-lsp-endhints',
  event = 'LspAttach',
  opts = {
    autoEnableHints = true,
    icons = {
      type = '=> ',
      parameter = '=> ',
      offspec = '=> ',
      unknown = '=> ',
    },
    label = {
      truncateAtChars = 40,
    },
  },
}
