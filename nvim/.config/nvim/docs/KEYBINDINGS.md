# KEYBINDINGS

Master cheat-sheet of every keymap defined under `lua/`. Grep `<leader>g` (or any
other prefix) to find every mapping starting with that prefix.

Leader is `<Space>` (set in `lua/wild-duck/remap.lua`, `vim.g.mapleader = ' '`,
`vim.g.maplocalleader = ' '`).

Columns in each table:
- Mode: normal `n`, insert `i`, visual `v`, visual-line/block `x`, select `s`,
  operator-pending `o`, terminal `t`.
- Keys: lhs as written in the source.
- Action: rhs or a short description copied from the source.
- Source: file the mapping lives in (relative to `lua/`).

---

## 1. General editing (core remaps)

From `wild-duck/remap.lua`.

| Mode | Keys | Action | Source |
| --- | --- | --- | --- |
| n | `<Esc>` | `<cmd>nohlsearch<CR>` -- clear search highlight | wild-duck/remap.lua |
| n | `<left>` | `<cmd>echo "Use h to move!!"<CR>` -- disable left arrow | wild-duck/remap.lua |
| n | `<right>` | `<cmd>echo "Use l to move!!"<CR>` -- disable right arrow | wild-duck/remap.lua |
| n | `<up>` | `<cmd>echo "Use k to move!!"<CR>` -- disable up arrow | wild-duck/remap.lua |
| n | `<down>` | `<cmd>echo "Use j to move!!"<CR>` -- disable down arrow | wild-duck/remap.lua |
| i | `<C-c>` | `<Esc>` -- alternate escape from insert | wild-duck/remap.lua |
| n | `Q` | `<nop>` -- disable Ex-mode | wild-duck/remap.lua |
| n | `<leader>S` | `:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>` -- substitute word under cursor | wild-duck/remap.lua |
| n | `<leader>x` | `<cmd>!chmod +x %<CR>` -- make current file executable | wild-duck/remap.lua |
| n | `<leader>vpp` | `<cmd>e ~/dotfiles/<CR>` -- open dotfiles dir | wild-duck/remap.lua |
| {n,v} | `<leader>d` | `"_d` -- delete without yanking | wild-duck/remap.lua |
| x | `<leader>p` | `"_dP` -- paste over selection without yanking | wild-duck/remap.lua |

## 2. Window and pane navigation

| Mode | Keys | Action | Source |
| --- | --- | --- | --- |
| n | `<C-h>` | `<C-w><C-h>` -- focus left window | wild-duck/remap.lua |
| n | `<C-l>` | `<C-w><C-l>` -- focus right window | wild-duck/remap.lua |
| n | `<C-j>` | `<C-w><C-j>` -- focus lower window | wild-duck/remap.lua |
| n | `<C-k>` | `<C-w><C-k>` -- focus upper window | wild-duck/remap.lua |
| n | `<S-h>` | `:<C-U>TmuxNavigateLeft<cr>` | plugins/navigation/vim-tmux-navigator/config.lua |
| n | `<S-j>` | `:<C-U>TmuxNavigateDown<cr>` | plugins/navigation/vim-tmux-navigator/config.lua |
| n | `<S-k>` | `:<C-U>TmuxNavigateUp<cr>` | plugins/navigation/vim-tmux-navigator/config.lua |
| n | `<S-l>` | `:<C-U>TmuxNavigateRight<cr>` | plugins/navigation/vim-tmux-navigator/config.lua |
| n | `<S-p>` | `:<C-U>TmuxNavigatePrevious<cr>` -- previous tmux pane | plugins/navigation/vim-tmux-navigator/config.lua |

## 3. Yank, paste, clipboard

| Mode | Keys | Action | Source |
| --- | --- | --- | --- |
| {n,v} | `<leader>y` | `"+y` -- yank to system clipboard | wild-duck/remap.lua |
| n | `<leader>Y` | `"+Y` -- yank line to system clipboard | wild-duck/remap.lua |
| x | `<leader>p` | `"_dP` -- paste over selection without yanking | wild-duck/remap.lua |

`TextYankPost` autocmd runs `vim.highlight.on_yank()` to flash yanked text.

## 4. Move lines and centred motions

