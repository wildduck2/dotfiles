local M = {}

function M.setup()
  -- Augroup for fugitive-buffer-only keymaps
  local wildduck_fugitive = vim.api.nvim_create_augroup('wildduck_fugitive', {})
  -- Set keymaps only when inside the fugitive status window
  vim.api.nvim_create_autocmd('BufWinEnter', {
    group = wildduck_fugitive,
    pattern = '*', -- matches all buffers; filtered by filetype below
    callback = function()
      -- Only apply keymaps in fugitive status buffer
      if vim.bo.ft ~= 'fugitive' then
        return
      end
      local bufnr = vim.api.nvim_get_current_buf()
      -- buffer-local, no recursive remap
      local opts = { buffer = bufnr, remap = false }
      -- Git push
      vim.keymap.set('n', '<leader>p', function()
        vim.cmd.Git 'push'
      end, opts)
      -- Git pull (default strategy)
      vim.keymap.set('n', '<leader>P', function()
        vim.cmd.Git { 'pull' }
      end, opts)
      -- Git pull with rebase on top of remote
      vim.keymap.set('n', '<leader>Pr', function()
        vim.cmd.Git { 'pull', '--rebase' }
      end, opts)
      -- Git pull with merge (no rebase)
      vim.keymap.set('n', '<leader>Pn', function()
        vim.cmd.Git { 'pull', '--no-rebase' }
      end, opts)
      -- Push and set upstream; type branch name after
      vim.keymap.set('n', '<leader>t', ':Git push -u origin ', opts)
    end,
  })
  -- Open fugitive status window (:Git)
  vim.keymap.set('n', '<leader>gs', vim.cmd.Git)
end

return M
