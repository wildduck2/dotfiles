# dadbod -- SQL workflow (DataGrip-style)

Three plugins working together to give a DataGrip-like SQL experience inside
Neovim. This is the main SQL workflow in this config; `sqls` LSP provides
diagnostics and completion as a secondary source, and `nvim-dbee` is available
as an alternative TUI.

## The three plugins

| Plugin | Role |
| --- | --- |
| `tpope/vim-dadbod` | the engine: `:DB <url> SELECT ...` runs SQL against any supported database via a single command. Filetype-restricted to `sql/mysql/plsql`. |
| `kristijanhusak/vim-dadbod-ui` | the DataGrip-style UI sidebar: connections, schemas, tables, saved queries, query history. Lazy-loaded on the commands and on `<leader>db`. |
| `kristijanhusak/vim-dadbod-completion` | live-schema completion source feeding into `nvim-cmp` -- column names, table names, keywords. Lazy on `sql/mysql/plsql` filetypes. |

## Files

- `init.lua` -- all three specs in a single return list. Sets `vim.g.db_ui_*`
  globals, declares the `<leader>db/df/dr/dq` keys lazy uses to trigger
  loading, defines the SQL filetype autocmd binding `<leader>S`, and the cmp
  filetype override for SQL.

There is no `config.lua` in this folder.

## Setting up connections

dadbod-ui resolves connections from three sources, in order:

### 1. Environment variables (best for secrets)

Any env var starting with `DBUI_URL_<NAME>` becomes a connection named `<NAME>`:

```sh
export DBUI_URL_LOCAL="postgresql://user:pass@localhost:5432/dbname"
export DBUI_URL_PROD="mysql://user:pass@db.example.com:3306/prod"
```

dadbod URL format follows the standard scheme://user:pass@host:port/db pattern.
Supported schemes include: `postgres` / `postgresql`, `mysql`, `mariadb`,
`sqlite`, `mongodb`, `redis`, `oracle`, `sqlserver`, `bigquery`, `snowflake`,
`presto`, `clickhouse`, plus more depending on the cli adapter installed.

### 2. JSON file

`vim.g.db_ui_save_location` is set to `vim.fn.stdpath('data') .. '/db_ui'`
(typically `~/.local/share/nvim/db_ui/`). Connections live in
`connections.json` inside that directory, with shape:

```json
[
  { "name": "Local", "url": "postgresql://user:pass@localhost:5432/dbname" }
]
```

### 3. In-UI prompt

`:DBUIAddConnection` prompts for URL and name; result is written to the JSON
file above.

## Keymaps (declared in `init.lua` `keys`)

| Key | Action |
| --- | --- |
| `<leader>db` | `:DBUIToggle` -- open/close the connections sidebar. |
| `<leader>df` | `:DBUIFindBuffer` -- jump the sidebar to the current query buffer. |
| `<leader>dr` | `:DBUIRenameBuffer` -- rename the active query/saved-query. |
| `<leader>dq` | `:DBUILastQueryInfo` -- show timing, row count etc. for the last query. |

## SQL filetype autocmd

When you open a `sql`, `mysql`, or `plsql` buffer, the autocmd
`dadbod-ui-keymaps` group adds:

| Mode | Key | Action |
| --- | --- | --- |
| n | `<leader>S` | `<Plug>(DBUI_ExecuteQuery)` -- run the whole query buffer. |
| v | `<leader>S` | `<Plug>(DBUI_ExecuteQuery)` -- run only the selection. |

This overrides the global `<leader>S` (substitute word under cursor) for SQL
files. Outside SQL buffers the substitute mapping is still active.

## Commands

| Command | Use |
| --- | --- |
| `:DB <url> <sql>` | one-shot query from anywhere. |
| `:DBUI` | open UI. |
| `:DBUIToggle` | open/close UI. |
| `:DBUIAddConnection` | add a connection through the UI. |
| `:DBUIFindBuffer` | jump UI to a query buffer. |
| `:DBUIRenameBuffer` | rename current query buffer. |
| `:DBUILastQueryInfo` | last query stats. |

## `vim.g.*` globals set

| Global | Value | Notes |
| --- | --- | --- |
| `vim.g.db_ui_save_location` | `stdpath('data') .. '/db_ui'` | Where connections.json + saved queries live. |
| `vim.g.db_ui_use_nerd_fonts` | `1` | Pretty sidebar icons. |
| `vim.g.db_ui_execute_on_save` | `0` | Don't auto-run when saving a query buffer; use `<leader>S` explicitly. |
| `vim.g.db_ui_table_helpers` | see below | Templates for the table-helpers menu. |

## Table helpers (`vim.g.db_ui_table_helpers`)

Templates rendered when you hit the table-helper menu in the UI (default
`<leader>R`/`<leader>S` per dadbod-ui binding inside the tree):

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

`{table}` is substituted with the table under the cursor. Add more dialects by
extending the table -- for example `sqlite = { List = ... }`, `mariadb = { ... }`,
`oracle = { ... }` -- using the appropriate identifier quoting (double quotes
for ANSI / postgres, backticks for mysql, square brackets for sqlserver).

## cmp filetype override

In `init.lua`, dadbod-completion's `config` callback sets per-filetype cmp
sources for `sql/mysql/plsql`:

```lua
cmp.setup.filetype({ 'sql', 'mysql', 'plsql' }, {
  sources = cmp.config.sources({
    { name = 'vim-dadbod-completion' },
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  }),
})
```

So SQL buffers always prefer dadbod's live-schema source over `sqls` LSP
completions. This is intentional: dadbod-completion knows about the connection
you're actually using.

## dadbod vs sqls vs dbee

Use this rough split:

| Tool | Best for |
| --- | --- |
| dadbod + dadbod-ui | day-to-day queries: connect, browse schema, run SQL, save queries. Mouse-light, fully buffer-based. |
| `sqls` LSP | per-buffer diagnostics, hover, go-to-definition for SQL identifiers in app source files. Format is disabled (conform owns formatting). |
| `nvim-dbee` (`:Dbee`) | when you want a richer TUI: result tables in a separate window, connection switcher, drawer-style layout. Different UX from dadbod-ui. |

You can run dadbod-ui and dbee side by side; they don't share state.

## Troubleshooting

- `:DB connection failed` -- check the URL works at the shell: `psql <url>`
  / `mysql ...`. The dadbod URL must be parseable by the CLI client.
- `vim-dadbod-completion` not suggesting columns -- the source only attaches
  when the buffer is associated with a connection. Use `:DBUI` to set one, or
  use a `--` modeline `-- db: <connection_name>` at the top of the file.
- Nerd font icons broken in the sidebar -- set `vim.g.have_nerd_font = false`
  in `wild-duck/set.lua` or unset `vim.g.db_ui_use_nerd_fonts = 0` here.
- Queries not running on save -- by design, `db_ui_execute_on_save = 0`.
  Use `<leader>S`.

## External setup required

dadbod itself doesn't ship database clients. You need at least one of:

- `psql` (postgres)
- `mysql` (mysql/mariadb)
- `sqlite3`
- vendor clients (oracle, sqlserver) for those URL schemes

For autocompletion of schema metadata, dadbod-completion uses the same client.

## References

- vim-dadbod: https://github.com/tpope/vim-dadbod
- vim-dadbod-ui: https://github.com/kristijanhusak/vim-dadbod-ui
- vim-dadbod-completion: https://github.com/kristijanhusak/vim-dadbod-completion
