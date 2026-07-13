# PLUGINS

lazy.nvim manages every plugin in this config. The bootstrap lives in
`lua/wild-duck/lazy.lua`; it calls `require('lazy').setup('plugins', ...)`,
which auto-loads every module under `lua/plugins/`. Each plugin lives at
`lua/plugins/<category>/<module>/init.lua` with its options split into a
sibling `config.lua` where the spec needs more than a few lines.

Top-level categories:

- `colorscheme/` -- visual theme(s)
- `cmp/` -- completion engine, sources, snippets
- `conform/` -- formatter wrapper (+ custom formatter overrides)
- `editor/` -- general-purpose editing enhancements
- `fun/` -- non-essential fun plugins
- `git/` -- git integration
- `lang/` -- per-language tooling (treesitter, dadbod, rust, markdown, ...)
- `lsp/` -- LSP, linters, diagnostics surfaces
- `navigation/` -- file/jump pickers and pane navigation
- `tools/` -- standalone utilities
- `ui/` -- statusline, file tree, terminals, popup helpers

The `module` column links to the per-module README under
`docs/plugins/<...>/README.md`.

---

## Master plugin table

| Plugin | What it does | Module |
| --- | --- | --- |
| folke/tokyonight.nvim | Tokyo Night colorscheme | [colorscheme/tokyonight](plugins/colorscheme/tokyonight/README.md) |
| hrsh7th/nvim-cmp | Insert-mode completion engine | [cmp](plugins/cmp/README.md) |
| L3MON4D3/LuaSnip | Snippet engine (LuaSnip) | [cmp](plugins/cmp/README.md) |
| saadparwaiz1/cmp_luasnip | LuaSnip source for nvim-cmp | [cmp](plugins/cmp/README.md) |
| hrsh7th/cmp-buffer | Buffer-words completion source | [cmp](plugins/cmp/README.md) |
| hrsh7th/cmp-path | Filesystem-path completion source | [cmp](plugins/cmp/README.md) |
| hrsh7th/cmp-cmdline | Cmdline completion source | [cmp](plugins/cmp/README.md) |
| hrsh7th/cmp-nvim-lsp | LSP completion source | [cmp](plugins/cmp/README.md) |
| hrsh7th/cmp-nvim-lua | Nvim-lua API completion source | [cmp](plugins/cmp/README.md) |
| rafamadriz/friendly-snippets | Community snippet collection | [cmp/snippets](plugins/cmp/snippets/README.md) |
| stevearc/conform.nvim | Format-on-save with per-filetype formatters | [conform](plugins/conform/README.md) |
| laytan/cloak.nvim | Hide secrets in `.env`/dotenv-like files | [editor/cloak](plugins/editor/cloak/README.md) |
| terrortylor/nvim-comment | `gcc` / `gc` toggle comments | [editor/comment](plugins/editor/comment/README.md) |
| JoosepAlviste/nvim-ts-context-commentstring | Treesitter-aware `commentstring` switching | [editor/comment](plugins/editor/comment/README.md) |
| lukas-reineke/indent-blankline.nvim | Indent guides and scope highlighting | [editor/indent-blankline](plugins/editor/indent-blankline/README.md) |
| echasnovski/mini.nvim | `mini.ai` (textobjects) and `mini.surround` only | [editor/mini](plugins/editor/mini/README.md) |
| ThePrimeagen/refactoring.nvim | Refactor extracts (extract function/var, inline, ...) | [editor/refactoring](plugins/editor/refactoring/README.md) |
| supermaven-inc/supermaven-nvim | Inline AI completions (Tab to accept) | [editor/supermaven](plugins/editor/supermaven/README.md) |
| kevinhwang91/nvim-ufo | Modern folding with treesitter provider | [editor/ufo](plugins/editor/ufo/README.md) |
| kevinhwang91/promise-async | Promise/async dependency for ufo | [editor/ufo](plugins/editor/ufo/README.md) |
| mbbill/undotree | Visual undo-history tree | [editor/undotree](plugins/editor/undotree/README.md) |
| eandrju/cellular-automaton.nvim | Make-it-rain visual effect | [fun/cellular-automaton](plugins/fun/cellular-automaton/README.md) |
| vyfor/cord.nvim | Discord rich presence | [fun/cord](plugins/fun/cord/README.md) |
| letieu/hacker.nvim | Typing animation for "look busy" | [fun/hacker](plugins/fun/hacker/README.md) |
| ty-labs/randiverse.nvim | Random data generators (uuid, email, ip, ...) | [fun/randiverse](plugins/fun/randiverse/README.md) |
| tpope/vim-fugitive | Full Git porcelain inside vim | [git/fugitive](plugins/git/fugitive/README.md) |
| lewis6991/gitsigns.nvim | Git sign column, hunks, blame, diffs | [git/gitsigns](plugins/git/gitsigns/README.md) |
| windwp/nvim-ts-autotag | Auto-close and auto-rename HTML/JSX tags | [lang/autotag](plugins/lang/autotag/README.md) |
| p00f/clangd_extensions.nvim | Clangd extras (AST view, memory usage) | [lang/clangd-extensions](plugins/lang/clangd-extensions/README.md) |
| tpope/vim-dadbod | SQL database engine (`:DB`) | [lang/dadbod](plugins/lang/dadbod/README.md) |
| kristijanhusak/vim-dadbod-ui | Tree-style UI for dadbod | [lang/dadbod](plugins/lang/dadbod/README.md) |
| kristijanhusak/vim-dadbod-completion | Live SQL schema completion source for cmp | [lang/dadbod](plugins/lang/dadbod/README.md) |
| MunifTanjim/nui.nvim | UI primitives (used by package-info) | [lang/package-info](plugins/lang/package-info/README.md) |
| epwalsh/obsidian.nvim | Obsidian vault integration for markdown | [lang/markdown](plugins/lang/markdown/README.md) |
| davidmh/mdx.nvim | MDX filetype support | [lang/markdown](plugins/lang/markdown/README.md) |
| toppair/peek.nvim | Browser preview of markdown (`:PeekOpen`) | [lang/markdown](plugins/lang/markdown/README.md) |
| vuki656/package-info.nvim | Inline package.json version info | [lang/package-info](plugins/lang/package-info/README.md) |
| rust-lang/rust.vim | Rust language support (`rustfmt_autosave`) | [lang/rust](plugins/lang/rust/README.md) |
| mrcjkb/rustaceanvim | rust-analyzer integration with extras | [lang/rust](plugins/lang/rust/README.md) |
| nvim-treesitter/nvim-treesitter | Treesitter parsers and queries (main branch) | [lang/treesitter](plugins/lang/treesitter/README.md) |
| MeanderingProgrammer/treesitter-modules.nvim | Re-implements old nvim-treesitter modules (incremental select, textobjects, swap, move) | [lang/treesitter](plugins/lang/treesitter/README.md) |
| nvim-treesitter/nvim-treesitter-textobjects | Textobject and movement queries (`@function.outer`, etc.) | [lang/treesitter](plugins/lang/treesitter/README.md) |
| chrisgrieser/nvim-lsp-endhints | End-of-line LSP inlay hint renderer | [lsp](plugins/lsp/README.md) |
| folke/lazydev.nvim | Lua workspace expansion for nvim runtime | [lsp](plugins/lsp/README.md) |
| Bilal2453/luvit-meta | `vim.uv` type defs for lazydev | [lsp](plugins/lsp/README.md) |
| mfussenegger/nvim-lint | On-save linter dispatcher | [lsp/lint](plugins/lsp/lint/README.md) |
| neovim/nvim-lspconfig | LSP server configurations | [lsp](plugins/lsp/README.md) |
| williamboman/mason.nvim | LSP/formatter/linter installer | [lsp](plugins/lsp/README.md) |
| williamboman/mason-lspconfig.nvim | Mason <-> lspconfig bridge | [lsp](plugins/lsp/README.md) |
| WhoIsSethDaniel/mason-tool-installer.nvim | Ensures non-LSP tools are installed via mason | [lsp](plugins/lsp/README.md) |
| j-hui/fidget.nvim | LSP progress notifications | [lsp](plugins/lsp/README.md) |
| hedyhli/outline.nvim | Symbol outline panel (`:Outline`) | [lsp](plugins/lsp/README.md) |
| folke/todo-comments.nvim | Highlight and search `TODO:`, `FIX:`, `NOTE:` | [lsp](plugins/lsp/README.md) |
| folke/trouble.nvim | Diagnostics/refs/symbols list panel | [lsp/trouble](plugins/lsp/README.md) |
| ThePrimeagen/harpoon | Pinned-file quick jump list (branch `harpoon2`) | [navigation/harpoon](plugins/navigation/harpoon/README.md) |
| nvim-telescope/telescope.nvim | Fuzzy-finder UI | [navigation/telescope](plugins/navigation/telescope/README.md) |
| nvim-telescope/telescope-fzf-native.nvim | Native fzf sorter for telescope | [navigation/telescope](plugins/navigation/telescope/README.md) |
| nvim-telescope/telescope-ui-select.nvim | `vim.ui.select` replacement via telescope | [navigation/telescope](plugins/navigation/telescope/README.md) |
| christoomey/vim-tmux-navigator | Unified pane navigation across vim and tmux | [navigation/vim-tmux-navigator](plugins/navigation/vim-tmux-navigator/README.md) |
| michaelrommel/nvim-silicon | Render selected code to a PNG (`:Silicon`) | [tools/silicon](plugins/tools/silicon/README.md) |
| nvim-lualine/lualine.nvim | Statusline | [ui/lualine](plugins/ui/lualine/README.md) |
| nvim-tree/nvim-tree.lua | File-explorer sidebar | [ui/nvim-tree](plugins/ui/nvim-tree/README.md) |
| nvim-tree/nvim-web-devicons | Filetype icons (shared) | [ui/nvim-tree](plugins/ui/nvim-tree/README.md) |
| folke/snacks.nvim | Bundle of small UI utilities (indent guides used here) | [ui/snacks](plugins/ui/snacks/README.md) |
| akinsho/toggleterm.nvim | Floating/tab/horizontal terminals | [ui/toggleterm](plugins/ui/toggleterm/README.md) |
| folke/which-key.nvim | Popup that shows pending keymaps | [ui/which-key](plugins/ui/which-key/README.md) |
| folke/zen-mode.nvim | Distraction-free editing mode | [ui/zen-mode](plugins/ui/zen-mode/README.md) |
| nvim-lua/plenary.nvim | Shared Lua utilities (dependency of many) | (no dedicated README) |

