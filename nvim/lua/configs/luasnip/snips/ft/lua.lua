local ls     = require "luasnip"

local fmta   = require("luasnip.extras.fmt").fmta
local rep    = require("luasnip.extras").rep

local s      = ls.snippet
local c      = ls.choice_node
local d      = ls.dynamic_node
local i      = ls.insert_node
local t      = ls.text_node
local snip   = ls.snippet_node

local isnip  = ls.indent_snippet_node
local f      = ls.function_node
local r      = ls.restore_node
local events = require("luasnip.util.events")
local ai     = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local m      = extras.m
local l      = extras.l


ls.add_snippets("lua", {
  s("req", fmta("local <1>= require('<2>')", { i(1), i(2) })),
  s("req2", fmta("local <1>, <2> = require('<3>')", { i(1), i(2), i(3) })),
  s("fun", fmta([[function <1>(<2>)<3>
  end]], { i(1), i(2), i(3) })),
})
