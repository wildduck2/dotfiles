local M = {}

M.ensure_installed = {
  'bash', 'c', 'cpp', 'css', 'eex', 'elixir', 'erlang', 'go',
  'gitignore', 'haskell', 'heex', 'hjson', 'html', 'javascript',
  'jsdoc', 'json', 'json5', 'lua', 'ocaml', 'perl', 'php',
  'prisma', 'rust', 'scala', 'scss', 'sql', 'surface', 'tsx',
  'typescript', 'vim', 'vimdoc', 'yaml', 'zig',
}

M.incremental_selection_keymaps = {
  init_selection = '<c-space>',
  node_incremental = '<c-space>',
  scope_incremental = '<c-s>',
  node_decremental = '<M-space>',
}

M.textobject_keymaps = {
  ['aa'] = '@parameter.outer',
  ['ia'] = '@parameter.inner',
  ['af'] = '@function.outer',
  ['if'] = '@function.inner',
  ['ac'] = '@class.outer',
  ['ic'] = '@class.inner',
}

function M.setup()
  vim.defer_fn(function()
    require('nvim-treesitter.configs').setup {
      ensure_installed = M.ensure_installed,
      build = ':TSUpdate',
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = M.incremental_selection_keymaps,
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = M.textobject_keymaps,
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
          goto_next_end = { [']M'] = '@function.outer', [']['] = '@class.outer' },
          goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
          goto_previous_end = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
        },
        swap = {
          enable = true,
          swap_next = { ['<leader>s'] = '@parameter.inner' },
          swap_previous = { ['<leader>S'] = '@parameter.inner' },
        },
      },
    }
  end, 0)
end

M.autotag_filetypes = {
  'html', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact',
  'svelte', 'vue', 'tsx', 'jsx', 'rescript', 'xml', 'php', 'markdown',
  'astro', 'glimmer', 'handlebars', 'hbs',
}

function M.setup_autotag()
  require('nvim-ts-autotag').setup {
    opts = {
      enable_close = true,
      enable_rename = true,
      enable_close_on_slash = true,
    },
    filetypes = M.autotag_filetypes,
  }
end

return M
