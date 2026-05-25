return {
  'aznhe21/actions-preview.nvim',
  event = 'LspAttach',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  config = function()
    require('actions-preview').setup({
      backend = { 'telescope' },
      telescope = {
        sorting_strategy = 'ascending',
        layout_strategy = 'vertical',
        layout_config = { width = 0.8, height = 0.9, prompt_position = 'top', preview_cutoff = 20 },
      },
    })
    -- Override the default <leader>ca to show preview before applying.
    vim.keymap.set(
      { 'n', 'v' },
      '<leader>ca',
      require('actions-preview').code_actions,
      { desc = 'LSP: [C]ode [A]ction (preview)' }
    )
  end,
}
