local M = {}

function M.setup()
  require('treesitter-modules').setup({
    ensure_installed = {
      'bash',
      'c',
      'cpp',
      'css',
      'eex',
      'elixir',
      'erlang',
      'go',
      'gitignore',
      'haskell',
      'heex',
      'hjson',
      'html',
      'javascript',
      'jsdoc',
      'json',
      'json5',
      'lua',
      'ocaml',
      'perl',
      'php',
      'markdown',
      'markdown_inline',
      'prisma',
      'rust',
      'scala',
      'scss',
      'sql',
      'surface',
      'tsx',
      'typescript',
      'vim',
      'vimdoc',
      'yaml',
      'zig',
    },
    auto_install = false,
    highlight = {
      enable = true,
      -- Disable highlighting on large files to keep scroll/edit responsive.
      -- Threshold: > 1MB OR > 5000 lines.
      -- disable = function(_, buf)
      --   local max_size = 1024 * 1024
      --   local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
      --   if ok and stats and stats.size > max_size then return true end
      --   if vim.api.nvim_buf_line_count(buf) > 5000 then return true end
      --   return false
      -- end,
    },
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
  })
end

return M