| Mode | Keys | Action | Source |
| --- | --- | --- | --- |
| v | `J` | `:m '>+1<CR>gv=gv` -- move selection down | wild-duck/remap.lua |
| v | `K` | `:m '<-2<CR>gv=gv` -- move selection up | wild-duck/remap.lua |
| n | `J` | `mzJ`z` -- join, keep cursor position | wild-duck/remap.lua |
| n | `<C-d>` | `<C-d>zz` -- half-page down, recenter | wild-duck/remap.lua |
| n | `<C-u>` | `<C-u>zz` -- half-page up, recenter | wild-duck/remap.lua |
| n | `n` | `nzzzv` -- next match, recenter, unfold | wild-duck/remap.lua |
| n | `N` | `Nzzzv` -- prev match, recenter, unfold | wild-duck/remap.lua |

## 5. Quickfix and location list

| Mode | Keys | Action | Source |
| --- | --- | --- | --- |
| n | `]q` | `<cmd>cnext<CR>zz` -- next quickfix item | wild-duck/remap.lua |
| n | `[q` | `<cmd>cprev<CR>zz` -- previous quickfix item | wild-duck/remap.lua |
| n | `]l` | `<cmd>lnext<CR>zz` -- next location list item | wild-duck/remap.lua |
| n | `[l` | `<cmd>lprev<CR>zz` -- previous location list item | wild-duck/remap.lua |

## 6. Diagnostics

| Mode | Keys | Action | Source |
| --- | --- | --- | --- |
| n | `[d` | `vim.diagnostic.goto_prev` -- previous diagnostic | wild-duck/remap.lua |
| n | `]d` | `vim.diagnostic.goto_next` -- next diagnostic | wild-duck/remap.lua |
| n | `<leader>e` | `vim.diagnostic.open_float` -- show diagnostic float | wild-duck/remap.lua |
| n | `<leader>q` | `vim.diagnostic.setloclist` -- diagnostics into loclist | wild-duck/remap.lua |

## 7. Completion menu (nvim-cmp)

From `plugins/cmp/config.lua` (insert mode, configured via `cmp.mapping.preset.insert`).

| Mode | Keys | Action | Source |
| --- | --- | --- | --- |
| i | `<C-n>` | `cmp.mapping.select_next_item()` | plugins/cmp/config.lua |
| i | `<C-p>` | `cmp.mapping.select_prev_item()` | plugins/cmp/config.lua |
| i | `<C-b>` | `cmp.mapping.scroll_docs(-4)` -- scroll docs up | plugins/cmp/config.lua |
| i | `<C-f>` | `cmp.mapping.scroll_docs(4)` -- scroll docs down | plugins/cmp/config.lua |
| i | `<C-y>` | `cmp.mapping.confirm { select = true }` -- accept | plugins/cmp/config.lua |
| i | `<C-Space>` | `cmp.mapping.complete {}` -- trigger completion | plugins/cmp/config.lua |
| {i,s} | `<C-l>` | LuaSnip `expand_or_jump` (forward) | plugins/cmp/config.lua |
| {i,s} | `<C-h>` | LuaSnip `jump(-1)` (backward) | plugins/cmp/config.lua |

## 8. Snippets

| Mode | Keys | Action | Source |
| --- | --- | --- | --- |
| {i,s} | `<C-k>` | `luasnip.expand_or_jump()` | plugins/cmp/init.lua |
| {i,s} | `<C-l>` | LuaSnip expand-or-jump forward (shared with cmp) | plugins/cmp/config.lua |
| {i,s} | `<C-h>` | LuaSnip jump backward (shared with cmp) | plugins/cmp/config.lua |

## 9. LSP (on_attach)

Active only in buffers with an LSP client attached. See
`plugins/lsp/lspconfig/config.lua`, function `on_attach`. All bindings are
buffer-local; descriptions are prefixed `LSP:` in `which-key`.

| Mode | Keys | Action | Source |
| --- | --- | --- | --- |
| n | `<leader>ca` | `vim.lsp.buf.code_action` -- code action | plugins/lsp/lspconfig/config.lua |
| n | `<leader>rn` | `vim.lsp.buf.rename` -- rename symbol | plugins/lsp/lspconfig/config.lua |
| n | `gr` | `telescope.builtin.lsp_references` -- goto references | plugins/lsp/lspconfig/config.lua |
| n | `gI` | `telescope.builtin.lsp_implementations` -- goto implementation | plugins/lsp/lspconfig/config.lua |
| n | `gd` | `telescope.builtin.lsp_definitions` -- goto definition | plugins/lsp/lspconfig/config.lua |
| n | `gD` | `vim.lsp.buf.declaration` -- goto declaration | plugins/lsp/lspconfig/config.lua |
| n | `<leader>ds` | `telescope.builtin.lsp_document_symbols` -- document symbols | plugins/lsp/lspconfig/config.lua |
| n | `<leader>ws` | `telescope.builtin.lsp_dynamic_workspace_symbols` -- workspace symbols | plugins/lsp/lspconfig/config.lua |
| n | `<leader>D` | `telescope.builtin.lsp_type_definitions` -- type definition | plugins/lsp/lspconfig/config.lua |
| n | `K` | `vim.lsp.buf.hover` -- hover docs | plugins/lsp/lspconfig/config.lua |
| n | `<leader>th` | toggle `vim.lsp.inlay_hint` for the buffer | plugins/lsp/lspconfig/config.lua |

### Rust LSP (rustaceanvim, overrides `K` and `<leader>ca` in rust buffers)

From `plugins/lang/rust/config.lua`, `server.on_attach`. The rust spec is
currently `add 'plugins.lang.rust'` commented out in `plugins/lang/init.lua`, so
these are only active if that line is re-enabled.

| Mode | Keys | Action |
| --- | --- | --- |
| n | `<leader>ca` | `vim.cmd.RustLsp 'codeAction'` -- grouped code action |
| n | `K` | `vim.cmd.RustLsp { 'hover', 'actions' }` -- hover actions |
| n | `<leader>rd` | `vim.cmd.RustLsp 'debuggables'` |
| n | `<leader>rr` | `vim.cmd.RustLsp 'runnables'` |
| n | `<leader>rt` | `vim.cmd.RustLsp 'testables'` |
| n | `<leader>rm` | `vim.cmd.RustLsp 'expandMacro'` |
| n | `<leader>rc` | `vim.cmd.RustLsp 'openCargo'` |
| n | `<leader>rp` | `vim.cmd.RustLsp 'parentModule'` |
| n | `<leader>rj` | `vim.cmd.RustLsp 'joinLines'` |
| n | `<leader>re` | `vim.cmd.RustLsp 'explainError'` |
| n | `<leader>rD` | `vim.cmd.RustLsp 'renderDiagnostic'` |
| n | `<leader>rk` | `vim.cmd.RustLsp { 'moveItem', 'up' }` |
| n | `<leader>rl` | `vim.cmd.RustLsp { 'moveItem', 'down' }` |
| n | `<leader>rH` | `vim.cmd.RustLsp { 'view', 'hir' }` |
| n | `<leader>rM` | `vim.cmd.RustLsp { 'view', 'mir' }` |

## 10. Formatter (conform.nvim)

| Mode | Keys | Action | Source |
| --- | --- | --- | --- |
| {n,v} | `<leader>f` | `conform.format { lsp_fallback = true, timeout_ms = 1000 }` | plugins/conform/config.lua |

Automatic: conform also runs `format_after_save` on `BufWritePost`.

## 11. Linter (nvim-lint)

No keymaps. Lint runs automatically on `BufWritePost` and `InsertLeave`
(`plugins/lsp/lint/config.lua`). Filetype-to-linter map:
`markdown=markdownlint`, `lua=luacheck`, `python=pylint`, `go=golangcilint`,
`dockerfile=hadolint`, `sql|mysql|plsql=sqlfluff`.

## 12. Treesitter (incremental selection, textobjects, move, swap)

From `plugins/lang/treesitter/config.lua`.

### 12.1 Incremental selection

| Mode | Keys | Action |
| --- | --- | --- |
| n | `<C-space>` | `init_selection` (start) |
| x | `<C-space>` | `node_incremental` (expand to next node) |
| x | `<C-s>` | `scope_incremental` (expand to next scope) |
| x | `<M-space>` | `node_decremental` (shrink) |

### 12.2 Textobjects (operator-pending and visual)

| Mode | Keys | Object |
| --- | --- | --- |
| {o,x} | `aa` | `@parameter.outer` |
| {o,x} | `ia` | `@parameter.inner` |
| {o,x} | `af` | `@function.outer` |
| {o,x} | `if` | `@function.inner` |
| {o,x} | `ac` | `@class.outer` |
| {o,x} | `ic` | `@class.inner` |

### 12.3 Movement

| Mode | Keys | Target |
| --- | --- | --- |
| n | `]m` | next start of `@function.outer` |
| n | `]]` | next start of `@class.outer` |
| n | `]M` | next end of `@function.outer` |
| n | `][` | next end of `@class.outer` |
| n | `[m` | previous start of `@function.outer` |
| n | `[[` | previous start of `@class.outer` |
| n | `[M` | previous end of `@function.outer` |
| n | `[]` | previous end of `@class.outer` |

### 12.4 Swap

| Mode | Keys | Action |
| --- | --- | --- |
| n | `<leader>sp` | swap with next `@parameter.inner` |
| n | `<leader>sP` | swap with previous `@parameter.inner` |

## 13. Telescope

From `plugins/navigation/telescope/config.lua`.

| Mode | Keys | Action |
| --- | --- | --- |
| n | `<leader>sh` | `builtin.help_tags` -- search help |
| n | `<leader>sk` | `builtin.keymaps` -- search keymaps |
| n | `<leader>sf` | `builtin.find_files` -- search files |
| n | `<leader>gf` | `builtin.git_files` -- search git-tracked files |
| n | `<leader>ss` | `builtin.builtin` -- pick a telescope picker |
| n | `<leader>sw` | `builtin.grep_string` -- search current word |
| n | `<leader>sg` | `builtin.live_grep` -- live grep |
| n | `<leader>sd` | `builtin.diagnostics` -- search diagnostics |
| n | `<leader>sr` | `builtin.resume` -- resume last picker |
| n | `<leader>s.` | `builtin.oldfiles` -- recent files |
| n | `<leader><leader>` | `builtin.buffers` -- buffer list |
| n | `<leader>sa` | `<cmd>Telescope ast_grep<CR>` |
| n | `<leader>sj` | `<cmd>Telescope dumb_jump<CR>` |
| n | `<leader>su` | `trouble.toggle { mode = 'document_diagnostics' }` |
| n | `<leader>/` | `builtin.current_buffer_fuzzy_find` (dropdown) |
| n | `<leader>s/` | `builtin.live_grep { grep_open_files = true }` |

Inside a Telescope prompt:

| Mode | Keys | Action |
| --- | --- | --- |
| i | `<leader>n` | open current results in Trouble |
| n | `<leader>tr` | open current results in Trouble |

User command: `:LiveGrepGitRoot` -- live grep scoped to repo root.

## 14. Harpoon

From `plugins/navigation/harpoon/config.lua`.

| Mode | Keys | Action |
| --- | --- | --- |
| n | `<leader>a` | `harpoon:list():add()` -- add file to list |
| n | `<C-e>` | `harpoon.ui:toggle_quick_menu(harpoon:list())` |
| n | `<C-t>` | `harpoon:list():select(1)` -- slot 1 |
| n | `<C-u>` | `harpoon:list():select(2)` -- slot 2 (overrides core `<C-u>` recenter) |
| n | `<C-n>` | `harpoon:list():select(3)` -- slot 3 |
| n | `<C-s>` | `harpoon:list():select(4)` -- slot 4 |

## 15. Trouble

From `plugins/lsp/trouble/init.lua`.

| Mode | Keys | Action |
| --- | --- | --- |
| n | `<leader>xx` | `<cmd>Trouble diagnostics toggle<cr>` |
| n | `<leader>xX` | `<cmd>Trouble diagnostics toggle filter.buf=0<cr>` -- buffer-only |
| n | `<leader>cs` | `<cmd>Trouble symbols toggle focus=false<cr>` |
| n | `<leader>cl` | `<cmd>Trouble lsp toggle focus=false win.position=right<cr>` |
| n | `<leader>xL` | `<cmd>Trouble loclist toggle<cr>` |
| n | `<leader>xQ` | `<cmd>Trouble qflist toggle<cr>` |

Inside a Trouble window (`action_keys` in `plugins/lsp/trouble/config.lua`):

| Keys | Action |
| --- | --- |
| `q` | close |
| `<esc>` | cancel |
| `r` | refresh |
| `<cr>` / `<tab>` / `<2-leftmouse>` | jump |
| `<c-x>` | open split |
| `<c-v>` | open vsplit |
| `<c-t>` | open tab |
| `o` | jump and close |
| `m` | toggle mode (workspace vs document) |
| `s` | switch severity filter |
| `P` | toggle preview |
| `K` | hover |
| `p` | preview |
| `c` | open code href |
| `zM`/`zm` | close folds |
| `zR`/`zr` | open folds |
| `zA`/`za` | toggle fold |
| `k` | previous |
| `j` | next |
| `?` | help |

## 16. Outline (hedyhli/outline.nvim)

No keymaps configured. Invoke with `:Outline`.

## 17. Git: Fugitive

| Mode | Keys | Action | Source |
| --- | --- | --- | --- |
| n | `<leader>gs` | `<cmd>Git<cr>` -- Fugitive status | plugins/git/fugitive/init.lua |

Buffer-local inside a `FileType fugitive` buffer
(`plugins/git/fugitive/config.lua`):

| Mode | Keys | Action |
| --- | --- | --- |
| n | `<leader>p` | `vim.cmd.Git 'push'` |
| n | `<leader>P` | `vim.cmd.Git { 'pull' }` |
| n | `<leader>Pr` | `vim.cmd.Git { 'pull', '--rebase' }` |
| n | `<leader>Pn` | `vim.cmd.Git { 'pull', '--no-rebase' }` |
| n | `<leader>t` | `:Git push -u origin ` (type branch then `<CR>`) |

## 18. Git: Gitsigns

From `plugins/git/gitsigns/config.lua`, `on_attach`. All bindings are
buffer-local in any git-tracked buffer.

| Mode | Keys | Action |
| --- | --- | --- |
| n | `]c` | next hunk (or `]c` in diff mode) |
| n | `[c` | previous hunk (or `[c` in diff mode) |
| n | `<leader>hs` | `gitsigns.stage_hunk` |
| v | `<leader>hs` | stage selected range |
| n | `<leader>hr` | `gitsigns.reset_hunk` |
| v | `<leader>hr` | reset selected range |
| n | `<leader>hS` | `gitsigns.stage_buffer` |
| n | `<leader>hu` | `gitsigns.undo_stage_hunk` |
| n | `<leader>hR` | `gitsigns.reset_buffer` |
| n | `<leader>hp` | `gitsigns.preview_hunk` |
| n | `<leader>hb` | `gitsigns.blame_line { full = true }` |
| n | `<leader>tb` | `gitsigns.toggle_current_line_blame` |
| n | `<leader>hd` | `gitsigns.diffthis` (vs index) |
| n | `<leader>hD` | `gitsigns.diffthis '~'` (vs previous commit) |
| n | `<leader>td` | `gitsigns.toggle_deleted` |
| {o,x} | `ih` | `:<C-U>Gitsigns select_hunk<CR>` -- hunk text object |

## 19. Refactoring

Plugin `ThePrimeagen/refactoring.nvim` is loaded but no keymaps are registered
in this config. Invoke via `:Refactor <name>` or build your own bindings.

## 20. Comments

From `plugins/editor/comment/config.lua` (terrortylor/nvim-comment).

| Mode | Keys | Action |
| --- | --- | --- |
| n | `gcc` | toggle line comment |
| n | `gbc` | toggle block comment |
| {n,v,o} | `gc` | comment operator (e.g. `gcap` to comment paragraph) |
| {o,x} | `ic` | inside-comment text object |

`nvim-ts-context-commentstring` updates `commentstring` via treesitter so the
correct comment style is used inside embedded languages (jsx, vue, etc.).

## 21. SQL: dadbod-ui + .env connect

From `plugins/lang/dadbod/init.lua` (lazy `keys`) and a `FileType` autocmd; plus
`plugins/lang/dadbod/env_connect.lua` for `<leader>de`.

| Mode | Keys | Action |
| --- | --- | --- |
| n | `<leader>db` | `<cmd>DBUIToggle<cr>` -- toggle DBUI |
| n | `<leader>df` | `<cmd>DBUIFindBuffer<cr>` -- find query buffer in UI |
| n | `<leader>dr` | `<cmd>DBUIRenameBuffer<cr>` -- rename query buffer |
| n | `<leader>dq` | `<cmd>DBUILastQueryInfo<cr>` -- last query info |
| n | `<leader>de` | connect to `DATABASE_URL` from nearest `.env` (also `:DBEnvConnect`) |
| n | `<leader>S` | `<Plug>(DBUI_ExecuteQuery)` (buffer-local in `sql`/`mysql`/`plsql`) |
| v | `<leader>S` | execute visual selection |

Inside the .env-connect modal:

| Mode | Keys | Action |
| --- | --- | --- |
| n | `q` | close modal |
| n | `<esc>` | close modal |

Note: `<leader>S` (substitute word under cursor) from `remap.lua` is overridden
in SQL buffers by the buffer-local DBUI execute mapping.

## 22. Database: dbee

From `plugins/lang/dbee/init.lua`. No project-level keymaps. Loaded on the
`:Dbee` command; the plugin's own UI exposes its bindings inside the panels.

## 23. File tree (nvim-tree)

From `plugins/ui/nvim-tree/init.lua` and `config.lua`.

| Mode | Keys | Action |
| --- | --- | --- |
| n | `<leader>pv` | `<cmd>NvimTreeToggle<CR>` |
| n | `<leader>l` | `<cmd>NvimTreeFocus<CR>` |
| n | `<leader>tn` | `<cmd>tabnew<CR>` -- new tab |
| n | `<leader>to` | `<cmd>tabonly<CR>` -- close other tabs |
| n | `<leader>tc` | `<cmd>tabclose<CR>` |
| n | `<leader>t.` | `<cmd>tabnext<CR>` |
| n | `<leader>t,` | `<cmd>tabprev<CR>` |

Buffer-local inside the nvim-tree buffer (in addition to defaults from
`api.config.mappings.default_on_attach`):

| Mode | Keys | Action |
| --- | --- | --- |
| n | `s` | open node path in `nautilus` (Linux file manager) |

## 24. Terminal (toggleterm)

| Mode | Keys | Action | Source |
| --- | --- | --- | --- |
| t | `<Esc><Esc>` | `<C-\><C-n>` -- exit terminal mode | wild-duck/remap.lua |

toggleterm itself is configured with `direction = 'tab'`; no project-level
toggle keymap is registered. Invoke with `:ToggleTerm` (default
`<C-\>` if you set one).

## 25. Zen mode

From `plugins/ui/zen-mode/config.lua` (lazy spec also defines `keys`).

| Mode | Keys | Action |
| --- | --- | --- |
| n | `<leader>zz` | zen mode, 105-col, with line numbers + relative numbers |
| n | `<leader>zZ` | minimal zen mode, 80-col, no numbers, no colorcolumn |

## 26. Undotree

From `plugins/editor/undotree/init.lua` and `plugins/editor/undotree/config.lua`
(both register the same binding):

| Mode | Keys | Action |
| --- | --- | --- |
| n | `<leader>u` | `<cmd>UndotreeToggle<cr>` |

## 27. Folding (nvim-ufo)

From `plugins/editor/ufo/config.lua`.

| Mode | Keys | Action |
| --- | --- | --- |
| n | `<leader>fR` | `require('ufo').openAllFolds` |
| n | `<leader>fM` | `require('ufo').closeAllFolds` |
| n | `<leader>fm` | toggle fold under cursor (`zc` if open else `zo`) |

Standard fold keys also work: `zo`, `zO`, `zc`, `zC`, `za`, `zA`, `zm`, `zM`,
`zr`, `zR`. See `wild-duck/set.lua` for a reminder block.

## 28. package-info (Node package.json)

From `plugins/lang/package-info/config.lua`. Active in `package.json` buffers.

| Mode | Keys | Action |
| --- | --- | --- |
| n | `<leader>ns` | `package-info.show` -- fetch and show versions |
| n | `<leader>nc` | `package-info.hide` |
| n | `<leader>nt` | `package-info.toggle` |
| n | `<leader>nu` | `package-info.update` |
| n | `<leader>nd` | `package-info.delete` |
| n | `<leader>ni` | `package-info.install` |
| n | `<leader>np` | `package-info.change_version` -- pick a version |

## 29. Markdown (peek.nvim)

No keymaps. User commands `:PeekOpen` and `:PeekClose` defined in
`plugins/lang/markdown/config.lua`. Active for `markdown` filetype.

## 30. Supermaven (AI ghost text)

From `plugins/editor/supermaven/config.lua`. These are insert-mode keys handled
by the plugin (not `vim.keymap.set`); they only fire when a suggestion is on
screen.

| Mode | Keys | Action |
| --- | --- | --- |
| i | `<Tab>` | accept full suggestion |
| i | `<C-]>` | clear suggestion |
| i | `<C-j>` | accept next word |

## 31. randiverse (random data generators)

From `plugins/fun/randiverse/config.lua`. Generators inserted via
`:Randiverse <command>`; keymaps are registered by the plugin itself when
`keymaps_enabled = true`.

| Mode | Keys | Action |
| --- | --- | --- |
| n | `<leader>rc` | random country |
| n | `<leader>rd` | random datetime |
| n | `<leader>re` | random email |
| n | `<leader>rf` | random float |
| n | `<leader>rh` | random hexcolor |
| n | `<leader>ri` | random integer |
| n | `<leader>rI` | random ip |
| n | `<leader>rl` | random lorem ipsum |
| n | `<leader>rN` | random name |
| n | `<leader>ru` | random url |
| n | `<leader>rU` | random uuid |
| n | `<leader>rw` | random word |

## 32. Fun: cellular-automaton, hacker, cord

| Mode | Keys | Action | Source |
| --- | --- | --- | --- |
| n | `<leader>mr` | `<cmd>CellularAutomaton make_it_rain<CR>` | wild-duck/remap.lua |
| n | `<leader>ha` | `<cmd>:HackFollowAuto<cr>` | plugins/fun/hacker/config.lua |
| n | `<leader>h` | `<cmd>:Hack<cr>` | plugins/fun/hacker/config.lua |

`cord.nvim` (Discord rich presence) registers no keymaps.

Note: `<leader>h` is a `which-key` group prefix for "Git [H]unk" (gitsigns)
but is also bound directly to `:Hack`. The single-key mapping triggers after
the which-key timeout (`vim.opt.timeoutlen = 300`).

---

## Motions and operators (vanilla vim, for reference)

These are not defined by this config; included as a reminder.

### Basic motion

| Keys | Motion |
| --- | --- |
| `h` `j` `k` `l` | left, down, up, right |
| `w` / `W` | next word / WORD start |
| `b` / `B` | previous word / WORD start |
| `e` / `E` | end of word / WORD |
| `0` | start of line |
| `^` | first non-blank of line |
| `$` | end of line |
| `g_` | last non-blank of line |
| `gg` | first line of file |
| `G` | last line of file |
| `{` / `}` | previous / next blank line (paragraph) |
| `(` / `)` | previous / next sentence |
| `[[` / `]]` | section start prev / next (treesitter overrides to class.outer) |
| `[]` / `][` | section end prev / next (treesitter overrides to class.outer end) |
| `[m` / `]m` | prev / next function start (treesitter) |
| `[M` / `]M` | prev / next function end (treesitter) |
| `f{c}` / `F{c}` | forward / backward to char on line |
| `t{c}` / `T{c}` | forward / backward till char on line |
| `;` / `,` | repeat last `f`/`t` forward / backward |
| `*` / `#` | search word under cursor forward / backward |
| `%` | matching bracket (matchit) |
| `''` | jump to last position |
| `` `` `` | jump to last position (preserves column) |
| `m{a-z}` | set mark |
| `'{a-z}` | jump to mark (line) |
| `` `{a-z} `` | jump to mark (exact position) |
| `<C-o>` / `<C-i>` | jump back / forward in jumplist |
| `gd` | go to local definition (here overridden by LSP) |

### Operator + motion examples

| Keys | Result |
| --- | --- |
| `dw` / `daw` / `diw` | delete word / a-word / inner-word |
| `dap` / `dip` | delete a paragraph / inner paragraph |
| `df,` / `dt,` | delete until comma / before comma |
| `yi"` | yank inside quotes |
| `ci{` | change inside braces |
| `vap` | visually select a paragraph |
| `gqap` | format a paragraph |
| `>ap` / `<ap` | indent / dedent a paragraph |

### Folding (vanilla)

`zo` open, `zO` open recursively, `zc` close, `zC` close recursively, `za`
toggle, `zM` close all, `zR` open all, `zm` `zr` adjust foldlevel by one.

### Window commands (`<C-w>` prefix; here `<C-w>{h,j,k,l}` is bound to a
shortcut via `<C-h>` etc.)

`<C-w>s` split, `<C-w>v` vsplit, `<C-w>q` close, `<C-w>o` only, `<C-w>=` equalise.

---

## Common chord prefixes

Everything bound under each `<leader>` prefix. Some letters double as both
single-key mappings (e.g. `<leader>e`) and group prefixes; which-key
disambiguates after `timeoutlen` (300ms).

### `<leader>c*` -- code / trouble

| Keys | Action |
| --- | --- |
| `<leader>ca` | code action (LSP, or RustLsp grouped) |
| `<leader>cs` | Trouble symbols toggle |
| `<leader>cl` | Trouble LSP defs/refs toggle |

### `<leader>d*` -- diagnostics / delete / database / docs

| Keys | Action |
| --- | --- |
| `<leader>d`  | delete without yanking (n/v) |
| `<leader>db` | DBUI toggle |
| `<leader>df` | DBUI find buffer |
| `<leader>dr` | DBUI rename buffer |
| `<leader>dq` | DBUI last query info |
| `<leader>de` | DB connect from .env |
| `<leader>ds` | LSP document symbols |
| `<leader>D`  | LSP type definition (capital D) |

### `<leader>e*`

| Keys | Action |
| --- | --- |
| `<leader>e` | open diagnostic float |

### `<leader>f*` -- format / fold

| Keys | Action |
| --- | --- |
| `<leader>f`  | conform format buffer (n/v) |
| `<leader>fR` | ufo open all folds |
| `<leader>fM` | ufo close all folds |
| `<leader>fm` | ufo toggle fold under cursor |

### `<leader>g*` -- git

| Keys | Action |
| --- | --- |
| `<leader>gs` | Fugitive status |
| `<leader>gf` | telescope git_files |

### `<leader>h*` -- git hunks (gitsigns) and hacker

| Keys | Action |
| --- | --- |
| `<leader>h`  | `:Hack` (fun/hacker) |
| `<leader>ha` | `:HackFollowAuto` |
| `<leader>hs` | stage hunk |
| `<leader>hr` | reset hunk |
| `<leader>hS` | stage buffer |
| `<leader>hu` | undo stage hunk |
| `<leader>hR` | reset buffer |
| `<leader>hp` | preview hunk |
| `<leader>hb` | blame line (full) |
| `<leader>hd` | diff this (vs index) |
| `<leader>hD` | diff this ~ (vs previous commit) |

### `<leader>l`

| Keys | Action |
| --- | --- |
| `<leader>l` | focus nvim-tree |

### `<leader>m*` -- fun / misc

| Keys | Action |
| --- | --- |
| `<leader>mr` | CellularAutomaton make_it_rain |

### `<leader>n*` -- npm / node packages

| Keys | Action |
| --- | --- |
| `<leader>ns` | package-info show |
| `<leader>nc` | package-info hide |
| `<leader>nt` | package-info toggle |
| `<leader>nu` | package-info update |
| `<leader>nd` | package-info delete |
| `<leader>ni` | package-info install |
| `<leader>np` | package-info change version |

### `<leader>p*` -- project / paste / pull (fugitive-buffer)

| Keys | Action |
| --- | --- |
| `<leader>p`  | paste over selection without yanking (visual) |
| `<leader>p`  | `Git push` (inside fugitive buffer only) |
| `<leader>pv` | NvimTree toggle |
| `<leader>P`  | `Git pull` (fugitive buffer) |
| `<leader>Pr` | `Git pull --rebase` (fugitive buffer) |
| `<leader>Pn` | `Git pull --no-rebase` (fugitive buffer) |

### `<leader>q`

| Keys | Action |
| --- | --- |
| `<leader>q` | diagnostics into loclist |

### `<leader>r*` -- rename / rust / randiverse

| Keys | Action |
| --- | --- |
| `<leader>rn` | LSP rename |
| `<leader>rc` | random country (or RustLsp openCargo) |
| `<leader>rd` | random datetime (or RustLsp debuggables) |
| `<leader>re` | random email (or RustLsp explainError) |
| `<leader>rf` | random float |
| `<leader>rh` | random hexcolor |
| `<leader>ri` | random integer |
| `<leader>rI` | random ip |
| `<leader>rl` | random lorem (or RustLsp moveItem down) |
| `<leader>rN` | random name |
| `<leader>ru` | random url |
| `<leader>rU` | random uuid |
| `<leader>rw` | random word |
| `<leader>rr` | RustLsp runnables |
| `<leader>rt` | RustLsp testables |
| `<leader>rm` | RustLsp expandMacro |
| `<leader>rp` | RustLsp parentModule |
| `<leader>rj` | RustLsp joinLines |
| `<leader>rD` | RustLsp renderDiagnostic |
| `<leader>rk` | RustLsp moveItem up |
| `<leader>rH` | RustLsp view HIR |
| `<leader>rM` | RustLsp view MIR |

Note: randiverse and rustaceanvim claim overlapping letters. Rust spec is
currently disabled in `lua/plugins/lang/init.lua`, so only randiverse bindings
fire by default.

### `<leader>s*` -- search / substitute / swap

| Keys | Action |
| --- | --- |
| `<leader>S`  | substitute word under cursor (or `<Plug>(DBUI_ExecuteQuery)` in SQL) |
| `<leader>sh` | help tags |
| `<leader>sk` | keymaps |
| `<leader>sf` | find files |
| `<leader>ss` | telescope pickers |
| `<leader>sw` | grep current word |
| `<leader>sg` | live grep |
| `<leader>sd` | diagnostics |
| `<leader>sr` | resume |
| `<leader>s.` | recent files |
| `<leader>sa` | telescope ast_grep |
| `<leader>sj` | telescope dumb_jump |
| `<leader>su` | trouble document_diagnostics |
| `<leader>/`  | fuzzy find in current buffer |
| `<leader>s/` | live grep in open files |
| `<leader>sp` | treesitter swap with next parameter |
| `<leader>sP` | treesitter swap with previous parameter |

### `<leader>t*` -- tabs / toggles

| Keys | Action |
| --- | --- |
| `<leader>tn` | new tab |
| `<leader>to` | close other tabs |
| `<leader>tc` | close tab |
| `<leader>t.` | next tab |
| `<leader>t,` | previous tab |
| `<leader>th` | toggle LSP inlay hints |
| `<leader>tb` | toggle gitsigns inline blame |
| `<leader>td` | toggle gitsigns deleted lines |
| `<leader>t`  | `:Git push -u origin ` (in fugitive buffer) |

### `<leader>u`

| Keys | Action |
| --- | --- |
| `<leader>u` | UndotreeToggle |

### `<leader>v*` -- vim config

| Keys | Action |
| --- | --- |
| `<leader>vpp` | open `~/dotfiles/` |

### `<leader>w*`

| Keys | Action |
| --- | --- |
| `<leader>ws` | LSP workspace symbols |

### `<leader>x*` -- trouble / execute

| Keys | Action |
| --- | --- |
| `<leader>x`  | `<cmd>!chmod +x %<CR>` -- make file executable |
| `<leader>xx` | Trouble diagnostics |
| `<leader>xX` | Trouble buffer diagnostics |
| `<leader>xL` | Trouble loclist |
| `<leader>xQ` | Trouble qflist |

### `<leader>X*` -- DAP debugger

See [`plugins/lsp/dap/README.md`](plugins/lsp/dap/README.md) for the full
table and per-language usage.

| Keys | Action |
| --- | --- |
| `<F5>` / `<leader>Xc` | continue / start session |
| `<F10>` / `<leader>Xn` | step over |
| `<F11>` / `<leader>Xi` | step into |
| `<F12>` / `<leader>Xo` | step out |
| `<S-F5>` / `<leader>Xt` | terminate |
| `<leader>Xb` | toggle breakpoint |
| `<leader>XB` | conditional breakpoint (prompt) |
| `<leader>Xl` | log point (prompt) |
| `<leader>XL` | run last configuration |
| `<leader>Xr` | toggle REPL |
| `<leader>Xu` | toggle dap-ui |
| `<leader>Xh` | hover eval under cursor |
| `<leader>Xe` | eval visual / word (n+v) |
| `<leader>Xj` / `<leader>Xk` | stack down / up |
| `<leader>Xq` | clear breakpoints + terminate |

### `<leader>y*`

| Keys | Action |
| --- | --- |
| `<leader>y` | yank to system clipboard (n/v) |
| `<leader>Y` | yank line to system clipboard |

### `<leader>z*` -- zen mode

| Keys | Action |
| --- | --- |
| `<leader>zz` | zen mode (numbered, 105 cols) |
| `<leader>zZ` | zen mode (minimal, 80 cols) |

### `<leader><leader>`

Telescope buffer picker.

### `<leader>a`

Harpoon add current file.

### `<leader>/`

Telescope fuzzy find in current buffer.
