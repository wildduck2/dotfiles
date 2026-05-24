# dap — Debug Adapter Protocol stack

Full debugger integration for Neovim built on
[`mfussenegger/nvim-dap`](https://github.com/mfussenegger/nvim-dap). Provides
launch / attach configs, breakpoints, step controls, REPL, watches, scopes,
and an in-editor variable popup for every language we wired:

- JavaScript / TypeScript / React (via `vscode-js-debug`)
- Rust, C, C++ (via `codelldb`)
- Go (via `delve`)
- Python (via `debugpy`)
- Elixir (via `elixir-ls` debug adapter)

> Quick start: open a source file, drop a breakpoint with `<leader>Xb`, hit
> `<F5>` to launch, step with `<F10>` / `<F11>` / `<F12>`, hover with
> `<leader>Xh`. UI auto-opens when a session starts and closes on terminate.

## Files

| File | Role |
| --- | --- |
| `init.lua` | lazy spec — pulls dap, dap-ui, nvim-nio, dap-virtual-text, mason-nvim-dap, and the per-language helpers. Loads on `VeryLazy`. |
| `config.lua` | `mason-nvim-dap` install list, `dap-ui` layout, virtual-text setup, sign icons, listener wiring (auto-open/close UI), `vscode-launch.json` loader, all keymaps. |
| `adapters/init.lua` | calls every adapter module. |
| `adapters/js.lua` | `pwa-node` / `pwa-chrome` configs (launch file, ts loader, attach, Jest, Vitest, Chrome). |
| `adapters/codelldb.lua` | `codelldb` server adapter + Rust cargo target picker + C/C++ binary prompt + attach. |
| `adapters/elixir.lua` | `mix_task` adapter for `mix test`, current-file test, `phx.server`. |
| `adapters/go.lua` | `dap-go.setup()` — delve-based debug / debug_test / attach. |
| `adapters/python.lua` | `dap-python.setup()` pointed at mason debugpy when present; pytest is the default test runner. |

## Plugins installed (mason-nvim-dap)

`mason-nvim-dap` auto-installs these on first run. `automatic_installation`
is `true` so any newly-referenced adapter is also fetched.

| Adapter | Mason package |
| --- | --- |
| codelldb (rust/c/cpp) | `codelldb` |
| js-debug (node/chrome) | `js-debug-adapter` |
| delve (go) | `delve` |
| debugpy (python) | `debugpy` |
| elixir-ls debug adapter | install via `:MasonInstall elixir-ls` (LSP package also ships DAP) |

If a debugger is missing, run `:Mason` and install it manually, or call
`:MasonInstall <package>`.

## Global keybinds

All under the `<leader>X` namespace + F-keys. They are registered in
`config.lua` and shown by `which-key` under `[DAP]`.

### Session control

| Key | Action | DAP function |
| --- | --- | --- |
| `<F5>` / `<leader>Xc` | Continue, or start a debug session if none is active | `dap.continue()` |
| `<F10>` / `<leader>Xn` | Step over (next line, do not enter calls) | `dap.step_over()` |
| `<F11>` / `<leader>Xi` | Step into the next call | `dap.step_into()` |
| `<F12>` / `<leader>Xo` | Step out of the current frame | `dap.step_out()` |
| `<S-F5>` / `<leader>Xt` | Terminate the running session | `dap.terminate()` |
| `<leader>XL` | Re-run the last configuration | `dap.run_last()` |
| `<leader>Xq` | Clear all breakpoints and terminate | custom |

### Breakpoints

| Key | Action |
| --- | --- |
| `<leader>Xb` | Toggle breakpoint on the current line |
| `<leader>XB` | Set conditional breakpoint (prompts for expression) |
| `<leader>Xl` | Set log-point (prompts for log message — no break, just prints) |

### Inspection / UI

| Key | Action |
| --- | --- |
| `<leader>Xu` | Toggle the dap-ui panels (left: scopes / breakpoints / stacks / watches; bottom: repl / console) |
| `<leader>Xr` | Toggle the DAP REPL split |
| `<leader>Xh` | Floating eval of the variable / expression under cursor (`dapui.eval`) |
| `<leader>Xe` | Eval visual selection or word under cursor; works in normal and visual mode |
| `<leader>Xj` | Move down one stack frame |
| `<leader>Xk` | Move up one stack frame |

### Signs

Defined via `vim.fn.sign_define` in `config.lua`.

| Sign | Glyph | Where it appears |
| --- | --- | --- |
| `DapBreakpoint` |  | Regular breakpoint |
| `DapBreakpointCondition` |  | Breakpoint with condition |
| `DapLogPoint` |  | Log point |
| `DapStopped` |  | Current frame (with `Visual` line-highlight) |
| `DapBreakpointRejected` |  | Adapter refused the breakpoint |

## dap-ui internal keybinds

Inside any dap-ui buffer (`dapui_scopes`, `dapui_stacks`, `dapui_watches`,
`dapui_breakpoints`, REPL, console, hover/float):

| Key | Action |
| --- | --- |
| `<CR>` / `<2-LeftMouse>` | Expand / collapse a node |
| `o` | Open (jump to source for the frame / breakpoint under cursor) |
| `d` | Remove (breakpoints / watch entries) |
| `e` | Edit (set value for a variable, edit a watch expression) |
| `r` | Open the REPL prompt with the variable preloaded |
| `t` | Toggle a state flag (e.g. expand-all) |
| `q` / `<Esc>` | Close a floating eval popup |

The bottom layout also exposes inline buttons via `controls.element = 'repl'`
— ▶ continue, ⏵ step over, ⤵ step into, ⤴ step out, ⏹ terminate, ↻ restart,
🔄 reverse continue, ⏸ pause, 🔌 disconnect. Click them with the mouse.

## REPL keybinds

The REPL buffer (`dap.repl.open()` or `<leader>Xr`):

| Key | Action |
| --- | --- |
| `<CR>` (insert) | Send the current line as an expression |
| `<up>` / `<down>` (insert) | Walk the REPL history |
| `<C-l>` | Clear the REPL |
| `.exit` | Disconnect / close the REPL |
| `.help` | Show every REPL command |

Other dot-commands: `.continue`, `.next`, `.into`, `.out`, `.up`, `.down`,
`.goto`, `.scopes`, `.threads`, `.frames`, `.capabilities`, `.b` (toggle
breakpoint).

## VSCode launch.json compatibility

`config.lua` registers each custom adapter type with
`require('dap.ext.vscode').type_to_filetypes()` so nvim-dap knows which
filetypes can resolve `.vscode/launch.json` entries of that type. The
file itself is read on-demand by `dap.continue()` — no global preload.

The mapping currently registered:

```lua
{
  ['pwa-node']   = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
  ['pwa-chrome'] = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
  codelldb       = { 'rust', 'c', 'cpp' },
}
```

Extend the map in `config.lua` to add more types.

## virtual text

`nvim-dap-virtual-text` annotates each line with the current value of every
variable referenced on it (end-of-line). Toggle commands (require
`enabled_commands = true`, which we set):

| Command | What it does |
| --- | --- |
| `:DapVirtualTextEnable` | Turn annotations on |
| `:DapVirtualTextDisable` | Turn annotations off |
| `:DapVirtualTextToggle` | Toggle |
| `:DapVirtualTextForceRefresh` | Re-evaluate every variable now |

## Per-language usage

### TypeScript / JavaScript / React — `adapters/js.lua`

Provided launch configs (pick after `<F5>` when filetype is one of
`javascript`, `typescript`, `javascriptreact`, `typescriptreact`):

1. **Launch file (node)** — runs the current file with the system `node`.
2. **Launch file (tsx loader)** — runs the current `.ts`/`.tsx` file with
   `node --import=tsx`. Requires `tsx` installed (`pnpm add -D tsx` or
   global).
3. **Attach to process** — `pick_process` prompt; the target Node must be
   started with `--inspect` or `--inspect-brk`.
4. **Debug Jest current file** — runs `./node_modules/jest/bin/jest.js
   --runInBand ${file}`. Set breakpoints first.
5. **Debug Vitest current file** — runs `./node_modules/vitest/vitest.mjs
   run ${file}`. Same idea.
6. **Chrome: http://localhost:3000** — launches Chrome and attaches to the
   page at `localhost:3000`. Adjust the URL in a `.vscode/launch.json` when
   you need a different port / host.

Sourcemap path overrides for Webpack are pre-wired. For Next.js / Vite
monorepos with non-default outputs, add a project-local override via
`.vscode/launch.json`.

### Rust / C / C++ — `adapters/codelldb.lua`

Adapter is `codelldb` (LLDB-based, bundled by Mason). Configurations:

- **Rust → Launch (cargo target)** — runs `cargo metadata`, lists every
  `bin` and `example` target, prompts to pick when there is more than one,
  auto-picks when only one exists, falls back to a manual path prompt
  otherwise. Debug profile binaries live at `target/debug/<name>`.
- **Rust → Launch (pick binary)** — manual path prompt + arg prompt
  (space-separated). Use this when you build with custom flags.
- **Rust → Attach to process** — `pick_process` prompt.
- **C / C++ → Launch (pick binary)** — manual path prompt + arg prompt.
- **C / C++ → Attach to process** — `pick_process` prompt.

**Important Rust knob.** Release builds strip debug info. Add the following
to `Cargo.toml` while debugging, otherwise breakpoints may be skipped:

```toml
[profile.dev]
debug = true
opt-level = 0
```

For C/C++ build with `-g -O0` (gcc / clang).

### Elixir — `adapters/elixir.lua`

Adapter is `elixir-ls` (its `debug_adapter.sh` shim). Install via
`:MasonInstall elixir-ls`. Configurations:

- **mix test** — runs the full test suite under the debugger.
- **mix test current file** — runs only `${file}`.
- **phx.server** — boots Phoenix under the debugger so you can break inside
  controllers / live views.

elixir-ls supports breakpoints only in modules listed under
`requireFiles`. For libraries outside `test/`, add the path glob to that
list (or copy the configuration into `.vscode/launch.json`).

### Go — `adapters/go.lua`

`dap-go.setup()` registers four configurations: **Debug**, **Debug
package**, **Attach**, **Debug test**, **Debug last test**. Use the test
helpers from a `_test.go` buffer:

```vim
:lua require('dap-go').debug_test()       " test under cursor
:lua require('dap-go').debug_last_test()  " re-run
```

### Python — `adapters/python.lua`

`dap-python.setup()` pointed at the Mason debugpy venv when present, else
falls back to system `python3`. Registers **Launch file**, **Launch file
with args**, **Launch module**, **Attach**. Pytest helpers:

```vim
:lua require('dap-python').test_method()   " function under cursor
:lua require('dap-python').test_class()    " class under cursor
:lua require('dap-python').debug_selection()
```

The default test runner is `pytest`. Change to `unittest` by editing
`adapters/python.lua`.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `<F5>` does nothing | Filetype has no matching configuration. Check `:lua =require('dap').configurations[vim.bo.filetype]`. |
| Adapter not found | `:Mason` — install the binary. Then re-source / restart Neovim. |
| Rust breakpoints never hit | Rebuild with `debug=true`, `opt-level=0`. Confirm `cargo build` (debug) ran. |
| JS sourcemaps point to `dist/` | Edit `sourceMapPathOverrides` in `adapters/js.lua` or add a per-project `.vscode/launch.json`. |
| UI does not auto-open | A previous session is still attached. `<leader>Xt` to terminate, then `<leader>Xu` to toggle. |
| `:DapVirtualText…` commands missing | Re-source — `enabled_commands = true` must be set before first use. |
| Console output not visible | Toggle the bottom layout via `<leader>Xu`, or `:lua require('dapui').open({ reset = true })`. |

Useful introspection commands:

```vim
:lua =require('dap').status()                                  -- 'running', 'stopped', ''
:lua =require('dap').session()                                 -- nil or session table
:lua =vim.tbl_keys(require('dap').configurations)              -- which filetypes are wired
:lua =require('dap').configurations[vim.bo.filetype]           -- configs available here
:lua require('dap').list_breakpoints()                         -- dump to qflist
```

## References

- nvim-dap: https://github.com/mfussenegger/nvim-dap
- nvim-dap-ui: https://github.com/rcarriga/nvim-dap-ui
- dap-virtual-text: https://github.com/theHamsta/nvim-dap-virtual-text
- mason-nvim-dap: https://github.com/jay-babu/mason-nvim-dap.nvim
- nvim-dap-vscode-js: https://github.com/mxsdev/nvim-dap-vscode-js
- vscode-js-debug: https://github.com/microsoft/vscode-js-debug
- codelldb: https://github.com/vadimcn/codelldb
- nvim-dap-go: https://github.com/leoluz/nvim-dap-go
- nvim-dap-python: https://github.com/mfussenegger/nvim-dap-python
- elixir-ls debug adapter: https://github.com/elixir-lsp/elixir-ls
