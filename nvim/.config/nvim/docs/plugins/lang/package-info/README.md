# package-info

`vuki656/package-info.nvim` -- shows latest version info as virtual text in
`package.json`, lets you update / remove / install / pick a version inline.

## Files

- `init.lua` -- spec; loads on `BufRead package.json`. Depends on `nui.nvim`.
- `config.lua` -- `package-info.setup{}` + keymaps.

## Keymaps (all start with `<leader>n`)

| Key | Action |
| --- | --- |
| `<LEADER>ns` | `package-info.show` -- fetch + display version info |
| `<LEADER>nc` | `hide` -- clear virtual text |
| `<LEADER>nt` | `toggle` |
| `<LEADER>nu` | `update` -- bump to latest |
| `<LEADER>nd` | `delete` -- remove package |
| `<LEADER>ni` | `install` -- prompt + install |
| `<LEADER>np` | `change_version` -- pick version |

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `highlights.up_to_date` | `#3C4048` | Dim grey for current. |
| `highlights.outdated` | `#d19a66` | Orange. |
| `highlights.invalid` | `#ee4b2b` | Red. |
| `icons.enable` | `true` | Show icons next to versions. |
| `icons.style.<state>` | nerd-font glyphs | Per-state icon strings. |
| `notifications` | `true` | Toasts on actions. |
| `autostart` | `false` | Don't auto-fetch on open. Use `<LEADER>ns`. |
| `hide_up_to_date` | `false` | Show all packages regardless of state. |
| `hide_unstable_versions` | `false` | Include pre-release versions in choices. |
| `package_manager` | `'pnpm'` | `'npm'`, `'yarn'`, or `'pnpm'`. |

## External setup

`pnpm` (or whichever manager you set) must be on PATH and runnable from the
project root.

## References

- https://github.com/vuki656/package-info.nvim
