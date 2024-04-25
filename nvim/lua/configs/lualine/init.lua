--NOTE: those are the files for the lau line conf there is other file not included if your
--  want to configer them down in this file you gonna find the other commponents and tips to add
--  FOR MORE INFO ABOUT THIS :help lualine
local mode        = require('configs.lualine.mode')
local diagnostics = require('configs.lualine.diagnostics')
local filename    = require('configs.lualine.filename')
local filetype    = require('configs.lualine.filetype')
local diff        = require('configs.lualine.diff')



require('lualine').setup({
    options = {
        icons_enabled = false,
        theme = 'auto',
        -- component_separators = '|',
        -- section_separators = '',
        component_separators = "|",
        -- section_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
    },
    sections = {
        lualine_a = {
            -- { 'mode', fmt = mode.get_mode_name }
            mode.mode_default
        },
        lualine_b = { 'branch', diff, diagnostics.n, },
        lualine_c = { filename.n },
        lualine_x = { filetype.n },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {},
})



--[[
-NOTE: Available components

    branch (git branch)
    buffers (shows currently available buffers)
    diagnostics (diagnostics count from your preferred source)
    diff (git diff status)
    encoding (file encoding)
    fileformat (file format)
    filename
    filesize
    filetype
    hostname
    location (location in file in line:column format)
    mode (vim mode)
    progress (%progress in file)
    searchcount (number of search matches when hlsearch is active)
    selectioncount (number of selected characters or lines)
    tabs (shows currently available tabs)
    windows (shows currently available windows)
-]]
