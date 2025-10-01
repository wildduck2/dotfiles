require('rose-pine').setup {
  -- disable_background = true
}

function ColorMyPencils(color)
  -- color = color or 'tokyonight-night'
  color = color or 'catppuccin-mocha'
  vim.cmd.colorscheme(color)

  -- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

vim.cmd.hi 'Comment gui=none'

ColorMyPencils()
vim.cmd [[colorscheme catppuccin-mocha]]
