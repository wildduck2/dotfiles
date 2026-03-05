local M = {}

function M.find_git_root()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  if current_file == '' then
    current_dir = cwd
  else
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end
  local git_root =
    vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

function M.setup()
  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'ui-select')

  local builtin = require 'telescope.builtin'
  local open_with_trouble = require('trouble.sources.telescope').open

  require('telescope').setup {
    pickers = {},
    defaults = {
      mappings = {
        i = { ['<leader>n'] = open_with_trouble },
        n = { ['<leader>tr'] = open_with_trouble },
      },
    },
    extensions = {
      ['ui-select'] = {
        require('telescope.themes').get_dropdown(),
      },
    },
  }

  -- Keymaps
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Search [G]it [F]iles' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

  vim.keymap.set('n', '<leader>sa', '<cmd>Telescope ast_grep<CR>', { desc = '[S]earch AST' })
  vim.keymap.set('n', '<leader>sj', '<cmd>Telescope dumb_jump<CR>', { desc = '[S]earch Jump' })

  vim.keymap.set('n', '<leader>su', function()
    require('trouble').toggle { mode = 'document_diagnostics' }
  end, { desc = '[S]earch trouble' })

  vim.keymap.set('n', '<leader>snd', '<cmd>Telescope diagnostics<cr>', {
    desc = 'Search diagnostics with Telescope',
  })
  vim.keymap.set('n', '<leader>sd', function()
    require('telescope.builtin').diagnostics { bufnr = 0 }
  end, { desc = 'Search document diagnostics (Telescope)' })

  vim.keymap.set('n', '<leader>/', function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  vim.keymap.set('n', '<leader>s/', function()
    builtin.live_grep {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
    }
  end, { desc = '[S]earch [/] in Open Files' })

  vim.api.nvim_create_user_command('LiveGrepGitRoot', function()
    local git_root = M.find_git_root()
    if git_root then
      require('telescope.builtin').live_grep { search_dirs = { git_root } }
    end
  end, {})
end

return M
