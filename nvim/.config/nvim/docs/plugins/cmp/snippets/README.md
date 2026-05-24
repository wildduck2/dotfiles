# cmp/snippets -- LuaSnip custom snippets

Hand-rolled snippets that augment `friendly-snippets`. Loaded from
`plugins/cmp/init.lua` via `pcall(require, 'plugins.cmp.snippets')` inside
LuaSnip's config block (after `from_vscode.lazy_load()`). Expand or jump
forward with `<C-k>` in insert/select mode, jump backward with `<C-j>`.

## Files

- `init.lua` -- loader. Requires `lua`, `typescript`, `tsx`, `sql`, `rust`,
  `c`, `cpp`.
- `lua.lua` -- Lua snippets.
- `typescript.lua` -- TypeScript-only snippets PLUS a general set applied
  to typescript / typescriptreact / javascript / javascriptreact.
- `tsx.lua` -- React (TSX) component / hook snippets.
- `sql.lua` -- SQL DDL/DML snippets.
- `rust.lua` -- Rust snippets.
- `c.lua` -- C snippets.
- `cpp.lua` -- C++ snippets.

## Lua snippets

| Trigger | Result |
| --- | --- |
| `req` | `local <1> = require('<2>')` |
| `req2` | `local <1>, <2> = require('<3>')` |
| `fun` | `function <1>(<2>) <3> end` |

## TypeScript snippets (typescript filetype)

| Trigger | Result |
| --- | --- |
| `ea_func` | async wrapper with `sonner` toast; `try { await request() } catch`. Choice node picks one of three request presets. |
| `ea_module` | NestJS `@Module({ controllers, providers, exports, imports })` |
| `nest_service` | NestJS `@Injectable()` class with constructor params |

## General JS/TS snippets

Applied to `typescript`, `typescriptreact`, `javascript`, `javascriptreact`.

| Trigger | Result |
| --- | --- |
| `imp` | `import { ... } from '...';` |
| `impd` | `import name from '...';` (default import) |
| `af` | `async function name(args): Promise<Ret> { ... }` |
| `arr` | `const name = (args): Ret => body;` |
| `try` | `try { ... } catch (err) { ... }` |
| `fetch` | `await fetch(...)` with method choice node + JSON handling |
| `zod` | zod schema + inferred type |
| `intf` | `export interface Name { ... }` |
| `typ` | `export type Name = ...;` |
| `enum` | `export enum Status { ... }` |
| `cls` | `export class Service { constructor(args){} body }` |
| `swc` | switch / case / default |
| `log` | `console.log('label:', val);` |

## TSX (React) snippets

`tsx` filetype.

| Trigger | Result |
| --- | --- |
| `rfc` | React function component scaffold |
| `rfd` | React function component, default export |
| `us` | `useState` |
| `ue` | `useEffect` |
| `um` | `useMemo` |
| `uc` | `useCallback` |
| `ur` | `useRef` |
| `nact` | Next.js Server Action skeleton |
| `nroute` | Next.js `app/.../route.ts` GET / POST scaffold |
| `rfrag` | `<>...</>` fragment |

## SQL snippets

`sql` filetype.

| Trigger | Result |
| --- | --- |
| `sel` | `SELECT ... FROM ... WHERE ...;` |
| `sela` | `SELECT * FROM ...;` |
| `join` | `JOIN ... ON ...` |
| `cte` | `WITH name AS ( ... ) SELECT ...` |
| `ins` | `INSERT INTO t (cols) VALUES (...);` |
| `inss` | `INSERT INTO t (cols) SELECT ...` |
| `upd` | `UPDATE t SET col=val WHERE ...;` |
| `del` | `DELETE FROM t WHERE ...;` |
| `ct` | `CREATE TABLE ...` |
| `fk` | `FOREIGN KEY (col) REFERENCES t(id)` |
| `idx` | `CREATE INDEX ...` |
| `uidx` | `CREATE UNIQUE INDEX ...` |
| `alta` | `ALTER TABLE t ADD COLUMN ...` |
| `altd` | `ALTER TABLE t DROP COLUMN ...` |
| `tx` | `BEGIN; ... COMMIT;` |
| `win` | window function: `OVER (PARTITION BY ... ORDER BY ...)` |
| `cnt` | `SELECT COUNT(*) FROM t WHERE ...;` |
| `exists` | `EXISTS (SELECT 1 FROM ...)` subquery |
| `upsert` | postgres `INSERT ... ON CONFLICT (...) DO UPDATE` |

