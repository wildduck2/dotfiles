# conform/formatters

Per-formatter `FileFormatterConfig` definitions. Each file returns a table
that conform merges with its built-in defaults; `init.lua` collects them
under the keys conform looks up. The mapping lives in
`plugins/conform/config.lua`'s `formatters_by_ft`.

## Files

- `init.lua` -- table mapping conform formatter key -> required module.
- `biome.lua`, `clang.lua`, `gofmt.lua`, `goimports.lua`, `lua.lua`,
  `rustfmt.lua`, `sqlfluff.lua` -- one config per formatter.

`init.lua` registers:

```lua
{
  lua          = ... lua.lua (stylua)
  gofumpt      = ... gofmt.lua (key is 'gofumpt' but cmd = gofmt)
  goimports    = ... goimports.lua
  rustfmt      = ... rustfmt.lua
  clang_format = ... clang.lua
  biome        = ... biome.lua
  sqlfluff     = ... sqlfluff.lua
}
```

## lua -- stylua

- Binary: `stylua`.
- Args: `--search-parent-directories --stdin-filepath $FILENAME -`.
- Reads `stylua.toml` (or `.stylua.toml`) walking up from the file.

## clang_format

- Binary: `clang-format`.
- Args: `-assume-filename $FILENAME --fallback-style=Google`.
- Range support uses computed `--offset` / `--length` (full
  range when invoked over a visual selection).
- Reads `.clang-format` from the project tree if present, otherwise falls back
  to Google style.

## gofmt

- Registered under the key `gofumpt` in the conform table but uses the
  `gofmt` binary with no args, stdin.

## goimports

- Binary: `goimports`. No args, stdin.

## rustfmt

- Binary: `rustfmt`.
- Options: `default_edition = '2021'`.
- Args: built from `--emit=stdout` plus `--edition=<detected>` (parsed from
  `Cargo.toml`) or the default `2021`.
- `cwd` resolves from `rustfmt.toml` / `.rustfmt.toml`.

## biome

- Binary: resolved via `conform.util.from_node_modules('biome')` so the
  project's local `node_modules/.bin/biome` wins, falling back to global PATH.
- Args: `format --stdin-file-path $FILENAME`. Stdin.
- Reads `biome.json` / `biome.jsonc` from the project.

## sqlfluff

- Binary: `sqlfluff`. Installed via mason-tool-installer.
- Args: `fix --disable-progress-bar --dialect postgres -`. Stdin.
- Default dialect is `postgres`. Override per project by adding a `.sqlfluff`
  config file at the project root with `[sqlfluff]` `dialect = mysql` (or
  whatever), which sqlfluff picks up automatically.
- The same `--dialect postgres` injection is mirrored in
  `plugins/lsp/lint/config.lua` for the sqlfluff linter, so format and lint
  agree on dialect when no project override exists.

## How to add a formatter override

Create `<name>.lua` with shape:

```lua
return {
  meta = { url = '...', description = '...' },
  command = 'mycmd',
  args = { '--flag', '$FILENAME' }, -- or function(self, ctx) ... end
  stdin = true,
  cwd = conform.util.root_file({ 'mytool.toml' }), -- optional
}
```

Register it in `init.lua` then map filetypes in `../config.lua`.

## References

- stylua: https://github.com/JohnnyMorganz/StyLua
- clang-format: https://clang.llvm.org/docs/ClangFormat.html
- gofmt: https://pkg.go.dev/cmd/gofmt
- goimports: https://pkg.go.dev/cmd/goimports
- rustfmt: https://github.com/rust-lang/rustfmt
- biome: https://github.com/biomejs/biome
- sqlfluff: https://github.com/sqlfluff/sqlfluff
