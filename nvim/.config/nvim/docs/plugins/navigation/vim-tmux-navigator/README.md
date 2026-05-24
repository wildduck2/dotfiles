# vim-tmux-navigator

`christoomey/vim-tmux-navigator` -- seamless movement between vim splits and
tmux panes. Loaded eagerly.

## Files

- `init.lua` -- spec; calls
  `require('plugins.navigation.vim-tmux-navigator.config').setup()`.
- `config.lua` -- disables default mappings and defines our Shift-based ones.

## Keymaps

`vim.g.tmux_navigator_no_mappings = 1` turns off the plugin's default
`<C-hjkl>` bindings (we already use those for window-only navigation in
`wild-duck/remap.lua`). The Shift-based versions take over for tmux-aware
movement:

| Key | Action |
| --- | --- |
| `<S-h>` | `:TmuxNavigateLeft` |
| `<S-j>` | `:TmuxNavigateDown` |
| `<S-k>` | `:TmuxNavigateUp` |
| `<S-l>` | `:TmuxNavigateRight` |
| `<S-p>` | `:TmuxNavigatePrevious` |

## External setup

Add these matching tmux bindings to your `~/.tmux.conf` so tmux forwards
movement events to vim and back:

```tmux
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
  | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'
```

(Or use the official snippet from the plugin's README.)

## References

- https://github.com/christoomey/vim-tmux-navigator
