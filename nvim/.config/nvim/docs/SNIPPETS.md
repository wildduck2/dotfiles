# Snippets reference

Triggers live in `lua/plugins/cmp/snippets/*.lua`. Expand with `<C-y>` (cmp
confirm) or `<C-k>` (luasnip expand_or_jump). Jump forward with `<C-l>`,
backward with `<C-h>`.

## Lua (`lua/plugins/cmp/snippets/lua.lua`)

| Trigger | Output |
|---------|--------|
| `req`   | `local X = require('Y')` |
| `req2`  | `local X, Y = require('Z')` |
| `fun`   | `function name(args) end` |

## TypeScript and JavaScript (`typescript.lua`)

Registered for `typescript`, `typescriptreact`, `javascript`, `javascriptreact`.

| Trigger     | Output                                          |
|-------------|-------------------------------------------------|
| `imp`       | `import { items } from 'from';`                 |
| `impd`      | default import                                  |
| `af`        | `async function ...(): Promise<Ret>`            |
| `arr`       | arrow function with return type                 |
| `try`       | try/catch block                                 |
| `fetch`     | fetch() call with method choice and error check |
| `zod`       | zod schema + inferred type                      |
| `intf`      | `export interface ... {}`                       |
| `typ`       | `export type ... = ...`                         |
| `enum`      | `export enum ... {}`                            |
| `cls`       | class with constructor and assignment           |
| `swc`       | switch/case skeleton                            |
| `log`       | `console.log('label:', val);`                   |
| `ea_func`   | NestJS-style async toast handler                |
| `ea_module` | NestJS @Module decorator                        |
| `nest_service` | NestJS @Injectable class                     |

## TSX (`tsx.lua`)

Registered for `typescriptreact`.

| Trigger | Output |
|---------|--------|
| `rfc`   | React functional component with typed props |
| `rfd`   | `export default function` component (Next.js page) |
| `rfrag` | component returning a `<></>` fragment |
| `us`    | `useState<Type>(initial)` |
| `ue`    | `useEffect(() => {}, [deps])` with optional cleanup |
| `um`    | `useMemo(() => expr, [deps])` |
| `uc`    | `useCallback((args) => {}, [deps])` |
| `ur`    | `useRef<Type>(null)` |
| `nact`  | Next.js server action (`'use server';`) |
| `nroute`| Next.js app-router route handler with method choice |

## SQL (`sql.lua`)

Registered for `sql`, `mysql`, `plsql`.

| Trigger  | Output |
|----------|--------|
| `sel`    | basic SELECT/FROM/WHERE |
| `sela`   | SELECT with alias |
| `join`   | SELECT with JOIN (INNER/LEFT/RIGHT/FULL choice) |
| `cte`    | WITH ... AS (...) SELECT |
| `ins`    | INSERT ... VALUES ... RETURNING |
| `inss`   | INSERT ... SELECT ... RETURNING |
| `upd`    | UPDATE ... SET ... WHERE ... RETURNING |
| `del`    | DELETE ... WHERE ... RETURNING |
| `ct`     | CREATE TABLE IF NOT EXISTS with id/created_at/updated_at |
| `fk`     | FOREIGN KEY constraint with ON DELETE choice |
| `idx`    | CREATE INDEX |
| `uidx`   | CREATE UNIQUE INDEX |
| `alta`   | ALTER TABLE ADD COLUMN with nullable choice |
| `altd`   | ALTER TABLE DROP COLUMN |
| `tx`     | BEGIN ... COMMIT |
| `win`    | ROW_NUMBER OVER PARTITION window |
| `cnt`    | SELECT COUNT(*) |
| `exists` | SELECT WHERE EXISTS (...) |
| `upsert` | INSERT ... ON CONFLICT DO UPDATE |

## Rust (`rust.lua`)