---

## By category

### colorscheme

- **tokyonight.nvim** (`folke/tokyonight.nvim`) -- only colorscheme active by
  default. Variant set in `plugins/colorscheme/tokyonight/config.lua` to
  `tokyonight-night`. Alternative specs (catppuccin, rose-pine, onedark,
  kanagawa, transparent) are commented out in `plugins/colorscheme/init.lua`.

### cmp (completion and snippets)

- **nvim-cmp** -- completion engine. Configured in `plugins/cmp/config.lua`
  with sources `lazydev > nvim_lsp > luasnip > path`. Documentation and
  completion windows use rounded borders.
- **LuaSnip** -- snippet engine. Loaded by nvim-cmp via the `luasnip` source;
  custom snippet modules live in `plugins/cmp/snippets/` (lua, typescript,
  tsx, sql, rust, c, cpp). `friendly-snippets` provides the community pack.
- **cmp-buffer, cmp-path, cmp-cmdline, cmp-nvim-lsp, cmp-nvim-lua,
  cmp_luasnip** -- completion source plugins.
- **mason.nvim, mason-lspconfig.nvim** -- pulled in as deps; the real setup
  lives under `lsp/`.

### conform (formatting)

- **conform.nvim** -- runs per-filetype formatters listed in
  `plugins/conform/config.lua`. Format on save via `format_after_save`. Custom
  formatter definitions live in `plugins/conform/formatters/`
  (`sqlfluff.lua`, `clang.lua`, `gofmt.lua`, `goimports.lua`, `lua.lua`,
  `biome.lua`, `rustfmt.lua`). Manual format: `<leader>f`.

