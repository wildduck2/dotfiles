local ls = require 'luasnip'

local fmta = require('luasnip.extras.fmt').fmta

local s = ls.snippet
local i = ls.insert_node

ls.add_snippets('lua', {
  s('req', fmta("local <1>= require('<2>')", { i(1), i(2) })),
  s('req2', fmta("local <1>, <2> = require('<3>')", { i(1), i(2), i(3) })),
  s('fun', fmta([[function <1>(<2>)<3>
  end]], { i(1), i(2), i(3) })),
})
