# duck-diff

Local git diff viewer in a Chrome app window: [gentleeduck/duck-diff](https://github.com/gentleeduck/duck-diff).

## Keys

| Key | Action |
|-----|--------|
| `<leader>gv` | Local changes (working tree against HEAD) |
| `<leader>gV` | What this branch adds on top of `main` |

## Commands

`:DuckDiff [staged|unstaged|<ref>|a..b|a...b|commit [sha]|status|close]`, with completion.

## Notes

- The repo is private: lazy.nvim clones it over ssh, and the first `:DuckDiff` downloads the release binary
  with `gh auth token`.
- `:checkhealth duck-diff` shows the binary, browser and tool status.
