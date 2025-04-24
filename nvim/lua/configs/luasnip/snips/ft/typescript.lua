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


ls.add_snippets("typescript", {
  s("ea_func", fmta([[
    import { toast } from "sonner";

    export async function <fname>() {
      try {
        const { data } = await <request>();
        if (!data) throw new Error("No data received");

        toast.success("<success_msg>");
        return data;
      } catch (error) {
        toast.error(error?.message || "<error_msg>");
        console.error(error);
      }
    }
  ]], {
    fname = r(1, "fname", i(1, "handleRequest")),
    request = c(2, {
      i(1, "fetchData"),
      i(1, "axios.get('/api/endpoint')"),
      i(1, "apiClient.doSomething()"),
    }),
    success_msg = r(3, "success_msg", i(1, "Operation successful")),
    error_msg = r(4, "error_msg", i(1, "Something went wrong")),
  }))
})
