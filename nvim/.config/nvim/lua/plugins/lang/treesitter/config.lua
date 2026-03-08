local M = {}

function M.setup()
  require('nvim-treesitter.configs').setup {
    ensure_installed = {
      'bash', 'c', 'cpp', 'css', 'eex', 'elixir', 'erlang', 'go',
      'gitignore', 'haskell', 'heex', 'hjson', 'html', 'javascript',
      'jsdoc', 'json', 'json5', 'lua', 'ocaml', 'perl', 'php',
      'markdown', 'markdown_inline',
      'prisma', 'rust', 'scala', 'scss', 'sql', 'surface', 'tsx',
      'typescript', 'vim', 'vimdoc', 'yaml', 'zig',
    },
    auto_install = false,
    highlight = { enable = true },
    indent = { enable = true },

    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },

    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
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
        swap_next = { ['<leader>sp'] = '@parameter.inner' },
        swap_previous = { ['<leader>sP'] = '@parameter.inner' },
      },
    },
  }
end

return M
