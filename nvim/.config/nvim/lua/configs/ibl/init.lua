local ibl = require("ibl")
---@module "ibl"
---@type ibl.config
local blacklineOpts = {
  whitespace = {
    highlight = {
      "Whitespace",
      "NonText",
    },
  },
  indent = {
    -- char = "|",
    -- tab_char = "|",
    -- highlight = { "Identifier", 'NonText' ,'CursorLineNr' ,'CursorLine'},
    smart_indent_cap = true,
    repeat_linebreak = true,
  },
  scope = {
    enabled = true,
    show_start = true,
    show_end = true,
    highlight = "Function", -- you can use "CursorLine", "Identifier", or define your own
    priority = 500,         -- z-index of scope highlight
  },
}

ibl.setup(blacklineOpts)

