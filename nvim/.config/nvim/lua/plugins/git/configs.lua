local M = {}

function M.setup_fugitive()
  local wildduck_fugitive = vim.api.nvim_create_augroup('wildduck_fugitive', {})
  vim.api.nvim_create_autocmd('BufWinEnter', {
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
      vim.keymap.set('n', '<leader>P', function()
        vim.cmd.Git { 'pull' }
      end, opts)
      vim.keymap.set('n', '<leader>Pr', function()
        vim.cmd.Git { 'pull', '--rebase' }
      end, opts)
      vim.keymap.set('n', '<leader>Pn', function()
        vim.cmd.Git { 'pull', '--no-rebase' }
      end, opts)
      vim.keymap.set('n', '<leader>t', ':Git push -u origin ', opts)
    end,
  })
  vim.keymap.set('n', '<leader>gs', vim.cmd.Git)
end

M.gitsigns_signs = {
  add = { text = '+' },
  change = { text = '~' },
  delete = { text = '_' },
  topdelete = { text = '‾' },
  changedelete = { text = '~' },
}

function M.gitsigns_on_attach(bufnr)
  local gitsigns = require 'gitsigns'
  local function map(mode, l, r, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, l, r, opts)
  end

  -- Navigation
  map('n', ']c', function()
    if vim.wo.diff then
      vim.cmd.normal { ']c', bang = true }
    else
      gitsigns.nav_hunk 'next'
    end
  end)
  map('n', '[c', function()
    if vim.wo.diff then
      vim.cmd.normal { '[c', bang = true }
    else
      gitsigns.nav_hunk 'prev'
    end
  end)

  -- Actions
  map('n', '<leader>hs', gitsigns.stage_hunk)
  map('n', '<leader>hr', gitsigns.reset_hunk)
  map('v', '<leader>hs', function()
    gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
  end)
  map('v', '<leader>hr', function()
    gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
  end)
  map('n', '<leader>hS', gitsigns.stage_buffer)
  map('n', '<leader>hu', gitsigns.undo_stage_hunk)
  map('n', '<leader>hR', gitsigns.reset_buffer)
  map('n', '<leader>hp', gitsigns.preview_hunk)
  map('n', '<leader>hb', function()
    gitsigns.blame_line { full = true }
  end)
  map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
  map('n', '<leader>hd', gitsigns.diffthis)
  map('n', '<leader>hD', function()
    gitsigns.diffthis '~'
  end)
  map('n', '<leader>td', gitsigns.toggle_deleted)
  map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
end

function M.setup_gitsigns()
  require('gitsigns').setup {
    signs = M.gitsigns_signs,
    on_attach = M.gitsigns_on_attach,
  }
end

return M
