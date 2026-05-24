local ls = require 'luasnip'
local fmta = require('luasnip.extras.fmt').fmta

local s = ls.snippet
local i = ls.insert_node
local c = ls.choice_node
local t = ls.text_node

local snips = {
  s('sel', fmta([[
  SELECT <cols>
  FROM <table>
  WHERE <cond>;]],
    { cols = i(1, '*'), table = i(2, 'table'), cond = i(3, 'true') })),

  s('sela', fmta([[
  SELECT <cols>
  FROM <table> AS <a>
  WHERE <cond>;]],
    { cols = i(1, 'a.*'), table = i(2, 'table'), a = i(3, 't'), cond = i(4, 'true') })),

  s('join', fmta([[
  SELECT <cols>
  FROM <left> AS l
  <jtype> JOIN <right> AS r ON l.<lk> = r.<rk>;]],
    {
      cols = i(1, 'l.*, r.*'),
      left = i(2, 'left_table'),
      jtype = c(3, { t 'INNER', t 'LEFT', t 'RIGHT', t 'FULL' }),
      right = i(4, 'right_table'),
      lk = i(5, 'id'),
      rk = i(6, 'left_id'),
    })),

  s('cte', fmta([[
  WITH <name> AS (
    <query>
  )
  SELECT <cols> FROM <name2>;]],
    { name = i(1, 'cte'), query = i(2, 'SELECT 1'), cols = i(3, '*'), name2 = i(1, 'cte') })),

  s('ins', fmta([[
  INSERT INTO <table> (<cols>)
  VALUES (<vals>)
  RETURNING <ret>;]],
    { table = i(1, 'table'), cols = i(2, ''), vals = i(3, ''), ret = i(4, 'id') })),

  s('inss', fmta([[
  INSERT INTO <table> (<cols>)
  SELECT <select_cols>
  FROM <source>
  RETURNING <ret>;]],
    { table = i(1, 'target'), cols = i(2, ''), select_cols = i(3, ''), source = i(4, 'source'), ret = i(5, 'id') })),

  s('upd', fmta([[
  UPDATE <table>
  SET <set>
  WHERE <cond>
  RETURNING <ret>;]],
    { table = i(1, 'table'), set = i(2, 'col = value'), cond = i(3, 'id = $1'), ret = i(4, 'id') })),

  s('del', fmta([[
  DELETE FROM <table>
  WHERE <cond>
  RETURNING <ret>;]],
    { table = i(1, 'table'), cond = i(2, 'id = $1'), ret = i(3, 'id') })),

  s('ct', fmta([[
  CREATE TABLE IF NOT EXISTS <name> (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    <fields>
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
  );]],
    { name = i(1, 'table'), fields = i(2, 'name VARCHAR(255) NOT NULL,') })),

  s('fk', fmta(
    "CONSTRAINT fk_<col> FOREIGN KEY (<col2>) REFERENCES <ref_table> (<ref_col>) ON DELETE <on_delete>",
    {
      col = i(1, 'user_id'),
      col2 = i(1, 'user_id'),
      ref_table = i(2, 'users'),
      ref_col = i(3, 'id'),
      on_delete = c(4, { t 'CASCADE', t 'SET NULL', t 'RESTRICT', t 'NO ACTION' }),
    })),

  s('idx', fmta(
    "CREATE INDEX IF NOT EXISTS idx_<table>_<col> ON <table2> (<col2>);",
    { table = i(1, 'table'), col = i(2, 'col'), table2 = i(1, 'table'), col2 = i(2, 'col') })),

  s('uidx', fmta(
    "CREATE UNIQUE INDEX IF NOT EXISTS uidx_<table>_<col> ON <table2> (<col2>);",
    { table = i(1, 'table'), col = i(2, 'col'), table2 = i(1, 'table'), col2 = i(2, 'col') })),

  s('alta', fmta(
    "ALTER TABLE <table>\n    ADD COLUMN <col> <type><nullable>;",
    {
      table = i(1, 'table'),
      col = i(2, 'col'),
      type = i(3, 'VARCHAR(255)'),
      nullable = c(4, { t '', t ' NOT NULL', t ' NOT NULL DEFAULT NULL' }),
    })),

  s('altd', fmta("ALTER TABLE <table>\n    DROP COLUMN <col>;",
    { table = i(1, 'table'), col = i(2, 'col') })),

  s('tx', fmta([[
  BEGIN;
    <body>
  COMMIT;]], { body = i(1, '') })),

  s('win', fmta([[
  SELECT <cols>,
         ROW_NUMBER() OVER (PARTITION BY <part> ORDER BY <ord>) AS <alias>
  FROM <table>;]],
    {
      cols = i(1, '*'),
      part = i(2, 'col'),
      ord = i(3, 'created_at DESC'),
      alias = i(4, 'rn'),
      table = i(5, 'table'),
    })),

  s('cnt', fmta('SELECT COUNT(*) FROM <table><cond>;',
    { table = i(1, 'table'), cond = c(2, { t '', t ' WHERE ' }) })),

  s('exists', fmta([[
  SELECT <cols>
  FROM <table> AS t
  WHERE EXISTS (
    SELECT 1 FROM <sub> WHERE <cond>
  );]],
    { cols = i(1, '*'), table = i(2, 'table'), sub = i(3, 'other'), cond = i(4, 'other.t_id = t.id') })),

  s('upsert', fmta([[
  INSERT INTO <table> (<cols>)
  VALUES (<vals>)
  ON CONFLICT (<key>) DO UPDATE
  SET <set>
  RETURNING <ret>;]],
    { table = i(1, 'table'), cols = i(2, ''), vals = i(3, ''), key = i(4, 'id'), set = i(5, ''), ret = i(6, 'id') })),
}

ls.add_snippets('sql', snips)
ls.add_snippets('mysql', snips)
ls.add_snippets('plsql', snips)
