# neotest — test runner

`nvim-neotest/neotest` with adapters for **jest**, **vitest**, **pytest**,
**go test**, **cargo test** (`neotest-rust`), and **ExUnit** (`neotest-elixir`).
Runs tests, shows ✓ / ✗ signs in the gutter, virtual text with the failure
message on the failing line, and a summary tree of every test in the
project.

Composes with the DAP stack: `strategy = 'dap'` makes neotest boot a
debugger session with the right adapter args so breakpoints work in the
test under cursor without writing a launch config.

## Files

- `init.lua` — lazy spec, adapter dependencies, all keymaps.
- `config.lua` — `neotest.setup{}` — adapter table, status / sign / icon /
  diagnostic / summary panel config.

## Plugins

| Plugin | Role |
| --- | --- |
| `nvim-neotest/neotest` | Core framework |
| `nvim-neotest/nvim-nio` | Async runtime (shared with DAP) |
| `nvim-lua/plenary.nvim` | Utility lib |
| `antoinemadec/FixCursorHold.nvim` | Workaround for slow `CursorHold` |
| `nvim-neotest/neotest-jest` | Jest adapter |
| `marilari88/neotest-vitest` | Vitest adapter |
| `nvim-neotest/neotest-python` | pytest adapter |
| `nvim-neotest/neotest-go` | go test adapter |
| `jfpedroza/neotest-elixir` | ExUnit adapter |

**Not loaded**

- **neotest-rust** — broken (`table index is nil` at init.lua:414). Use
  DAP directly for rust tests: `cargo test --no-run`, then `<F5>` →
  "Launch (pick binary)" → `target/debug/deps/<crate>-<hash>` with args
  `test_name --exact --nocapture`. Or wait for `rustaceanvim` (commented
  out in `lang/init.lua`) which ships its own test runner.
- **C / C++** — no quality neotest adapter exists. Debug test binaries
  via DAP directly: build with `-g`, `<F5>` → "Launch (pick binary)".

## Global keymaps — `<leader>T*` namespace

`T` is uppercase to avoid collision with the existing `<leader>t*` tab
keys (`tn / to / tc / t. / t,`).

| Key | Action |
| --- | --- |
| `<leader>Tr` | Run nearest test (function under cursor) |
| `<leader>Tt` | Run all tests in current file |
| `<leader>TT` | Run every test in the project |
| `<leader>Tl` | Run last test |
| `<leader>Td` | Debug nearest test via DAP — breakpoints honored |
| `<leader>TD` | Debug last test via DAP |
| `<leader>Ts` | Toggle summary panel (tree of all tests with status) |
| `<leader>To` | Open output of current test (floating window, auto-close) |
| `<leader>TO` | Toggle output panel (every run, persistent bottom split) |
| `<leader>TS` | Stop running test(s) |
| `<leader>Tw` | Toggle watch mode on the current file — re-runs on save |
| `[t` / `]t` | Jump to previous / next failed test |

## Summary panel — internal keymaps

Inside the panel (open with `<leader>Ts`):

| Key | Action |
| --- | --- |
| `<CR>` / `<2-LeftMouse>` | Expand / collapse the node |
| `e` | Expand all |
| `i` | Jump to test in source buffer |
| `o` | Show short output |
| `O` | Short output (alt key — same action with `short = 'O'`) |
| `r` | Run the test (or directory / file) under cursor |
| `d` | Debug the test under cursor (DAP strategy) |
| `m` | Mark a test |
| `M` | Clear all marks |
| `R` | Run all marked tests |
| `D` | Debug all marked tests |
| `t` | Target the test (filter view to it) |
| `T` | Clear target |
| `a` | Attach to a running test (tail its output) |
| `u` | Stop the test |
| `w` | Toggle watch on the test |
| `J` / `K` | Jump to next / previous failed test in panel |

## Status feedback

- **Gutter signs**: `✓` passed (green), `✗` failed (red), `◍` running
  (blue), `○` skipped (grey). Defined via `vim.fn.sign_define` for
  `neotest_passed/failed/running/skipped`.
- **Virtual text**: failing assertion message appears on the failing line
  (status.virtual_text = true).
- **Diagnostics**: failed tests register as ERROR-level diagnostics so
  trouble / lualine count them.
- **Summary tree**: live progress as tests run.

## Per-adapter notes

### jest

`jestCommand = 'npx jest --'`. Auto-detects config file:

- In a monorepo (`/packages/*`), uses `<pkg>/jest.config.ts`.
- Otherwise `${cwd}/jest.config.js`.

Override per project by editing `config.lua` or by adding a
`.neotest.lua` in the repo (advanced — see neotest docs).

`env = { CI = true }` runs tests non-interactively.

### vitest

Filters `node_modules` from discovery so the tree only shows your tests.
Default vitest command + config detection — works for most setups.

### pytest

`runner = 'pytest'`, `dap.justMyCode = false` (so DAP can step into
library code).

### go

Default `go test` invocation. Discovers via `_test.go` files.

### elixir

ExUnit. Needs `mix` in PATH. Discovers `test/**/*_test.exs`.

## DAP strategy — debug a single test

Drop a breakpoint inside the test → `<leader>Td`. neotest:

1. Resolves the test name + file
2. Boots DAP with the matching adapter (jest = vscode-js-debug, pytest =
   debugpy, go = delve, rust = codelldb, elixir = elixir-ls)
3. Hits your breakpoint with full step / scope / watch support

No `.vscode/launch.json` needed.

## Output panel

`<leader>To` opens a floating window with the failing test's stdout /
stderr / formatted assertion diff. `<leader>TO` opens a persistent split
that accumulates output across runs — useful while running watch mode.

## Watch mode

`<leader>Tw` toggles watch for the current file. On every save, neotest
re-runs the file's tests and updates signs. The watch icon (👁) appears
beside the test in the summary panel.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| "No tests found" | Adapter not matching. `:lua =require('neotest').state.adapter_ids()` should list the right adapter for the project. |
| Jest can't find config | Edit `jestConfigFile` callback in `config.lua` or set `NEOTEST_JEST_CONFIG` env var. |
| Vitest only sees some tests | Make sure `vitest.config.ts` includes the right patterns. |
| Signs not visible | `:set signcolumn=yes`. Check `:lua =vim.fn.sign_getdefined('neotest_passed')`. |
| DAP strategy fails | Run the relevant DAP install first — neotest reuses our adapters in `plugins/lsp/dap/`. |
| pytest stuck in venv | Adapter detects venv automatically but only if it's at `.venv` or active. Activate before launching nvim. |

## References

- neotest: https://github.com/nvim-neotest/neotest
- neotest-jest: https://github.com/nvim-neotest/neotest-jest
- neotest-vitest: https://github.com/marilari88/neotest-vitest
- neotest-python: https://github.com/nvim-neotest/neotest-python
- neotest-go: https://github.com/nvim-neotest/neotest-go
- neotest-rust: https://github.com/rouge8/neotest-rust
- neotest-elixir: https://github.com/jfpedroza/neotest-elixir