### editor (general enhancements)

- **cloak.nvim** -- masks values in `.env*`, `wrangler.toml`, `.dev.vars`.
- **nvim-comment + nvim-ts-context-commentstring** -- treesitter-aware
  `gc`/`gcc` comment toggle.
- **indent-blankline.nvim** -- indent guides with scope highlighting; excludes
  help, NvimTree, Trouble, lazy, mason, toggleterm, dashboard.
- **mini.nvim** -- only `mini.ai` (extended textobjects, n_lines=500) and
  `mini.surround` are loaded.
- **refactoring.nvim** -- bring-up only, no keymaps registered. Invoke
  `:Refactor <name>` directly.
- **supermaven-nvim** -- AI inline completions; `<Tab>` accept, `<C-]>`
  clear, `<C-j>` accept next word.
- **nvim-ufo + promise-async** -- treesitter+indent fold provider; opens with
  large foldlevel by default. Keymaps: `<leader>fR`/`fM`/`fm`.
- **undotree** -- `<leader>u` toggles the undo tree panel.

### fun (non-essential)

- **cellular-automaton.nvim** -- `:CellularAutomaton make_it_rain` (or
  `<leader>mr`).
- **cord.nvim** -- Discord rich presence; shows file, workspace, idle, etc.
- **hacker.nvim** -- `<leader>h` / `<leader>ha` to mimic fast typing.
- **randiverse.nvim** -- inserts random data (`:Randiverse <kind>`);
  `<leader>r{c,d,e,f,h,i,I,l,N,u,U,w}` bindings.

