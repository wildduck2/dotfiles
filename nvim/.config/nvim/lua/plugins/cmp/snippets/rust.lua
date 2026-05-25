local ls = require('luasnip')
local fmta = require('luasnip.extras.fmt').fmta

local s = ls.snippet
local i = ls.insert_node
local c = ls.choice_node
local t = ls.text_node

ls.add_snippets('rust', {
  s(
    'fnr',
    fmta('fn <name>(<args>) -> Result<<Ok>, <Err>> {\n    <body>\n}', {
      name = i(1, 'name'),
      args = i(2, ''),
      Ok = i(3, '()'),
      Err = i(4, 'anyhow::Error'),
      body = i(5, 'Ok(())'),
    })
  ),

  s(
    'fnp',
    fmta(
      'pub fn <name>(<args>) -> <Ret> {\n    <body>\n}',
      { name = i(1, 'name'), args = i(2, ''), Ret = i(3, '()'), body = i(4, '') }
    )
  ),

  s(
    'afn',
    fmta(
      'async fn <name>(<args>) -> <Ret> {\n    <body>\n}',
      { name = i(1, 'name'), args = i(2, ''), Ret = i(3, 'Result<()>'), body = i(4, '') }
    )
  ),

  s(
    'struct',
    fmta(
      [[
  #[derive(<derives>)]
  pub struct <Name> {
      <fields>
  }]],
      { derives = i(1, 'Debug, Clone'), Name = i(2, 'Name'), fields = i(3, 'pub field: String,') }
    )
  ),

  s(
    'enumr',
    fmta(
      [[
  #[derive(<derives>)]
  pub enum <Name> {
      <variants>
  }]],
      { derives = i(1, 'Debug, Clone'), Name = i(2, 'Kind'), variants = i(3, 'Variant,') }
    )
  ),

  s(
    'impl',
    fmta(
      [[
  impl <Name> {
      pub fn new(<args>) -> Self {
          Self { <body> }
      }
  }]],
      { Name = i(1, 'Name'), args = i(2, ''), body = i(3, '') }
    )
  ),

  s(
    'implt',
    fmta(
      'impl <Trait> for <Name> {\n    <body>\n}',
      { Trait = i(1, 'Trait'), Name = i(2, 'Name'), body = i(3, '') }
    )
  ),

  s(
    'trait',
    fmta(
      'pub trait <Name> {\n    <body>\n}',
      { Name = i(1, 'Name'), body = i(2, 'fn method(&self);') }
    )
  ),

  s(
    'mat',
    fmta(
      [[
  match <expr> {
      <pat> => <arm>,
      _ => <def>,
  }]],
      { expr = i(1, ''), pat = i(2, 'Some(v)'), arm = i(3, ''), def = i(4, '()') }
    )
  ),

  s(
    'iflet',
    fmta(
      [[
  if let <pat> = <expr> {
      <body>
  }]],
      { pat = i(1, 'Some(v)'), expr = i(2, ''), body = i(3, '') }
    )
  ),

  s(
    'whlet',
    fmta(
      [[
  while let <pat> = <expr> {
      <body>
  }]],
      { pat = i(1, 'Some(v)'), expr = i(2, ''), body = i(3, '') }
    )
  ),

  s(
    'matq',
    fmta(
      [[
  let <name> = match <expr> {
      <Ok>(v) => v,
      <Err>(e) => return Err(e.into()),
  };]],
      {
        name = i(1, 'value'),
        expr = i(2, ''),
        Ok = c(3, { t('Ok'), t('Some') }),
        Err = c(4, { t('Err'), t('None =>') }),
      }
    )
  ),

  s(
    'test',
    fmta(
      [[
  #[cfg(test)]
  mod tests {
      use super::*;

      #[test]
      fn <name>() {
          <body>
      }
  }]],
      { name = i(1, 'it_works'), body = i(2, 'assert_eq!(2 + 2, 4);') }
    )
  ),

  s(
    'testfn',
    fmta(
      [[
  #[test]
  fn <name>() {
      <body>
  }]],
      { name = i(1, 'test_'), body = i(2, '') }
    )
  ),

  s(
    'atest',
    fmta(
      [[
  #[tokio::test]
  async fn <name>() {
      <body>
  }]],
      { name = i(1, 'test_'), body = i(2, '') }
    )
  ),

  s(
    'main',
    fmta(
      [[
  fn main() -> Result<(), Box<dyn std::error::Error>> {
      <body>
      Ok(())
  }]],
      { body = i(1, '') }
    )
  ),

  s(
    'amain',
    fmta(
      [[
  #[tokio::main]
  async fn main() -> Result<(), Box<dyn std::error::Error>> {
      <body>
      Ok(())
  }]],
      { body = i(1, '') }
    )
  ),

  s('use', fmta('use <path>;', { path = i(1, '') })),

  s('mod', fmta('mod <name>;', { name = i(1, '') })),

  s('pmod', fmta('pub mod <name>;', { name = i(1, '') })),

  s('drv', fmta('#[derive(<list>)]', { list = i(1, 'Debug, Clone, PartialEq') })),

  s(
    'forr',
    fmta(
      [[
  for <name> in <iter> {
      <body>
  }]],
      { name = i(1, 'item'), iter = i(2, 'iter'), body = i(3, '') }
    )
  ),

  s(
    'log',
    fmta('tracing::<level>!("<msg>"<args>);', {
      level = c(1, { t('info'), t('debug'), t('warn'), t('error'), t('trace') }),
      msg = i(2, ''),
      args = i(3, ''),
    })
  ),

  s('pln', fmta('println!("<fmt>"<args>);', { fmt = i(1, '{:?}'), args = i(2, ', val') })),
})
