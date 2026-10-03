# Emacs (Doom)

[Doom Emacs](https://github.com/doomemacs/doomemacs) configured as a full IDE: LSP, completion, git, project management, and a terminal, themed with [Tokyo Night](https://emacsthemes.com/themes/doom-tokyo-night). Runs TUI-only, like `nvim` -- no GUI frame.

## Requirements

- **Arch Linux** (pacman)
- **GNU Stow**
- A [Nerd Font](https://www.nerdfonts.com/) -- Berkeley Mono Trial (if present in `dotfiles/fonts/`) or JetBrainsMono Nerd Font, same fallback as `kitty`/`terminator`

## Install

```bash
./setup.sh emacs
```

This is an **opt-in module** -- not part of the default `./setup.sh` full install. Run it explicitly if you want Doom Emacs alongside (or instead of) `nvim`.

What it does:

1. Installs `emacs`, `ripgrep`, `fd`
2. Clones the Doom framework to `~/.config/emacs` (cloned like `.oh-my-zsh`, not stowed -- it's upstream code)
3. Stows this module's `.config/doom/` (your actual config) into `~/.config/doom`
4. Installs language servers: `rust-analyzer`, `clangd` (via `clang`), `elixir-ls` (AUR), `typescript-language-server` + `vscode-langservers-extracted` (npm)
5. Runs `doom sync` to install every package declared in `init.el`
6. Enables `emacs.service` (systemd `--user`) so `emacsclient -t` attaches instantly instead of cold-starting Emacs

## Directory Structure

```
emacs/.config/doom/
├── init.el       # Which Doom modules are enabled (completion, lang, tools, ui...)
├── config.el     # One-line stub: tangles + loads config.org on every startup
├── config.org    # The real config, literate style -- theme, font, personal settings
└── packages.el   # Extra packages not covered by a Doom module (empty by default)
```

`config.org` is the file to edit. It's org-mode with `emacs-lisp` source blocks
under headers (Theme, Editor, LSP, Org); `config.el` just calls
`org-babel-load-file` on it at startup, so there's no separate tangle step to
remember -- edit `config.org`, then `SPC h r r` (`doom/reload`) or restart Emacs.

## Language Coverage

TypeScript/JavaScript, HTML/CSS, JSON, Rust, C/C++, Elixir, shell, Markdown, Org, YAML -- each with LSP (`lsp-mode`) and Tree-sitter.

## Theme

- `doom-tokyo-night` (bundled in `doom-themes`, no separate package). Renders correctly in the terminal because kitty is true-color-capable -- no GUI frame needed for accurate colors.
- No `doom-font`/`doom-big-font` config -- those only affect GUI frames. In a TUI frame, font is whatever kitty is configured with (JetBrainsMono Nerd Font Bold Italic, per the `kitty` module).
- `treemacs` (file tree) uses the `doom-colors` icon theme; icons render via kitty's own Nerd Font glyphs.
- `ligatures` module is intentionally not enabled -- ligature substitution is GUI-only; kitty handles its own ligatures independently if you ever want them.

## Launching

```bash
emacs   # aliased in zsh/.zshrc to `emacsclient -t -a ""`
```

Opens a text-mode Doom Emacs frame right in the current terminal, attached to the `emacs.service` daemon (instant, no cold start). The `-a ""` auto-starts the daemon if it isn't running yet. `Ctrl-x Ctrl-c` detaches without killing the daemon.

Doom CLI: `~/.config/emacs/bin/doom doctor` / `sync` / `upgrade`

## Key Bindings Quick Reference

Leader is `SPC` (matches nvim's `<leader>` = Space), same evil/vim-motion muscle memory as the `nvim` module.

| Key | Action |
|-----|--------|
| `SPC SPC` | Find file |
| `SPC .` | Find file in project |
| `SPC ,` | Switch buffer |
| `SPC f f` | Find file |
| `SPC p p` | Switch project |
| `SPC g g` | Magit status |
| `SPC c a` | LSP code action |
| `SPC c d` | LSP jump to definition |
| `SPC c f` | Format buffer |
| `SPC o t` | Toggle terminal (vterm) |
| `SPC o p` | Toggle treemacs |

Full reference: `SPC h b b` (describe bindings) inside Emacs.

## Known Preference Carried Over From `nvim`

`lsp-lens-enable` is set to `nil` in `config.org` -- inline codelens (reference/definition counts above functions) was removed from the `nvim` module for being more clutter than signal, same call here.
