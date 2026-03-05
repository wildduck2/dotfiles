# Neovim Configuration

A modular Neovim configuration built on [lazy.nvim](https://github.com/folke/lazy.nvim) with full LSP support, intelligent completion, formatting, linting, and a rich set of development tools.

## Requirements

- **Neovim** >= 0.11
- **Git** >= 2.19
- A [Nerd Font](https://www.nerdfonts.com/) (icons, glyphs, statusline)
- A terminal with true-color support
- **GNU Stow** (for dotfile symlink management)

## Quick Start

```bash
# Clone the dotfiles repo
git clone https://github.com/<your-user>/dotfiles ~/dotfiles
cd ~/dotfiles

# Install system dependencies (Arch Linux)
./nvim/setup.sh

# Symlink nvim config via stow
stow nvim

# Launch nvim — lazy.nvim auto-installs plugins on first run
nvim
```

On first launch, Mason will auto-install all configured LSP servers. Treesitter will auto-install all configured parsers. This may take a minute.

## Directory Structure

```
nvim/.config/nvim/
├── init.lua                        # Entry point — loads wild-duck core
├── lazy-lock.json                  # Plugin version lock file
├── package.json                    # Node deps (svelte-language-server)
├── spell/en.utf-8.add              # Custom spell dictionary
│
├── after/ft/
│   └── lua.lua                     # Lua filetype overrides
│
└── lua/
    ├── wild-duck/                  # Core configuration
    │   ├── init.lua                # Loads remap -> set -> lazy
    │   ├── remap.lua               # Global keybindings
    │   ├── set.lua                 # Vim options & settings
    │   └── lazy.lua                # lazy.nvim bootstrap
    │
    └── plugins/                    # Plugin modules (auto-loaded by lazy.nvim)
        ├── colorschemes/           # Theme configurations
        ├── telescope/              # Fuzzy finder & search
        ├── treesitter/             # Syntax highlighting & text objects
        ├── lsp/                    # LSP, Mason, diagnostics
        ├── cmp/                    # Completion engine & snippets
        │   └── snippets/           # Custom LuaSnip snippets (lua, typescript)
        ├── conform/                # Code formatting
        │   └── formatters/         # Per-formatter config overrides
        ├── lint/                   # Linting (nvim-lint)
        ├── nvim-tree/              # File explorer sidebar
        ├── git/                    # Fugitive & Gitsigns
        ├── harpoon/                # Quick file navigation
        ├── trouble/                # Diagnostics list & todo-comments
        ├── editing/                # Comment, refactoring, cloak
        ├── ui/                     # Lualine, toggleterm, zen-mode, which-key, indent guides
        ├── utils/                  # Plenary, undotree, tmux-navigator, mini, ufo, silicon
        ├── fun/                    # Hacker.nvim, randiverse, cellular-automaton
        ├── languages/              # Rust, C/C++, package-info, dbee
        ├── markdown/               # Obsidian, MDX, peek (preview)
        ├── discord/                # Discord Rich Presence (cord.nvim)
        └── supermaven/             # AI code completion
```

Each plugin module follows the same pattern:

```
plugins/{module}/
├── init.lua        # lazy.nvim plugin spec (dependencies, lazy-loading, keys)
└── configs.lua     # Configuration data & setup functions
```

## Plugin Inventory (74 plugins)

### Core
| Plugin | Purpose |
|--------|---------|
| lazy.nvim | Plugin manager |
| plenary.nvim | Lua utility library (dependency for many plugins) |

### Navigation & Search
| Plugin | Purpose | Trigger |
|--------|---------|---------|
| telescope.nvim | Fuzzy finder | `<leader>sf`, `<leader>sg`, `<leader><leader>` |
| telescope-fzf-native | Native FZF sorter for telescope | auto |
| telescope-ui-select | Use telescope for `vim.ui.select` | auto |
| harpoon2 | Quick file marks | `<leader>a`, `<C-e>`, `<C-t/u/n/s>` |
| nvim-tree.lua | File explorer sidebar | `<leader>pv`, `<leader>l` |
| nvim-web-devicons | File type icons | auto |

### LSP & Completion
| Plugin | Purpose |
|--------|---------|
| nvim-lspconfig | LSP client configuration |
| mason.nvim | LSP/tool installer |
| mason-lspconfig | Bridge mason <-> lspconfig |
| mason-tool-installer | Auto-install configured tools |
| fidget.nvim | LSP progress indicator |
| lazydev.nvim | Neovim Lua API completion |
| nvim-cmp | Completion engine |
| cmp-nvim-lsp | LSP completion source |
| cmp-path | File path completion source |
| LuaSnip | Snippet engine |
| cmp_luasnip | Snippet completion source |
| friendly-snippets | Community snippet collection |

### Syntax & Editing
| Plugin | Purpose |
|--------|---------|
| nvim-treesitter | Syntax highlighting & parsing |
| nvim-treesitter-textobjects | Code-aware text objects |
| nvim-ts-autotag | Auto close/rename HTML tags |
| playground | Treesitter query playground |
| nvim_comment | Toggle comments (`gcc`, `gc`) |
| refactoring.nvim | Code refactoring tools |
| cloak.nvim | Hide secrets in `.env` files |

### Formatting & Linting
| Plugin | Purpose |
|--------|---------|
| conform.nvim | Code formatting (format-on-save) |
| nvim-lint | Asynchronous linting |

### Git
| Plugin | Purpose | Trigger |
|--------|---------|---------|
| vim-fugitive | Git commands | `<leader>gs` |
| gitsigns.nvim | Git gutter signs & hunk actions | `<leader>hs`, `]c`/`[c` |

### UI & UX
| Plugin | Purpose | Trigger |
|--------|---------|---------|
| lualine.nvim | Statusline | auto |
| which-key.nvim | Keybinding hints | auto (after `<leader>`) |
| indent-blankline | Indent guides | auto |
| zen-mode.nvim | Distraction-free editing | `<leader>zz`, `<leader>zZ` |
| toggleterm.nvim | Terminal management | auto |
| trouble.nvim | Diagnostics list | `<leader>xx` |
| todo-comments.nvim | Highlight TODO/FIXME/etc | auto |
| undotree | Undo history visualizer | auto |
| nvim-ufo | Modern code folding | auto |
| mini.nvim | Assorted mini plugins | auto |

### Language-Specific
| Plugin | Purpose |
|--------|---------|
| rust.vim | Rust filetype support |
| rustaceanvim | Enhanced Rust tooling |
| clangd_extensions.nvim | C/C++ clangd enhancements |
| package-info.nvim | npm package info in package.json |
| nvim-dbee | Database explorer |
| obsidian.nvim | Obsidian vault integration |
| vim-mdx-js | MDX syntax support |
| peek.nvim | Markdown live preview |

### Colorschemes
TokyoNight, Catppuccin, Rose Pine, OneDark, Kanagawa, Gruvbuddy (via colorbuddy), Transparent

### Other
| Plugin | Purpose |
|--------|---------|
| supermaven-nvim | AI code completion |
| cord.nvim | Discord Rich Presence |
| silicon.nvim | Code screenshots |
| vim-tmux-navigator | Seamless tmux/nvim navigation |
| hacker.nvim | Hacker-style animations |
| randiverse.nvim | Random data generator |
| cellular-automaton | Make it rain animation (`<leader>mr`) |

## LSP Servers (16)

All auto-installed via Mason:

| Server | Language(s) |
|--------|-------------|
| `lua_ls` | Lua |
| `clangd` | C / C++ |
| `rust_analyzer` | Rust |
| `ts_ls` | TypeScript / JavaScript |
| `tailwindcss` | Tailwind CSS |
| `cssls` | CSS |
| `html` | HTML |
| `jsonls` | JSON |
| `yamlls` | YAML |
| `bashls` | Bash / Shell |
| `prismals` | Prisma |
| `dockerls` | Dockerfile |
| `docker_compose_language_service` | Docker Compose |
| `mdx_analyzer` | MDX |
| `biome` | JS/TS (linting & formatting) |
| `typos_lsp` | Typo detection |

## Formatters

Configured in `plugins/conform/` with format-on-save enabled (1s timeout):

| Formatter | Filetypes |
|-----------|-----------|
| `stylua` | Lua |
| `clang-format` | C, C++ |
| `goimports` + `gofmt` | Go |
| `rustfmt` | Rust |
| `biome` | JavaScript, TypeScript, JSX, TSX, JSON |
| `prettier` | HTML, CSS, SCSS, YAML, Markdown |
| `shfmt` | Bash, Shell |
| `isort` + `black` | Python |

## Linters

Configured in `plugins/lint/`, triggered on `BufWritePost` and `InsertLeave`:

| Linter | Filetypes |
|--------|-----------|
| `eslint_d` | JavaScript, TypeScript, JSX, TSX |
| `luacheck` | Lua |
| `pylint` | Python |
| `golangcilint` | Go |
| `markdownlint` | Markdown |
| `hadolint` | Dockerfile |
| `jsonlint` | JSON |

## Treesitter Parsers (34)

Auto-installed: `bash`, `c`, `cpp`, `css`, `eex`, `elixir`, `erlang`, `go`, `gitignore`, `haskell`, `heex`, `hjson`, `html`, `javascript`, `jsdoc`, `json`, `json5`, `lua`, `ocaml`, `perl`, `php`, `prisma`, `rust`, `scala`, `scss`, `sql`, `surface`, `tsx`, `typescript`, `vim`, `vimdoc`, `yaml`, `zig`

## Keybindings Reference

Leader key: `<Space>`

### General
| Key | Mode | Action |
|-----|------|--------|
| `<Esc>` | n | Clear search highlight |
| `<C-h/j/k/l>` | n | Navigate windows |
| `<C-d>` / `<C-u>` | n | Scroll down/up (centered) |
| `n` / `N` | n | Next/prev search result (centered) |
| `J` | n | Join lines (cursor stays) |
| `J` / `K` | v | Move selected lines down/up |
| `Q` | n | Disabled (no Ex mode) |
| `<C-c>` | i | Escape |

### Leader Keymaps
| Key | Mode | Action |
|-----|------|--------|
| `<leader>pv` | n | Toggle file tree |
| `<leader>l` | n | Focus file tree |
| `<leader>sf` | n | Search files |
| `<leader>sg` | n | Search by grep (live) |
| `<leader>gf` | n | Search git files |
| `<leader>sh` | n | Search help tags |
| `<leader>sk` | n | Search keymaps |
| `<leader>sw` | n | Search current word |
| `<leader>sd` | n | Search diagnostics |
| `<leader>sr` | n | Resume last search |
| `<leader>s.` | n | Search recent files |
| `<leader>sa` | n | Search AST (ast_grep) |
| `<leader>sj` | n | Search jump (dumb_jump) |
| `<leader>/` | n | Fuzzy search current buffer |
| `<leader>s/` | n | Grep in open files |
| `<leader><leader>` | n | Find existing buffers |
| `<leader>gs` | n | Git status (Fugitive) |
| `<leader>a` | n | Add file to Harpoon |
| `<C-e>` | n | Toggle Harpoon menu |
| `<C-t/u/n/s>` | n | Jump to Harpoon mark 1/2/3/4 |
| `<leader>f` | n | Format buffer (conform) |
| `<leader>s` | n | Find & replace current word |
| `<leader>x` | n | Make file executable |
| `<leader>p` | x | Paste without overwriting register |
| `<leader>y` | n,v | Yank to system clipboard |
| `<leader>Y` | n | Yank line to system clipboard |
| `<leader>d` | n,v | Delete without register |
| `<leader>vpp` | n | Open dotfiles directory |
| `<leader>mr` | n | Cellular automaton rain |
| `<leader>zz` | n | Zen mode (105 width) |
| `<leader>zZ` | n | Zen mode (80 width, no numbers) |

### LSP (available when LSP attaches)
| Key | Mode | Action |
|-----|------|--------|
| `gd` | n | Go to definition |
| `gD` | n | Go to declaration |
| `gr` | n | Go to references |
| `gI` | n | Go to implementation |
| `K` | n | Hover documentation |
| `<leader>ca` | n | Code action |
| `<leader>rn` | n | Rename symbol |
| `<leader>ds` | n | Document symbols |
| `<leader>ws` | n | Workspace symbols |
| `<leader>D` | n | Type definition |
| `<leader>th` | n | Toggle inlay hints |

### Git (Gitsigns)
| Key | Mode | Action |
|-----|------|--------|
| `]c` / `[c` | n | Next/prev hunk |
| `<leader>hs` | n,v | Stage hunk |
| `<leader>hr` | n,v | Reset hunk |
| `<leader>hS` | n | Stage buffer |
| `<leader>hu` | n | Undo stage hunk |
| `<leader>hR` | n | Reset buffer |
| `<leader>hp` | n | Preview hunk |
| `<leader>hb` | n | Blame line |
| `<leader>hd` | n | Diff this |
| `<leader>hD` | n | Diff this (~) |
| `<leader>tb` | n | Toggle line blame |
| `<leader>td` | n | Toggle deleted |

### Fugitive (in fugitive buffer)
| Key | Mode | Action |
|-----|------|--------|
| `<leader>p` | n | Git push |
| `<leader>P` | n | Git pull |
| `<leader>Pr` | n | Git pull --rebase |
| `<leader>Pn` | n | Git pull --no-rebase |
| `<leader>t` | n | Git push -u origin ... |

### Trouble
| Key | Mode | Action |
|-----|------|--------|
| `<leader>xx` | n | Toggle diagnostics |
| `<leader>xX` | n | Toggle buffer diagnostics |
| `<leader>cs` | n | Toggle symbols |
| `<leader>cl` | n | Toggle LSP definitions/references |
| `<leader>xL` | n | Toggle location list |
| `<leader>xQ` | n | Toggle quickfix list |

### Treesitter Text Objects
| Key | Mode | Action |
|-----|------|--------|
| `af` / `if` | o,v | Around/inside function |
| `ac` / `ic` | o,v | Around/inside class |
| `aa` / `ia` | o,v | Around/inside parameter |
| `]m` / `[m` | n | Next/prev function start |
| `]]` / `[[` | n | Next/prev class start |
| `<leader>s` | n | Swap next parameter |
| `<leader>S` | n | Swap previous parameter |
| `<c-space>` | n,v | Incremental selection |
| `<M-space>` | n,v | Shrink selection |

### Tabs
| Key | Mode | Action |
|-----|------|--------|
| `<leader>tn` | n | New tab |
| `<leader>to` | n | Close other tabs |
| `<leader>tc` | n | Close tab |
| `<leader>t.` | n | Next tab |
| `<leader>t,` | n | Previous tab |

### Diagnostics & Quickfix
| Key | Mode | Action |
|-----|------|--------|
| `[d` / `]d` | n | Prev/next diagnostic |
| `<leader>e` | n | Show diagnostic float |
| `<leader>q` | n | Open diagnostic quickfix |
| `]q` / `[q` | n | Next/prev quickfix item |
| `]l` / `[l` | n | Next/prev location list item |

## Vim Options

Key settings configured in `wild-duck/set.lua`:

- **Indentation**: 2-space tabs, smart indent, expand tabs
- **Line numbers**: Relative + absolute
- **Search**: Case-insensitive (smart-case), incremental, highlight
- **Undo**: Persistent undo history (`~/.config/nvim/.undo`)
- **UI**: Color column at 100, cursor line, sign column always visible, true color
- **Splits**: Open right and below
- **Clipboard**: System clipboard integration
- **Whitespace**: Visible EOL markers
- **Scrolling**: 10-line scroll offset
- **Timing**: 250ms update time, 300ms timeout
- **Wrapping**: Enabled with line break at word boundaries
- **Swap/Backup**: Disabled (rely on undo history)

## External Dependencies

### System Packages (Arch Linux)

```bash
# Core
neovim git base-devel stow

# Language runtimes
nodejs npm python python-pip go rust cargo deno

# Formatters
stylua prettier shfmt
python-black python-isort

# Linters
luacheck eslint_d hadolint

# Tools
ripgrep fd silicon tmux xclip unzip curl wget
```

### npm Global Packages

```bash
npm i -g markdownlint-cli jsonlint @biomejs/biome
```

### Go Tools

```bash
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

### Installed by Mason (automatic)

All 16 LSP servers are auto-installed by Mason on first launch. No manual action needed.

## Customization

- **Add a new plugin**: Create `lua/plugins/{name}/init.lua` (lazy spec) and `configs.lua` (setup logic)
- **Add an LSP server**: Add to `M.servers` in `plugins/lsp/configs.lua`
- **Add a formatter**: Add to `formatters_by_ft` in `plugins/conform/configs.lua`, optionally add a config file in `plugins/conform/formatters/`
- **Add a linter**: Add to `M.linters_by_ft` in `plugins/lint/configs.lua`
- **Add treesitter parser**: Add to `M.ensure_installed` in `plugins/treesitter/configs.lua`
- **Change colorscheme**: Edit `plugins/colorschemes/configs.lua`
- **Custom snippets**: Add files in `plugins/cmp/snippets/`

## Resources

- [Learn Lua in Y Minutes](https://learnxinyminutes.com/lua/)
- [Neovim LSP Client Guide](https://vonheikemen.github.io/devlog/tools/neovim-lsp-client-guide/)
- [Neovim LSP Docs](https://neovim.io/doc/user/lsp.html)
- [LSP 3.17 Specification](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/)
- [lazy.nvim Documentation](https://lazy.folke.io/)
