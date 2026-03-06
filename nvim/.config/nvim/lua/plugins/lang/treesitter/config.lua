local M = {}

function M.setup()
  -- Defer setup to avoid blocking startup
  vim.defer_fn(function()
    require('nvim-treesitter.configs').setup {
      -- Parsers to install automatically
      ensure_installed = {
        'bash', 'c', 'cpp', 'css', 'eex', 'elixir', 'erlang', 'go',
        'gitignore', 'haskell', 'heex', 'hjson', 'html', 'javascript',
        'jsdoc', 'json', 'json5', 'lua', 'ocaml', 'perl', 'php',
        'prisma', 'rust', 'scala', 'scss', 'sql', 'surface', 'tsx',
        'typescript', 'vim', 'vimdoc', 'yaml', 'zig',
      },
      build = ':TSUpdate', -- Run :TSUpdate on install
      auto_install = false, -- Don't auto-install missing parsers
      highlight = { enable = true }, -- Syntax highlighting via treesitter
      indent = { enable = true }, -- Treesitter-based indentation

      -- Incremental selection: expand/shrink selection by node
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>', -- Start selecting a node
          node_incremental = '<c-space>', -- Expand to next parent node
          scope_incremental = '<c-s>', -- Expand to enclosing scope
          node_decremental = '<M-space>', -- Shrink selection one node
        },
      },

      -- Textobjects: select/move/swap by syntax node
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Jump forward to matching textobject
          keymaps = {
            ['aa'] = '@parameter.outer', -- Around parameter
            ['ia'] = '@parameter.inner', -- Inside parameter
            ['af'] = '@function.outer', -- Around function
            ['if'] = '@function.inner', -- Inside function
            ['ac'] = '@class.outer', -- Around class
            ['ic'] = '@class.inner', -- Inside class
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- Add movements to jumplist
          goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
          goto_next_end = { [']M'] = '@function.outer', [']['] = '@class.outer' },
          goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
          goto_previous_end = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
        },
        swap = {
          enable = true,
          swap_next = { ['<leader>sp'] = '@parameter.inner' }, -- Swap param right
          swap_previous = { ['<leader>sP'] = '@parameter.inner' }, -- Swap param left
        },
      },
    }
  end, 0)
end

return M
