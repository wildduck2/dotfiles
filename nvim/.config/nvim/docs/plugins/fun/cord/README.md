# cord

`vyfor/cord.nvim` -- Discord Rich Presence for Neovim. Lazy-loaded on `VeryLazy`.

## Files

- `init.lua` -- spec; `opts` returns the table from `config.lua`.
- `config.lua` -- the full opts table.

## External setup

The Discord client must be running locally. cord ships an IPC server binary
that talks to Discord; the plugin fetches the prebuilt binary on first run
(`advanced.server.update = 'fetch'`). If your network blocks that, set
`advanced.server.executable_path` to a local binary.

## Configurable knobs

The full opts tree is in `config.lua`. The interesting ones:

| Option | Value | Notes |
| --- | --- | --- |
| `log_level` | `vim.log.levels.OFF` | Silence cord's log output. |
| `editor.client` | `'neovim'` | Discord app identity. |
| `editor.tooltip` | `'The One True Text Editor'` | Hover text on the editor icon. |
| `display.theme` | `'default'` | Icon set. |
| `display.flavor` | `'dark'` | `'dark'` or `'light'`. |
| `display.view` | `'full'` | `'full'` or `'compact'`. |
| `timestamp.enabled` | `true` | Show elapsed time. |
| `timestamp.reset_on_*` | `false` | Don't reset on idle/file change/etc. |
| `idle.enabled` | `true` | Detect AFK. |
| `idle.timeout` | `300000` (5 min) | ms before going idle. |
| `idle.tooltip` | "Idle emoji" | Hover text while idle. |
| `text.viewing` / `text.editing` | functions | Format the "Viewing path/file" line. Editing includes total line count. |
| `text.<activity>` | functions returning a string | Workspace, file_browser, plugin_manager, lsp, vcs, notes, debug, test, diagnostics, games, terminal, dashboard. |
| `buttons[1]` | "View Repository" -> `opts.repo_url or 'https://github.com/wildduck'` | Single profile button. |
| `assets.<lang>` | per-language icon override | Currently `rust`, `typescript`, `lua`. |
| `extensions.persistent_timer` | save on `exit/focus_change/periodic`, every 30s | Survives nvim restarts. |
| `extensions.visibility` | blacklist mode | Add workspace names, glob, or paths to hide from Discord. |
| `advanced.server.timeout` | `300000` (5 min) | IPC timeout. |
| `advanced.discord.reconnect` | `enabled = true`, every `5000` ms | Auto-reconnect. |
| `advanced.workspace.root_markers` | `.git`, `.hg`, `.svn` | Determines workspace boundaries. |
| `advanced.workspace.limit_to_cwd` | `false` | If true, only show presence for files under cwd. |

## Keymaps / commands

None.

## References

- https://github.com/vyfor/cord.nvim