### git

- **vim-fugitive** -- `<leader>gs` opens `:Git` status. Inside the fugitive
  buffer the extra mappings `<leader>p` (push), `<leader>P` (pull),
  `<leader>Pr` (pull rebase), `<leader>Pn` (pull no-rebase), `<leader>t`
  (push -u origin ...) are active.
- **gitsigns.nvim** -- sign column, hunk navigation `]c`/`[c`, hunk actions
  `<leader>h*`, inline blame toggle `<leader>tb`, deleted-line toggle
  `<leader>td`, hunk text object `ih`.

### lang

- **nvim-treesitter** (main branch) + **treesitter-modules.nvim** +
  **nvim-treesitter-textobjects** -- parsers for the ~35 languages listed in
  `plugins/lang/treesitter/config.lua`, plus incremental selection,
  textobjects, move, and swap.
- **nvim-ts-autotag** -- HTML/JSX tag closing and renaming for html, jsx,
  tsx, vue, svelte, php, markdown, astro, glimmer, handlebars.
- **clangd_extensions.nvim** -- C/C++ extras over clangd (AST, memory).
- **package-info.nvim + nui.nvim** -- inline npm package version info in
  `package.json`. `pnpm` is the configured package manager.
- **vim-dadbod + vim-dadbod-ui** -- SQL stack. UI on `<leader>db`.
  `db_manager` (`:DBAdd`, `:DBSwitch`, `:DBScope`, ...) persists named
  connections and pushes them into both dadbod and `duck-sqllsp`.
  Completion / hover / format / diagnostics for SQL all come from
  duck-sqllsp.
- **obsidian.nvim + mdx.nvim + peek.nvim** -- markdown stack. Peek renders to
  a browser via `:PeekOpen` (uses `i3-msg` to split the window manager).
