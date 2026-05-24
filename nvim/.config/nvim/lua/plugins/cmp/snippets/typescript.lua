local ls = require 'luasnip'

local fmta = require('luasnip.extras.fmt').fmta
local r = ls.restore_node

local s = ls.snippet
local c = ls.choice_node
local i = ls.insert_node

ls.add_snippets('typescript', {
  s(
    'ea_func',
    fmta(
      [[
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
  ]],
      {
        fname = r(1, 'fname', i(1, 'handleRequest')),
        request = c(2, {
          i(1, 'fetchData'),
          i(1, "axios.get('/api/endpoint')"),
          i(1, 'apiClient.doSomething()'),
        }),
        success_msg = r(3, 'success_msg', i(1, 'Operation successful')),
        error_msg = r(4, 'error_msg', i(1, 'Something went wrong')),
      }
    )
  ),
})

-- NestJS snippets
ls.add_snippets('typescript', {
  s(
    'ea_module',
    fmta(
      [[
    import { Module } from '@nestjs/common';

    @Module({
      controllers: [<controllers>],
      providers: [<providers>],
      exports: [<exports>],
      imports: [<imports>],
    })
    export class <modulename> {}
  ]],
      {
        controllers = r(1, 'controllers', i(1, '')),
        providers = r(2, 'providers', i(1, '')),
        exports = r(3, 'exports', i(1, '')),
        imports = r(4, 'imports', i(1, '')),
        modulename = r(5, 'modulename', i(1, 'AuthModule')),
      }
    )
  ),
})

ls.add_snippets('typescript', {
  s(
    'nest_service',
    fmta(
      [[
    import { Injectable } from '@nestjs/common';

    @Injectable()
    export class <classname> {
      constructor(<constructor_params>) {}
    }
  ]],
      {
        classname = r(1, 'classname', i(1, 'AuthService')),
        constructor_params = r(2, 'constructor_params', i(1, '')),
      }
    )
  ),
})

local t = ls.text_node

local general_snips = {
  s('imp', fmta("import { <items> } from '<from>';", { items = i(1, ''), from = i(2, '') })),
  s('impd', fmta("import <name> from '<from>';", { name = i(1, ''), from = i(2, '') })),

  s('af', fmta('async function <name>(<args>): Promise<<Ret>> {\n  <body>\n}',
    { name = i(1, 'run'), args = i(2, ''), Ret = i(3, 'void'), body = i(4, '') })),

  s('arr', fmta('const <name> = (<args>): <Ret> => <body>;',
    { name = i(1, 'fn'), args = i(2, ''), Ret = i(3, 'void'), body = i(4, '') })),

  s('try', fmta([[
  try {
    <body>
  } catch (<err>) {
    <handle>
  }]], { body = i(1, ''), err = i(2, 'error'), handle = i(3, 'console.error(error)') })),

  s('fetch', fmta([[
  const response = await fetch(<url>, {
    method: '<method>',
    headers: { 'Content-Type': 'application/json' },
    <body>
  });
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  const data = await response.json();]],
    {
      url = i(1, "'/api/endpoint'"),
      method = c(2, { t 'GET', t 'POST', t 'PUT', t 'DELETE', t 'PATCH' }),
      body = i(3, '// body: JSON.stringify({})'),
    })),

  s('zod', fmta([[
  import { z } from 'zod';

  export const <name>Schema = z.object({
    <fields>
  });

  export type <Type> = z.infer<typeof <name2>Schema>;]],
    { name = i(1, 'User'), fields = i(2, ''), Type = i(1, 'User'), name2 = i(1, 'User') })),

  s('intf', fmta('export interface <Name> {\n  <body>\n}',
    { Name = i(1, 'Name'), body = i(2, '') })),

  s('typ', fmta('export type <Name> = <body>;',
    { Name = i(1, 'Name'), body = i(2, '') })),

  s('enum', fmta([[
  export enum <Name> {
    <body>
  }]], { Name = i(1, 'Status'), body = i(2, '') })),

  s('cls', fmta([[
  export class <Name> {
    constructor(<args>) {<assign>}

    <body>
  }]], { Name = i(1, 'Service'), args = i(2, ''), assign = i(3, ''), body = i(4, '') })),

  s('swc', fmta([[
  switch (<expr>) {
    case <case1>:
      <body1>
      break;
    default:
      <def>
  }]], { expr = i(1, ''), case1 = i(2, ''), body1 = i(3, ''), def = i(4, '') })),

  s('log', fmta("console.log('<label>:', <val>);", { label = i(1, ''), val = i(2, '') })),
}

ls.add_snippets('typescript', general_snips)
ls.add_snippets('typescriptreact', general_snips)
ls.add_snippets('javascript', general_snips)
ls.add_snippets('javascriptreact', general_snips)