## Rust snippets

| Trigger | Result |
| --- | --- |
| `fnr` | `fn name(args) -> Ret { ... }` |
| `fnp` | `pub fn name(args) -> Ret { ... }` |
| `afn` | `async fn name(args) -> Ret { ... }` |
| `struct` | `pub struct Name { fields }` |
| `enumr` | `pub enum Name { variants }` |
| `impl` | `impl Name { ... }` |
| `implt` | `impl Trait for Name { ... }` |
| `trait` | `pub trait Name { ... }` |
| `mat` | `match expr { arms }` |
| `iflet` | `if let Some(x) = expr { ... }` |
| `whlet` | `while let Some(x) = expr { ... }` |
| `matq` | match with `Ok(_)` / `Err(_)` arms |
| `test` | `#[cfg(test)] mod tests { ... }` |
| `testfn` | `#[test] fn name() { ... }` |
| `atest` | `#[tokio::test] async fn name() { ... }` |
| `main` | `fn main() { ... }` |
| `amain` | `#[tokio::main] async fn main() { ... }` |
| `use` | `use path;` |
| `mod` | `mod name;` |
| `pmod` | `pub mod name;` |
| `drv` | `#[derive(Debug, Clone, PartialEq)]` |
| `forr` | `for x in iter { ... }` |
| `log` | `tracing::level!("msg", args);` (level is choice node) |
| `pln` | `println!("{:?}", val);` |

## C snippets

| Trigger | Result |
| --- | --- |
| `inc` | `#include <header>` |
| `incl` | `#include "header"` |
| `def` | `#define NAME value` |
| `main` | `int main(int argc, char **argv) { ... return 0; }` |
| `fn` | `Ret name(args) { ... }` |
| `forr` | `for (int i = 0; i < n; i++) { ... }` |
| `whl` | `while (cond) { ... }` |
| `ife` | `if (cond) { ... } else { ... }` |
| `strc` | `typedef struct Name { ... } Name;` |
| `enm` | `typedef enum { ... } Name;` |
| `mal` | `malloc(...)` with NULL check |
| `free` | `free(p); p = NULL;` |
| `prf` | `printf("...\n", args);` |
| `fprf` | `fprintf(stream, "...", args);` (stream is choice node) |
| `grd` | `#ifndef / #define / #endif` header guard |

## C++ snippets

| Trigger | Result |
| --- | --- |
| `inc` | `#include <iostream>` |
| `incl` | `#include "header.hpp"` |
| `main` | `int main() { ... return 0; }` |
| `cls` | class with constructor + body |
| `strc` | `struct Name { ... };` |
| `ns` | `namespace name { ... }` |
| `tpl` | `template <typename T> ...` |
| `lam` | `auto name = [capture](args) -> Ret { ... };` |
| `forr` | range-for `for (auto& x : container) { ... }` |
| `fori` | C-style index for loop |
| `whl` | `while (cond) { ... }` |
| `try` | `try { ... } catch (const std::exception& e) { ... }` |
| `uniq` | `std::make_unique<Type>(args)` |
| `shrd` | `std::make_shared<Type>(args)` |
| `vec` | `std::vector<Type> name{init};` |
| `cout` | `std::cout << expr << '\n';` |
| `cerr` | `std::cerr << expr << '\n';` |
| `grd` | header guard |
| `ife` | `if/else` |
| `mat` | `switch` (C++ doesn't have native match) |

## How to add a new language

1. Create `lua/plugins/cmp/snippets/<lang>.lua`.
2. Add `require 'plugins.cmp.snippets.<lang>'` to `snippets/init.lua`.
3. Use `ls.add_snippets('<filetype>', { ... })` with `fmta` for clarity.

## References

- LuaSnip docs: https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md
