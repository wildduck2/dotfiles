local wildduck_fugitive = vim.api.nvim_create_augroup('wildduck_fugitive', {})
local autocmd = vim.api.nvim_create_autocmd

autocmd('BufWinEnter', {
  group = wildduck_fugitive,
  pattern = '*',
  callback = function()
    if vim.bo.ft ~= 'fugitive' then
      return
    end
    local bufnr = vim.api.nvim_get_current_buf()
    local opts = { buffer = bufnr, remap = false }
    vim.keymap.set('n', '<leader>p', function()
      vim.cmd.Git 'push'
    end, opts)

    -- INFO: PULL COMMANDS
    vim.keymap.set('n', '<leader>P', function()
      vim.cmd.Git { 'pull' }
    end, opts)
    -- rebase always
    vim.keymap.set('n', '<leader>Pr', function()
      vim.cmd.Git { 'pull', '--rebase' }
    end, opts)
    -- rebase always
    vim.keymap.set('n', '<leader>Pn', function()
      vim.cmd.Git { 'pull', '--no-rebase' }
    end, opts)


    -- NOTE: It allows me to easily set the branch i am pushing and any tracking
    -- needed if i did not set the branch up correctly
    vim.keymap.set('n', '<leader>t', ':Git push -u origin ', opts)
  end,
})

vim.keymap.set('n', '<leader>gs', vim.cmd.Git)
