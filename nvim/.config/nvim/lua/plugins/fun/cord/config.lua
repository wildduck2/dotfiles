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
    enabled = true, -- Show elapsed time on Discord
    reset_on_idle = false, -- Restart timer after idle
    reset_on_change = false, -- Restart timer on file change
    shared = false, -- Share timer across instances
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
    default = nil, -- Fallback text (nil = auto)
    workspace = function(opts) return 'In ' .. opts.workspace end,
    viewing = function(opts) return 'Viewing ' .. opts.filename end,
    editing = function(opts) return 'Editing ' .. opts.filename end,
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
    dashboard = 'Home', -- Text shown on dashboard screen
  },
  buttons = nil, -- Custom buttons on Discord profile
  assets = nil, -- Custom image assets
  variables = nil, -- Custom template variables

  -- Lifecycle hooks
  hooks = {
    ready = nil, -- Fires when cord connects
    shutdown = nil, -- Fires on cord shutdown
    pre_activity = nil, -- Before activity update
    post_activity = nil, -- After activity update
    idle_enter = nil, -- When entering idle
    idle_leave = nil, -- When leaving idle
    workspace_change = nil, -- On workspace switch
    buf_enter = nil, -- On buffer enter
  },
  plugins = nil, -- Extra plugin integrations

  -- Advanced/internal settings
  advanced = {
    plugin = {
      autocmds = true, -- Register autocmds for tracking
      cursor_update = 'on_hold', -- Update on CursorHold event
      match_in_mappings = true, -- Detect plugins from mappings
    },
    server = {
      update = 'fetch', -- Update method: 'fetch' | 'build'
      pipe_path = nil, -- Custom IPC pipe path
      executable_path = nil, -- Custom server binary path
      timeout = 300000, -- Server connection timeout (ms)
    },
    discord = {
      pipe_paths = nil, -- Custom Discord IPC pipe paths
      reconnect = {
        enabled = false, -- Auto-reconnect on disconnect
        interval = 5000, -- Retry interval (ms)
        initial = true, -- Reconnect on initial failure
      },
    },
    workspace = {
      root_markers = { '.git', '.hg', '.svn' }, -- Project root indicators
      limit_to_cwd = false, -- Only detect workspace in cwd
    },
  },
}

return M
