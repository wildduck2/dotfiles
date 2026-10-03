# Yazi Configuration

[Yazi](https://github.com/sxyazi/yazi) file manager with Tokyo Night, rounded borders, git markers, folder sizes on every row and rich previews.

## Quick Start

```bash
cd ~/dotfiles
./yazi/setup.sh
```

Then run `y` in zsh. Quitting with `q` leaves the shell in the folder you were in (`Q` quits without changing directory).

## What You Get

- **Rows** show size and modified date. Folder sizes are counted in the background by the local `dir-size` plugin.
- **Status bar** shows owner, group and permissions of the hovered item.
- **Previews** for code, images, SVG, PDF, video thumbnails, JSON and archive contents (real images in kitty; drawn as text with chafa in Terminator).
- **Git markers** next to changed, untracked and ignored files; ignored names are dimmed like in nvim.
- **Delete** moves to the trash (`d`); `D` deletes permanently.

## Keybindings

### Custom
| Key | Action |
|-----|--------|
| `l` | Enter folder or open file in nvim |
| `p` | Paste into the hovered folder (or the current one) |
| `T` | Maximize or restore the preview pane |
| `c m` | chmod selected files |
| `C` | Compress selected files to zip (type another extension to change format) |
| `g .` | Go to dotfiles |
| `g w` | Go to the wildduck workspace |
| `g i` | Go to iryss |

### Built-in worth knowing
| Key | Action |
|-----|--------|
| `Tab` | Details of the hovered item: size, created, modified, mimetype |
| `z` / `Z` | Jump with zoxide / fzf |
| `s` / `S` | Search by name (fd) / content (ripgrep) |
| `m s/b/m/p/o/n` | Switch row info: size, created, modified, permissions, owner, none |
| `,` + key | Sort (`, s` size, `, m` modified, `, n` natural) |
| `.` | Toggle hidden files |
| `Space` / `v` | Select / visual mode |
| `y` `x` `d` `D` | Copy, cut, trash, delete permanently |
| `r` | Rename (bulk rename in nvim when several are selected) |
| `c c` / `c f` | Copy path / filename |
| `t` | New tab |
| `~` or `F1` | Help |

## Plugins

Pinned in `package.toml` and restored by `ya pkg install`; only the local ones are tracked in git.

| Plugin | Purpose |
|--------|---------|
| [full-border](https://github.com/yazi-rs/plugins/tree/main/full-border.yazi) | Rounded border around all panes |
| [git](https://github.com/yazi-rs/plugins/tree/main/git.yazi) | Git status markers |
| [smart-enter](https://github.com/yazi-rs/plugins/tree/main/smart-enter.yazi) | `l` enters or opens |
| [smart-paste](https://github.com/yazi-rs/plugins/tree/main/smart-paste.yazi) | Paste into hovered folder |
| [chmod](https://github.com/yazi-rs/plugins/tree/main/chmod.yazi) | Change permissions |
| [toggle-pane](https://github.com/yazi-rs/plugins/tree/main/toggle-pane.yazi) | Maximize preview |
| [ouch](https://github.com/ndtoan96/ouch.yazi) | Archive preview and compression |
| [tokyo-night](https://github.com/BennyOe/tokyo-night.yazi) | Flavor (theme) |
| `dir-size` (local) | Folder sizes on every row |
| `chafa-preview` (local) | Image and video previews outside kitty |

Created dates depend on the filesystem: NTFS drives mounted through fuse (like `/run/media/...`) don't report them.