| Trigger  | Output |
|----------|--------|
| `fnr`    | `fn name(args) -> Result<Ok, Err>` |
| `fnp`    | `pub fn` with return type |
| `afn`    | `async fn ... -> Ret` |
| `struct` | `#[derive(...)] pub struct` |
| `enumr`  | `#[derive(...)] pub enum` |
| `impl`   | `impl Name { pub fn new() -> Self }` |
| `implt`  | `impl Trait for Name` |
| `trait`  | `pub trait Name {}` |
| `mat`    | `match expr { pat => arm, _ => def }` |
| `iflet`  | `if let pat = expr {}` |
| `whlet`  | `while let pat = expr {}` |
| `matq`   | early-return match (Ok/Err pattern) |
| `test`   | `#[cfg(test)] mod tests` block |
| `testfn` | single `#[test]` function |
| `atest`  | `#[tokio::test] async fn` |
| `main`   | `fn main() -> Result<(), Box<dyn Error>>` |
| `amain`  | `#[tokio::main] async fn main` |
| `use`    | `use path;` |
| `mod`    | `mod name;` |
| `pmod`   | `pub mod name;` |
| `drv`    | `#[derive(Debug, Clone, PartialEq)]` |
| `forr`   | `for item in iter {}` |
| `log`    | `tracing::level!("msg", args);` (level choice) |
| `pln`    | `println!("{:?}", val);` |

## C (`c.lua`)

| Trigger | Output |
|---------|--------|
| `inc`   | `#include <header>` |
| `incl`  | `#include "header"` |
| `def`   | `#define NAME value` |
| `main`  | `int main(int argc, char **argv)` |
| `fn`    | function definition |
| `forr`  | counted for loop |
| `whl`   | while loop |
| `ife`   | if/else |
| `strc`  | `typedef struct Name {} Name;` |
| `enm`   | `typedef enum {} Name;` |
| `mal`   | `malloc` with null-check |
| `free`  | `free(p); p = NULL;` |
| `prf`   | `printf(...)` |
| `fprf`  | `fprintf(stderr/stdout, ...)` |
| `grd`   | header include guard |

## C++ (`cpp.lua`)

| Trigger | Output |
|---------|--------|
| `inc`   | `#include <header>` |
| `incl`  | `#include "header"` |
| `main`  | `int main(int argc, char **argv)` |
| `cls`   | class with ctor/dtor and private section |
| `strc`  | `struct Name {}` |
| `ns`    | `namespace name {}` block |
| `tpl`   | `template <typename T>` function |
| `lam`   | `auto fn = [capture](args) -> Ret {}` |
| `forr`  | range-for with auto choice |
| `fori`  | counted for loop |
| `whl`   | while loop |
| `try`   | try/catch with `const std::exception&` default |
| `uniq`  | `std::make_unique<T>(args)` |
| `shrd`  | `std::make_shared<T>(args)` |
| `vec`   | `std::vector<T> name` with init choice |
| `cout`  | `std::cout << expr << '\n';` |
| `cerr`  | `std::cerr << expr << '\n';` |
| `grd`   | `#pragma once` |
| `ife`   | if/else |
| `mat`   | switch/case |

## How to add a new snippet

1. Open the file for the target language under `lua/plugins/cmp/snippets/`.
2. Add an entry inside the table passed to `ls.add_snippets(...)`:

```lua
s('trigger', fmta([[
multiline
template with <holes>
]], { holes = i(1, 'default') }))
```

3. Available helpers: `i` (insert node), `c` (choice node), `t` (text node).
4. Reload nvim or re-source the file.

## Cmp menu keymaps

| Key       | Action |
|-----------|--------|
| `<C-n>`   | Next item |
| `<C-p>`   | Previous item |
| `<C-y>`   | Confirm |
| `<C-Space>` | Trigger completion |
| `<C-b>`   | Scroll docs up |
| `<C-f>`   | Scroll docs down |
| `<C-l>`   | Jump forward in snippet placeholders |
| `<C-h>`   | Jump backward in snippet placeholders |
| `<C-k>`   | LuaSnip `expand_or_jump` |
