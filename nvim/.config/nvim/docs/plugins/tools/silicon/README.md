# silicon

`michaelrommel/nvim-silicon` -- generate beautiful code screenshots via the
`silicon` CLI. Lazy on `:Silicon`.

## Files

- `init.lua` -- spec only, no custom config.

## Why we use it

For screenshots of code blocks (issues, slide decks). Visual selection +
`:Silicon` saves a PNG of the highlighted region.

## Commands

- `:Silicon` -- render the current selection (or whole buffer) to an image.

## External setup

- `silicon` CLI must be installed: https://github.com/Aloxaf/silicon. On Arch:
  `pacman -S silicon`.

## Configurable knobs

We use defaults. To override (output path, theme, font), pass `opts` in
`init.lua`. Common ones:

- `output` -- output path template, e.g. `'~/Pictures/silicon-{time}.png'`.
- `theme` -- `'TwoDark'`, `'Dracula'`, etc.
- `font` -- e.g. `'JetBrainsMono Nerd Font=16'`.
- `tab_width`, `line_pad`, `pad_horiz`, `pad_vert` -- spacing.
- `background` -- hex color.

## References

- https://github.com/michaelrommel/nvim-silicon
- silicon: https://github.com/Aloxaf/silicon
