local M = {}

M.opts = {
  log_level = vim.log.levels.OFF, -- Suppress log output

  -- Editor identity shown on Discord
  editor = {
    client = 'neovim', -- Discord app name: neovim | vim
    tooltip = 'The One True Text Editor', -- Hover text on editor icon
    icon = nil, -- Custom editor icon URL
  },

  -- Rich presence appearance
  display = {
    theme = 'default', -- Icon theme for file types
    flavor = 'dark', -- Icon flavor: 'dark' | 'light'
    view = 'full', -- 'full' shows all fields, 'compact' fewer
    swap_fields = false, -- Swap details and state lines
    swap_icons = false, -- Swap large and small image
  },

  -- Elapsed time display
  timestamp = {
    enabled = true,
    reset_on_idle = false,
    reset_on_change = false,
    shared = false,
  },

  -- Idle/AFK detection
  idle = {
    enabled = true, -- Enable idle status detection
    timeout = 300000, -- Idle after 5 min (ms)
    show_status = true, -- Display idle status on Discord
    ignore_focus = true, -- Stay active even when unfocused
    unidle_on_focus = true, -- Resume on window focus
    smart_idle = true, -- Only idle if no other instances active
    details = 'Idling', -- Idle status text
    state = nil, -- Custom idle state text
    tooltip = '💤', -- Hover text while idle
    icon = nil, -- Custom idle icon URL
  },

  -- Status text templates per activity type
  text = {
    default = nil,
    workspace = function(opts) return 'In ' .. opts.workspace end,
    viewing = function(opts)
      local parent = vim.fn.expand '%:h:t'
      local file = parent ~= '' and parent ~= '.' and (parent .. '/' .. opts.filename) or opts.filename
      return 'Viewing ' .. file .. ' [' .. opts.cursor_line .. ':' .. opts.cursor_char .. ']'
    end,
    editing = function(opts)
      local parent = vim.fn.expand '%:h:t'
      local file = parent ~= '' and parent ~= '.' and (parent .. '/' .. opts.filename) or opts.filename
      local lines = vim.api.nvim_buf_line_count(0)
      return 'Editing ' .. file .. ' [' .. opts.cursor_line .. '/' .. lines .. ']'
    end,
    file_browser = function(opts) return 'Browsing files in ' .. opts.name end,
    plugin_manager = function(opts) return 'Managing plugins in ' .. opts.name end,
    lsp = function(opts) return 'Configuring LSP in ' .. opts.name end,
    docs = function(opts) return 'Reading ' .. opts.name end,
    vcs = function(opts) return 'Committing changes in ' .. opts.name end,
    notes = function(opts) return 'Taking notes in ' .. opts.name end,
    debug = function(opts) return 'Debugging in ' .. opts.name end,
    test = function(opts) return 'Testing in ' .. opts.name end,
    diagnostics = function(opts) return 'Fixing problems in ' .. opts.name end,
    games = function(opts) return 'Playing ' .. opts.name end,
    terminal = function(opts) return 'Running commands in ' .. opts.name end,
    dashboard = 'Home',
  },

  -- Buttons shown on Discord profile
  buttons = {
    {
      label = 'View Repository',
      url = function(opts)
        return opts.repo_url or 'https://github.com/wildduck'
      end,
    },
  },

  -- Custom file type assets
  assets = {
    rust = {
      icon = 'rust',
      tooltip = 'Rust',
      name = 'Rust',
    },
    typescript = {
      icon = 'typescript',
      tooltip = 'TypeScript',
      name = 'TypeScript',
    },
    lua = {
      icon = 'lua',
      tooltip = 'Lua',
      name = 'Lua',
    },
  },

  -- Custom variables for string templates
  variables = true,

  -- Extensions
  extensions = {
    -- Persist elapsed time across nvim sessions
    persistent_timer = {
      scope = 'global',
      mode = 'all',
      save_on = { 'exit', 'focus_change', 'periodic' },
      save_interval = 30,
    },
    -- Hide certain workspaces from Discord
    visibility = {
      override = true,
      precedence = 'blacklist',
      rules = {
        blacklist = {
          -- Add workspace names or paths to hide from Discord:
          -- 'secret-project',
          -- { type = 'path', value = '/home/wildduck/work/private-repo' },
          -- { type = 'glob', value = '**/private-*' },
        },
      },
    },
  },

  -- Advanced/internal settings
  advanced = {
    plugin = {
      autocmds = true,
      cursor_update = 'on_hold',
      match_in_mappings = true,
      debounce = {
        delay = 0,
        interval = 500,
      },
    },
    server = {
      update = 'fetch',
      pipe_path = nil,
      executable_path = nil,
      timeout = 300000,
    },
    discord = {
      pipe_paths = nil,
      reconnect = {
        enabled = true,
        interval = 5000,
        initial = true,
      },
      sync = {
        enabled = true,
        mode = 'defer',
        interval = 5000,
        reset_on_update = false,
        pad = true,
      },
    },
    workspace = {
      root_markers = { '.git', '.hg', '.svn' },
      limit_to_cwd = false,
    },
  },
}

return M
