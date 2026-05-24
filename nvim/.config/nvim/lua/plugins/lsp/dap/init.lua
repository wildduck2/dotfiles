return {
  {
    'mfussenegger/nvim-dap',
    event = 'VeryLazy',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'theHamsta/nvim-dap-virtual-text',
      'jay-babu/mason-nvim-dap.nvim',
      'williamboman/mason.nvim',
      { 'leoluz/nvim-dap-go' },
      { 'mfussenegger/nvim-dap-python' },
    },
    config = function()
      require('plugins.lsp.dap.config').setup()
    end,
  },
}
