local ls = require('luasnip')
local fmta = require('luasnip.extras.fmt').fmta

local s = ls.snippet
local i = ls.insert_node
local c = ls.choice_node
local t = ls.text_node

local snips = {
  s('inc', fmta('#include <<header>>', { header = i(1, 'iostream') })),
  s('incl', fmta('#include "<header>"', { header = i(1, 'header.hpp') })),

  s(
    'main',
    fmta(
      [[
  #include <iostream>

  int main(int argc, char **argv) {
      <body>
      return 0;
  }]],
      { body = i(1, '') }
    )
  ),

  s(
    'cls',
    fmta(
      [[
  class <Name> {
  public:
      <Name2>(<ctor_args>);
      ~<Name3>();

  private:
      <members>
  };]],
      {
        Name = i(1, 'Name'),
        Name2 = i(1, 'Name'),
        ctor_args = i(2, ''),
        Name3 = i(1, 'Name'),
        members = i(3, ''),
      }
    )
  ),

  s('strc', fmta('struct <Name> {\n    <body>\n};', { Name = i(1, 'Name'), body = i(2, '') })),

  s(
    'ns',
    fmta(
      'namespace <name> {\n    <body>\n} // namespace <name2>',
      { name = i(1, 'app'), body = i(2, ''), name2 = i(1, 'app') }
    )
  ),

  s(
    'tpl',
    fmta(
      [[
  template <typename <T>>
  <Ret> <name>(<args>) {
      <body>
  }]],
      { T = i(1, 'T'), Ret = i(2, 'T'), name = i(3, 'fn'), args = i(4, ''), body = i(5, '') }
    )
  ),

  s(
    'lam',
    fmta('auto <name> = [<capture>](<args>) -> <Ret> {\n    <body>\n};', {
      name = i(1, 'fn'),
      capture = i(2, ''),
      args = i(3, ''),
      Ret = i(4, 'void'),
      body = i(5, ''),
    })
  ),

  s(
    'forr',
    fmta(
      [[
  for (<Type> <name> : <iter>) {
      <body>
  }]],
      {
        Type = c(1, { t('auto'), t('auto const&'), t('auto&') }),
        name = i(2, 'item'),
        iter = i(3, ''),
        body = i(4, ''),
      }
    )
  ),

  s(
    'fori',
    fmta(
      [[
  for (<Type> <i> = <start>; <i2> < <end>; ++<i3>) {
      <body>
  }]],
      {
        Type = i(1, 'int'),
        i = i(2, 'i'),
        start = i(3, '0'),
        i2 = i(2, 'i'),
        ['end'] = i(4, 'n'),
        i3 = i(2, 'i'),
        body = i(5, ''),
      }
    )
  ),

  s('whl', fmta('while (<cond>) {\n    <body>\n}', { cond = i(1, ''), body = i(2, '') })),

  s(
    'try',
    fmta(
      [[
  try {
      <body>
  } catch (<Exc> <e>) {
      <handler>
  }]],
      {
        body = i(1, ''),
        Exc = i(2, 'const std::exception&'),
        e = i(3, 'e'),
        handler = i(4, "std::cerr << e.what() << '\\n';"),
      }
    )
  ),

  s(
    'uniq',
    fmta(
      'auto <name> = std::make_unique<<Type>>(<args>);',
      { name = i(1, 'p'), Type = i(2, 'T'), args = i(3, '') }
    )
  ),

  s(
    'shrd',
    fmta(
      'auto <name> = std::make_shared<<Type>>(<args>);',
      { name = i(1, 'p'), Type = i(2, 'T'), args = i(3, '') }
    )
  ),

  s(
    'vec',
    fmta('std::vector<<Type>> <name><init>;', {
      Type = i(1, 'int'),
      name = i(2, 'v'),
      init = c(3, { t(''), t('{}'), t('(n)'), t('{a, b, c}') }),
    })
  ),

  s('cout', fmta("std::cout << <expr> << '\\n';", { expr = i(1, '"hello"') })),
  s('cerr', fmta("std::cerr << <expr> << '\\n';", { expr = i(1, 'e.what()') })),

  s(
    'grd',
    fmta(
      [[
  #pragma once

  <body>]],
      { body = i(1, '') }
    )
  ),

  s(
    'ife',
    fmta(
      [[
  if (<cond>) {
      <ifb>
  } else {
      <elseb>
  }]],
      { cond = i(1, ''), ifb = i(2, ''), elseb = i(3, '') }
    )
  ),

  s(
    'mat',
    fmta(
      [[
  switch (<expr>) {
      case <case1>: <body1>; break;
      default: <def>;
  }]],
      { expr = i(1, ''), case1 = i(2, ''), body1 = i(3, ''), def = i(4, '') }
    )
  ),
}

ls.add_snippets('cpp', snips)
