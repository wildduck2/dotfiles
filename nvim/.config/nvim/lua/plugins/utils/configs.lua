local M = {}

function M.setup_undotree()
  vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
end

function M.setup_tmux()
  vim.g.tmux_navigator_no_mappings = 1
  vim.keymap.set('n', '<S-h>', ':<C-U>TmuxNavigateLeft<cr>', { noremap = true, silent = true })
  vim.keymap.set('n', '<S-j>', ':<C-U>TmuxNavigateDown<cr>', { noremap = true, silent = true })
  vim.keymap.set('n', '<S-k>', ':<C-U>TmuxNavigateUp<cr>', { noremap = true, silent = true })
  vim.keymap.set('n', '<S-l>', ':<C-U>TmuxNavigateRight<cr>', { noremap = true, silent = true })
  vim.keymap.set('n', '<S-p>', ':<C-U>TmuxNavigatePrevious<cr>', { noremap = true, silent = true })
end

function M.setup_mini()
  require('mini.ai').setup { n_lines = 500 }
  require('mini.surround').setup()
  local statusline = require 'mini.statusline'
  statusline.setup { use_icons = vim.g.have_nerd_font }
  ---@diagnostic disable-next-line: duplicate-set-field
  statusline.section_location = function()
    return '%2l:%-2v'
  end
end

function M.setup_ufo()
  vim.o.foldcolumn = '1'
  vim.o.foldenable = false
  vim.o.foldlevel = 99
  vim.o.foldlevelstart = 99
  vim.o.fillchars = [[fold: ,foldopen:-,foldsep:│,diff:⣿]]

  require('ufo').setup {}

  vim.keymap.set('n', '<leader>fR', require('ufo').openAllFolds)
  vim.keymap.set('n', '<leader>fM', require('ufo').closeAllFolds)
  vim.keymap.set('n', '<leader>fm', function()
    local line = vim.fn.line '.'
    local foldClosed = vim.fn.foldclosed(line)
    if foldClosed == -1 then
      vim.cmd 'normal! zc'
    else
      vim.cmd 'normal! zo'
    end
  end)
end

return M
