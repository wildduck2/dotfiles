# cmp/snippets -- LuaSnip custom snippets

Snippets we define in this repo. `friendly-snippets` covers the bulk of common
languages; this folder only adds the few that are personal.

Loaded from `plugins/cmp/init.lua` via `pcall(require, 'plugins.cmp.snippets')`
inside LuaSnip's config block (after `from_vscode.lazy_load()`). Expand or jump
forward with `<C-k>` in insert/select mode.

## Files

- `init.lua` -- requires `lua.lua` and `typescript.lua`.
- `lua.lua` -- Lua snippets.
- `typescript.lua` -- TypeScript snippets.

## Lua snippets

| Trigger | Result |
| --- | --- |
| `req` | `local <1> = require('<2>')` |
| `req2` | `local <1>, <2> = require('<3>')` |
| `fun` | function block: `function <1>(<2>) <3> end` |

## TypeScript snippets

| Trigger | Result |
| --- | --- |
| `ea_func` | async function with `sonner` toast wrapping `try { await request() } catch`. Placeholders: `fname` (default `handleRequest`), `request` (choice node with three presets), `success_msg`, `error_msg`. |
| `ea_module` | NestJS `@Module({ controllers, providers, exports, imports })` class. |
| `nest_service` | NestJS `@Injectable()` class with constructor params placeholder. |

## How to add a new language

1. Create `lua/plugins/cmp/snippets/<lang>.lua`.
2. `require('plugins.cmp.snippets.<lang>')` from `snippets/init.lua`.
3. Use `ls.add_snippets('<filetype>', { ... })` with `fmta` for clarity.

## References

- LuaSnip docs: https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md
