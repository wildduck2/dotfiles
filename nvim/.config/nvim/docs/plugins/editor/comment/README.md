# comment

`terrortylor/nvim-comment` plus `JoosepAlviste/nvim-ts-context-commentstring`.
Toggles line / block comments and respects the embedded language (JSX, Vue,
Svelte, etc.).

## Why we use it

`gcc` and `gc<motion>` are muscle memory. The treesitter hook keeps the
right comment marker in JSX braces, Vue templates, and so on.

## Files

- `init.lua` -- spec; loads on `BufReadPost` with the ts-context-commentstring
  dependency.
- `config.lua` -- runs `nvim_comment.setup{}`.

## Keymaps

| Key | Action |
| --- | --- |
| `gcc` | toggle current line |
| `gbc` | toggle block comment |
| `gc<motion>` | comment over a motion (e.g. `gcap`) |

These are the defaults activated by `create_mappings = true`.

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `marker_padding` | `true` | Insert space between marker and code. |
| `comment_empty` | `true` | Comment blank lines too. |
| `comment_empty_trim_whitespace` | `true` | Strip trailing space on empty comments. |
| `create_mappings` | `true` | Register keymaps above. |
| `line_mapping` | `'gcc'` | -- |
| `block_mapping` | `'gbc'` | -- |
| `operator_mapping` | `'gc'` | -- |
| `comment_chunk_text_object` | `'ic'` | Conflicts with treesitter `ic` class-inner (treesitter only kicks in inside class nodes). |
| `hook` | calls `ts_context_commentstring.internal.update_commentstring()` | Treesitter-aware commentstring per cursor position. |

## References

- nvim-comment: https://github.com/terrortylor/nvim-comment
- nvim-ts-context-commentstring: https://github.com/JoosepAlviste/nvim-ts-context-commentstring