- **rust.vim + rustaceanvim** -- Rust support. rustaceanvim adds RustLsp
  bindings under `<leader>r*` and overrides `K`/`<leader>ca`. The spec is
  currently commented out in `plugins/lang/init.lua`.

### lsp

- **nvim-lspconfig** -- core LSP plumbing. Servers configured in
  `plugins/lsp/lspconfig/config.lua`: clangd, lua_ls, rust_analyzer, ts_ls,
  tailwindcss, cssls, html, jsonls, yamlls, prismals, typos_lsp, biome,
  bashls, dockerls, docker_compose_language_service, mdx_analyzer,
  duck_sqllsp.
- **mason.nvim + mason-lspconfig.nvim + mason-tool-installer.nvim** -- LSP/
  formatter/linter binary management. `ensure_installed` covers every server
  in `M.servers` EXCEPT `duck_sqllsp`, which is built from source at
  `@duck-sqllsp` and installed to `~/.local/bin/duck-sqllsp`.
- **fidget.nvim** -- LSP progress notifications. Configured to avoid the
  nvim-tree sidebar.
- **lazydev.nvim** -- Lua workspace setup for nvim runtime when editing
  `*.lua`.
- **luvit-meta** -- `vim.uv` type stubs loaded on demand via lazydev.
- **nvim-lsp-endhints** -- end-of-line inlay hints with custom prefix `=> `,
  truncated at 40 chars.
- **trouble.nvim** -- diagnostics/LSP results panel. `<leader>xx`,
  `<leader>xX`, `<leader>cs`, `<leader>cl`, `<leader>xL`, `<leader>xQ`.
- **outline.nvim** -- symbol outline (`:Outline`).
- **todo-comments.nvim** -- highlights TODO/FIX/NOTE; signs disabled.
- **nvim-lint** -- runs linters on `BufWritePost`/`InsertLeave`. Linters:
  markdownlint, luacheck, pylint, golangcilint, hadolint.
- **nvim-dap + nvim-dap-ui + nvim-dap-virtual-text + mason-nvim-dap +
  nvim-dap-go + nvim-dap-python** -- debugger stack. js-debug-adapter
  wired directly. Adapters for ts/js, rust, c/cpp, elixir, go, python.
  `<F5>` continue, `<leader>X*` namespace. See `plugins/lsp/dap/`.
- **neotest + neotest-jest + neotest-vitest + neotest-python + neotest-go
  + neotest-rust + neotest-elixir** -- test runner. ✓ / ✗ signs in
  gutter, virtual-text error on failing line, summary panel, DAP debug
  strategy. `<leader>T*` namespace. See `plugins/lsp/neotest/`.

### navigation

- **telescope.nvim + telescope-fzf-native.nvim + telescope-ui-select.nvim +
  nvim-web-devicons** -- main picker stack. `<leader>s*`, `<leader>gf`,
  `<leader>/`, `<leader><leader>`. Telescope results can be sent to Trouble
  via `<leader>n` (insert) or `<leader>tr` (normal). Custom user command
  `:LiveGrepGitRoot`.
- **harpoon** (branch `harpoon2`) + plenary -- pinned-file list. `<leader>a`
  add, `<C-e>` toggle menu, `<C-t/u/n/s>` select slots 1-4.
- **vim-tmux-navigator** -- `<S-h/j/k/l>` move across vim windows and tmux
  panes; `<S-p>` go to previous pane.

### tools

- **nvim-silicon** -- `:Silicon` to render selection to a PNG.

### ui

- **lualine.nvim** -- statusline with mode mapping, branch, diagnostics,
  diff, filename, filetype, progress, location.
- **nvim-tree.lua + nvim-web-devicons** -- file tree. `<leader>pv` toggle,
  `<leader>l` focus. Inside the tree, `s` opens path in `nautilus`.
- **snacks.nvim** -- only the `indent` module is enabled; renders the
  primary indent guides (scope handled by indent-blankline.nvim).
