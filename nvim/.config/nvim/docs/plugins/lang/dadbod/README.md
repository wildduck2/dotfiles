# dadbod -- SQL workflow

DataGrip-style SQL inside Neovim built on top of `vim-dadbod` plus a local
connection manager (`db_manager`). Completion, hover, formatting, and
diagnostics for SQL come from `duck-sqllsp` (configured in
`plugins/lsp/lspconfig/`), NOT from a separate completion plugin.

## Plugins

| Plugin | Role |
| --- | --- |
| `tpope/vim-dadbod` | engine: `:DB <url> SELECT ...` runs SQL against any supported database. Lazy on the `:DB` command and on `sql/mysql/plsql` filetypes. |
| `kristijanhusak/vim-dadbod-ui` | DataGrip-style sidebar: connections, schemas, tables, saved queries, query history. Lazy on its commands and on `<leader>db`. |

`vim-dadbod-completion` is **not** installed here. duck-sqllsp owns SQL
completion.

## Files

| File | What |
| --- | --- |
| `init.lua` | lazy specs for vim-dadbod and vim-dadbod-ui. Sets `vim.g.db_ui_*` globals, declares the `<leader>db/df/dr/dq` UI keys, defines the SQL filetype autocmd binding `<leader>S` for `<Plug>(DBUI_ExecuteQuery)`. Calls `db_manager.setup()` in `init`. |
| `db_manager.lua` | orchestrator. Loads store, registers commands, pushes connection list into duck-sqllsp via `vim.lsp.config('duck_sqllsp', { init_options = wiring.initialization_options() })`, refreshes dadbod globals (`vim.g.dbs`, `vim.g.db`). |
| `store.lua` | persistent connection store. Two JSON files under `stdpath('data')`: `db_connections.json` (list of connections, chmod 0600) and `db_active.json` (`{ active, scope }`). |
| `urls.lua` | URL builders for the two consumers — dadbod URL (`postgres://...`) and duck-sqllsp connection spec (`{ alias, driver, dataSourceName }`). |
| `wiring.lua` | pushes state into vim-dadbod (`vim.g.dbs`, `vim.g.db`, `b:db`) and duck-sqllsp (via `initializationOptions.duckSqllsp` and `workspace/didChangeConfiguration`). |
| `ui.lua` | UI primitives — `info` / `warn` notifications, error modal, prompt-chain wizard, picker, list modal. |
| `commands.lua` | `:DB*` user commands and `<leader>db*` keymaps for add / edit / delete / switch / list / scope / refresh. |

## Connection storage

`db_connections.json`:

```json
[
  {
    "name": "Local",
    "driver": "postgresql",
    "host": "localhost",
    "port": "5432",
    "user": "postgres",
    "password": "postgres",
    "database": "mydb",
    "schema": "public"
  }
]
```

`db_active.json`:

```json
{ "active": "Local", "scope": "all" }
```

`scope` controls duck-sqllsp completion: `all` (all databases / schemas
listed), `db` (active database only), `schema` (active schema only).

Edit either file directly or use `:DBAdd` / `:DBEdit` / `:DBDelete`.
Connections file is `chmod 0600` because it holds plaintext credentials.

## Drivers supported by `:DBAdd`

The interactive picker lists `postgresql`, `mysql`, `sqlite3`. dadbod
itself supports many more URLs (oracle, sqlserver, mongodb, bigquery,
snowflake, presto, clickhouse, mariadb). Add those by editing
`db_connections.json` directly with a pre-built `dsn`.

## Keymaps — dadbod-ui (declared in `init.lua` `keys`)

| Key | Action |
| --- | --- |
| `<leader>db` | `:DBUIToggle` — open/close the connections sidebar |
| `<leader>df` | `:DBUIFindBuffer` — jump sidebar to current query buffer |
| `<leader>dr` | `:DBUIRenameBuffer` — rename query / saved query |
| `<leader>dq` | `:DBUILastQueryInfo` — timing / rows for the last query |

## Keymaps — db_manager (registered by `commands.register()`)

| Key | Action |
| --- | --- |
| `<leader>dba` | `:DBAdd` — add connection via wizard |
| `<leader>dbe` | `:DBEdit` — edit existing connection |
| `<leader>dbd` | `:DBDelete` — delete a connection |
| `<leader>dbs` | `:DBSwitch` — switch active connection (pushed to duck-sqllsp) |
| `<leader>dbl` | `:DBList` — modal listing all connections |
| `<leader>dbc` | `:DBScope` — set completion scope (`all` / `db` / `schema`) |

> `<leader>db` is both a direct map (`DBUIToggle`) AND a prefix for the
> chord keys above. Vim resolves on `timeoutlen` — pressing only
> `<leader>db` fires after the timeout. Adjust `:set timeoutlen` if the
> wait is noticeable.

