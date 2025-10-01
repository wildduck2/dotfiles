require('supermaven-nvim').setup {
  keymaps = {
    accept_suggestion = '<Tab>',
    clear_suggestion = '<C-]>',
    accept_word = '<C-j>',
  },
  ignore_filetypes = {}, -- or { "cpp", }
  color = {
    -- suggestion_color = '#ffffff',
    cterm = 244,
  },
  log_level = 'info', -- set to "off" to disable logging completely
  disable_inline_completion = false, -- disables inline completion for use with cmp
  disable_keymaps = false, -- disables built in keymaps for more manual control
  condition = function()
    return false
  end, -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
}

--[[ Supermaven-nvim provides the following commands:

:SupermavenStart    start supermaven-nvim
:SupermavenStop     stop supermaven-nvim
:SupermavenRestart  restart supermaven-nvim
:SupermavenToggle   toggle supermaven-nvim
:SupermavenStatus   show status of supermaven-nvim
:SupermavenUseFree  switch to the free version
:SupermavenUsePro   switch to the pro version
:SupermavenLogout   log out of supermaven
:SupermavenShowLog  show logs for supermaven-nvim
:SupermavenClearLog clear logs for supermaven-nvim

]]

--[[ Lua API
The supermaven-nvim.api module provides the following functions for interacting with supermaven-nvim from Lua:

local api = require("supermaven-nvim.api")

api.start() -- starts supermaven-nvim
api.stop() -- stops supermaven-nvim
api.restart() -- restarts supermaven-nvim if it is running, otherwise starts it
api.toggle() -- toggles supermaven-nvim
api.is_running() -- returns true if supermaven-nvim is running
api.use_free_version() -- switch to the free version
api.use_pro() -- switch to the pro version
api.logout() -- log out of supermaven
api.show_log() -- show logs for supermaven-nvim
api.clear_log() -- clear logs for supermaven-nvim ]]
