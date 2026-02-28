local M = {}

M.n = {
    'filetype',
    colored = true,               -- Displays filetype icon in color if set to true
    icon_only = false,            -- Display only an icon for filetype
    icon = { align = 'right' },   -- Display filetype icon on the right hand side
    -- icon =    {'X', align='right'}
    -- Icon string ^ in table is ignored in filetype component
}

return M
