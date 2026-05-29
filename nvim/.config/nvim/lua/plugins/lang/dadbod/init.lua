-- vim-dadbod-ui + persistent connection manager.
--
-- Plugins loaded:
--   * tpope/vim-dadbod              SQL engine (`:DB`). ft + cmd lazy.
--   * kristijanhusak/vim-dadbod-ui  DataGrip-style sidebar. cmd + keys lazy.
--
-- Completion, hover, formatting, and diagnostics for SQL come from the
-- duck-sqllsp language server, configured in plugins/lsp/lspconfig.

return {
  {
    'tpope/vim-dadbod',
    cmd = { 'DB' },
    ft = { 'sql', 'mysql', 'plsql' },
  },

  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = { 'tpope/vim-dadbod' },
    cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
    ft = { 'sql', 'mysql', 'plsql' },
    keys = {
      { '<leader>db', '<cmd>DBUIToggle<cr>', desc = '[D]atabase: toggle UI' },
      { '<leader>df', '<cmd>DBUIFindBuffer<cr>', desc = '[D]atabase: [f]ind buffer in UI' },
      { '<leader>dr', '<cmd>DBUIRenameBuffer<cr>', desc = '[D]atabase: [r]ename query buffer' },
      { '<leader>dq', '<cmd>DBUILastQueryInfo<cr>', desc = '[D]atabase: last [q]uery info' },
    },
    init = function()
      require('plugins.lang.dadbod.db_manager').setup()

      vim.g.db_ui_save_location = vim.fn.stdpath('data') .. '/db_ui'
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_execute_on_save = 0

      vim.g.db_ui_table_helpers = {
        postgresql = {
          List = 'SELECT * FROM "{table}" LIMIT 200;',
          Count = 'SELECT COUNT(*) FROM "{table}";',
        },
        mysql = {
          List = 'SELECT * FROM `{table}` LIMIT 200;',
          Count = 'SELECT COUNT(*) FROM `{table}`;',
        },
      }

      local grp = vim.api.nvim_create_augroup('dadbod-ui-keymaps', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = grp,
        pattern = { 'sql', 'mysql', 'plsql' },
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          vim.keymap.set(
            'n',
            '<leader>S',
            '<cmd>%DB<cr>',
            vim.tbl_extend('force', opts, { desc = 'SQL: execute buffer' })
          )
          vim.keymap.set(
            'x',
            '<leader>S',
            ":DB<cr>",
            vim.tbl_extend('force', opts, { desc = 'SQL: execute selection' })
          )
        end,
      })
    end,
  },
}
