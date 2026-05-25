local ls = require('luasnip')
local fmta = require('luasnip.extras.fmt').fmta

local s = ls.snippet
local i = ls.insert_node
local c = ls.choice_node
local t = ls.text_node

-- React / Next.js snippets for .tsx files.
-- Trigger names start with `r` (react) or `n` (next).
local snips = {
  -- Functional component with typed props.
  s(
    'rfc',
    fmta(
      [[
    type <Name>Props = {
      <props>
    };

    export function <Name2>({ <destruct> }: <Name3>Props) {
      return (
        <<root>>
          <body>
        </<root2>>
      );
    }
    ]],
      {
        Name = i(1, 'Component'),
        Name2 = i(1, 'Component'),
        Name3 = i(1, 'Component'),
        props = i(2, '// props'),
        destruct = i(3, ''),
        root = i(4, 'div'),
        root2 = i(4, 'div'),
        body = i(5, ''),
      }
    )
  ),

  -- Default-export functional component (Next.js page style).
  s(
    'rfd',
    fmta(
      [[
    export default function <Name>() {
      return (
        <<root>>
          <body>
        </<root2>>
      );
    }
    ]],
      {
        Name = i(1, 'Page'),
        root = i(2, 'div'),
        root2 = i(2, 'div'),
        body = i(3, ''),
      }
    )
  ),

  -- useState with typed initial value.
  s(
    'us',
    fmta('const [<name>, set<Setter>] = useState<<Type>>(<initial>);', {
      name = i(1, 'value'),
      Setter = i(2, 'Value'),
      Type = i(3, 'string'),
      initial = i(4, "''"),
    })
  ),

  -- useEffect with deps array.
  s(
    'ue',
    fmta(
      [[
    useEffect(() => {
      <body>
      <cleanup>
    }, [<deps>]);
    ]],
      {
        body = i(1, ''),
        cleanup = c(2, { t(''), t('return () => {};') }),
        deps = i(3, ''),
      }
    )
  ),

  -- useMemo.
  s(
    'um',
    fmta(
      [[
    const <name> = useMemo(() => <expr>, [<deps>]);
    ]],
      { name = i(1, 'value'), expr = i(2, ''), deps = i(3, '') }
    )
  ),

  -- useCallback.
  s(
    'uc',
    fmta(
      [[
    const <name> = useCallback((<args>) => {
      <body>
    }, [<deps>]);
    ]],
      { name = i(1, 'handle'), args = i(2, ''), body = i(3, ''), deps = i(4, '') }
    )
  ),

  -- useRef.
  s(
    'ur',
    fmta(
      'const <name> = useRef<<Type>>(<initial>);',
      { name = i(1, 'ref'), Type = i(2, 'HTMLDivElement'), initial = i(3, 'null') }
    )
  ),

  -- Next.js server action (Next 14+).
  s(
    'nact',
    fmta(
      [[
    'use server';

    export async function <name>(<args>) {
      <body>
    }
    ]],
      { name = i(1, 'action'), args = i(2, 'formData: FormData'), body = i(3, '') }
    )
  ),

  -- Next.js route handler (app router).
  s(
    'nroute',
    fmta(
      [[
    import { NextRequest, NextResponse } from 'next/server';

    export async function <method>(request: NextRequest) {
      <body>
      return NextResponse.json({ <result> });
    }
    ]],
      {
        method = c(1, { t('GET'), t('POST'), t('PUT'), t('DELETE'), t('PATCH') }),
        body = i(2, ''),
        result = i(3, ''),
      }
    )
  ),

  -- React.FC fragment-only return.
  s(
    'rfrag',
    fmta(
      [[
    export function <Name>() {
      return (
        <>
          <body>
        </>
      );
    }
    ]],
      { Name = i(1, 'Component'), body = i(2, '') }
    )
  ),
}

ls.add_snippets('typescriptreact', snips)
