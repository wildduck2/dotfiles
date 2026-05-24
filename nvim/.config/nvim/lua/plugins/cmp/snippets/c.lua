local ls = require 'luasnip'
local fmta = require('luasnip.extras.fmt').fmta

local s = ls.snippet
local i = ls.insert_node
local c = ls.choice_node
local t = ls.text_node

local snips = {
  s('inc', fmta('#include <<header>>', { header = i(1, 'stdio.h') })),
  s('incl', fmta('#include "<header>"', { header = i(1, 'header.h') })),
  s('def', fmta('#define <name> <value>', { name = i(1, 'NAME'), value = i(2, '0') })),

  s('main', fmta([[
  #include <stdio.h>

  int main(int argc, char **argv) {
      <body>
      return 0;
  }]], { body = i(1, '') })),

  s('fn', fmta('<Ret> <name>(<args>) {\n    <body>\n}',
    { Ret = i(1, 'void'), name = i(2, 'name'), args = i(3, ''), body = i(4, '') })),

  s('forr', fmta('for (<Type> <i> = <start>; <i2> < <end>; <i3>++) {\n    <body>\n}',
    { Type = i(1, 'int'), i = i(2, 'i'), start = i(3, '0'), i2 = i(2, 'i'), ['end'] = i(4, 'n'), i3 = i(2, 'i'), body = i(5, '') })),

  s('whl', fmta('while (<cond>) {\n    <body>\n}', { cond = i(1, ''), body = i(2, '') })),

  s('ife', fmta([[
  if (<cond>) {
      <ifb>
  } else {
      <elseb>
  }]], { cond = i(1, ''), ifb = i(2, ''), elseb = i(3, '') })),

  s('strc', fmta([[
  typedef struct <Name> {
      <fields>
  } <Name2>;]], { Name = i(1, 'Name'), fields = i(2, ''), Name2 = i(1, 'Name') })),

  s('enm', fmta([[
  typedef enum {
      <values>
  } <Name>;]], { values = i(1, ''), Name = i(2, 'Name') })),

  s('mal', fmta(
    "<Type> *<name> = malloc(<count> * sizeof(<Type2>));\nif (!<name2>) { <err> }",
    { Type = i(1, 'int'), name = i(2, 'p'), count = i(3, 'n'), Type2 = i(1, 'int'), name2 = i(2, 'p'), err = i(4, 'return -1;') })),

  s('free', fmta('free(<ptr>);\n<ptr2> = NULL;', { ptr = i(1, 'p'), ptr2 = i(1, 'p') })),

  s('prf', fmta('printf("<fmt>\\n"<args>);', { fmt = i(1, '%d'), args = i(2, ', val') })),
  s('fprf', fmta('fprintf(<stream>, "<fmt>\\n"<args>);',
    { stream = c(1, { t 'stderr', t 'stdout' }), fmt = i(2, '%d'), args = i(3, ', val') })),

  s('grd', fmta([[
  #ifndef <GUARD>
  #define <GUARD2>

  <body>

  #endif]], { GUARD = i(1, 'HEADER_H'), GUARD2 = i(1, 'HEADER_H'), body = i(2, '') })),
}

ls.add_snippets('c', snips)