## SQL filetype autocmd

When you open a `sql`, `mysql`, or `plsql` buffer the autocmd group
`dadbod-ui-keymaps` adds:

| Mode | Key | Action |
| --- | --- | --- |
| n | `<leader>S` | `<Plug>(DBUI_ExecuteQuery)` — run whole buffer |
| v | `<leader>S` | `<Plug>(DBUI_ExecuteQuery)` — run selection |

Overrides the global `<leader>S` (substitute-word) for SQL only.

## Commands

### dadbod-ui

| Command | Use |
| --- | --- |
| `:DB <url> <sql>` | one-shot query from anywhere |
| `:DBUI` / `:DBUIToggle` | open / toggle UI |
| `:DBUIAddConnection` | dadbod-ui's own add (writes to `db_ui_save_location`) |
| `:DBUIFindBuffer` | jump UI to current query buffer |
| `:DBUIRenameBuffer` | rename current query buffer |
| `:DBUILastQueryInfo` | last query stats |

### db_manager

| Command | Use |
| --- | --- |
| `:DBAdd` | wizard — picks driver, then prompts host/port/user/password/database/schema |
| `:DBEdit` | edit an existing connection |
| `:DBDelete` | delete a connection |
| `:DBSwitch` | switch active connection; pushes via LSP didChangeConfiguration |
| `:DBList` | modal listing every stored connection |
| `:DBScope` | set duck-sqllsp completion scope |
| `:DBRefresh` | reload from disk and re-push to dadbod + LSP |

## `vim.g.*` globals set

| Global | Value |
| --- | --- |
| `vim.g.db_ui_save_location` | `stdpath('data') .. '/db_ui'` (saved queries, sessions) |
| `vim.g.db_ui_use_nerd_fonts` | `1` |
| `vim.g.db_ui_execute_on_save` | `0` — use `<leader>S` explicitly |
| `vim.g.db_ui_table_helpers` | postgresql + mysql `List` / `Count` templates |
| `vim.g.dbs` | refreshed by `wiring.refresh_dadbod()` — list of `{ name, url }` |
| `vim.g.db` | active connection URL (used by `:DB`) |

## Table helpers (`vim.g.db_ui_table_helpers`)

`{table}` is substituted with the table under the cursor in the UI tree.

```lua
postgresql = {
  List  = 'SELECT * FROM "{table}" LIMIT 200;',
  Count = 'SELECT COUNT(*) FROM "{table}";',
},
mysql = {
  List  = 'SELECT * FROM `{table}` LIMIT 200;',
  Count = 'SELECT COUNT(*) FROM `{table}`;',
},
```

Add dialects by extending the table — `sqlite = { ... }`, `oracle = { ... }`
— using the appropriate identifier quoting.

## Integration with duck-sqllsp

`db_manager.setup()` ships `wiring.initialization_options()` into the
duck-sqllsp config via `vim.lsp.config('duck_sqllsp', { init_options = ... })`.
The server reads
`{ duckSqllsp = { connections, activeConnection, scope } }` on attach. On
`:DBSwitch` / `:DBScope`, `wiring` emits
`workspace/didChangeConfiguration` so the running server updates without
restart.

duck-sqllsp must be on `PATH` as `duck-sqllsp`. Build from the
`@duck-sqllsp` Rust workspace and install with `cargo install --path .`
or `install -m 0755 target/release/duck-sqllsp ~/.local/bin/`.

## Troubleshooting

- `:DB connection failed` — verify the URL works at the shell (`psql <url>`,
  `mysql ...`). dadbod URLs must be parseable by the CLI client.
- Completion stale after editing a connection — `:DBRefresh` or
  `:LspRestart duck_sqllsp`.
- Nerd font icons broken in the sidebar — set `vim.g.have_nerd_font = false`
  in `wild-duck/set.lua` or `vim.g.db_ui_use_nerd_fonts = 0` here.
- Queries not running on save — by design, `db_ui_execute_on_save = 0`.
  Use `<leader>S`.
- Password leaked in `:messages` — UI prompt uses `hidden = true`; check
  any custom logger / fidget config if it leaks.

## External setup required

dadbod itself doesn't ship database clients. Install at least one:

- `psql` (postgres)
- `mysql` (mysql/mariadb)
- `sqlite3`
- vendor clients (oracle, sqlserver) for those URL schemes

duck-sqllsp speaks to the same clients, so installing them covers both
the engine and the LSP.

## References

- vim-dadbod: https://github.com/tpope/vim-dadbod
- vim-dadbod-ui: https://github.com/kristijanhusak/vim-dadbod-ui
- duck-sqllsp: see `@duck-sqllsp` workspace