- **toggleterm.nvim** -- terminals open in tabs (`direction = 'tab'`).
- **which-key.nvim** -- key hint popup with group labels for `<leader>c`,
  `<leader>d`, `<leader>e`, `<leader>h`, `<leader>p`, `<leader>q`,
  `<leader>r`, `<leader>s`, `<leader>t`, `<leader>v`, `<leader>w`,
  `<leader>x`, `<leader>y`.
- **zen-mode.nvim** -- `<leader>zz` (105-col with line numbers) and
  `<leader>zZ` (80-col minimal).

### colorscheme alternatives (commented out)

The following entries appear in `plugins/colorscheme/init.lua` but are
disabled:

- `rose-pine/neovim`
- `navarasu/onedark.nvim`
- `rebelot/kanagawa.nvim`
- `xiyaowong/transparent.nvim`
- `plugins.colorscheme.catppuccin` (module reference; no module file present)

---

## Tool binaries (non-plugin dependencies)

These external programs are not installed by lazy.nvim. They must be on
`$PATH`. Where noted, mason-tool-installer ensures them automatically through
`require('mason-tool-installer').setup({ ensure_installed = ... })` in
`plugins/lsp/lspconfig/config.lua` -- specifically, the union of LSP server
names in `M.servers` plus `sqlfluff`.

Formatters (`conform.nvim`):

- `sqlfluff` -- SQL formatter and linter. Auto-installed via mason-tool-installer.
- `stylua` -- Lua formatter. Not in mason-tool-installer list; install manually
  (cargo, brew, or mason directly).
- `clang-format` -- C/C++ formatter. Not in mason-tool-installer list; install
  via system package manager or mason.
- `gofmt`, `goimports` -- Go formatters. Ship with Go (gofmt) or `go install`.
- `rustfmt` -- Rust formatter. Ships with rustup.
- `biome` -- JS/TS/JSON formatter and linter. Auto-installed via
  mason-tool-installer (`biome` server doubles as the formatter binary).
- `prettier` -- HTML/CSS/SCSS/YAML/Markdown/MDX formatter. Not in
  mason-tool-installer list; install manually.
- `shfmt` -- shell formatter. Not in mason-tool-installer list.
- `isort`, `black` -- Python (only listed in `formatters_by_ft`; not installed
  by mason-tool-installer).

Linters (`nvim-lint`):

- `pylint` -- Python linter. Not auto-installed.
- `luacheck` -- Lua linter. Not auto-installed.
- `golangcilint` -- Go linter. Not auto-installed.
- `hadolint` -- Dockerfile linter. Not auto-installed.
- `markdownlint` -- Markdown linter. Not auto-installed.
- `sqlfluff` -- SQL linter (shared with formatter). Auto-installed.

LSP servers (all auto-installed by mason-tool-installer):

- `clangd`, `lua_ls`, `rust_analyzer`, `ts_ls`, `tailwindcss`, `cssls`,
  `html`, `jsonls`, `yamlls`, `prismals`, `typos_lsp`, `biome`, `bashls`,
  `dockerls`, `docker_compose_language_service`, `mdx_analyzer`, `sqls`.

External CLI binaries used elsewhere:

- `ripgrep` (`rg`) -- required by telescope live grep.
- `lazygit` -- not invoked from this config directly, but expected as a
  general dotfiles dependency.
- `gh` -- GitHub CLI, used for `<leader>P*` push/pull operations indirectly
  by the user.
- `nautilus` -- GNOME file explorer; nvim-tree's `s` keybinding shells out to
  it.
- `i3-msg` -- used by peek.nvim's `:PeekOpen`/`:PeekClose` user commands to
  split the i3 window manager.
- `deno` -- build dependency of `peek.nvim` (`deno task build:fast`).
- `make` -- build dependency of `telescope-fzf-native.nvim` and LuaSnip
  (`install_jsregexp`).
- `git` -- used by lazy.nvim to clone plugin specs and by fugitive/gitsigns.
