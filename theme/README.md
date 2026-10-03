# Theme - Tokyo Night (System Dark Mode)

Forces GTK3/GTK4 apps into dark mode using the `Tokyonight-Dark` theme, so
that non-WM-native dialogs (file pickers, `nm-applet`, `blueman`,
`pavucontrol`, `polkit-gnome` prompts, GTK-based utilities) match the Tokyo
Night palette already used across kitty, btop, and the cursor theme
([banana-cursor](../banana-cursor)), instead of falling back to a light
Adwaita theme.

## Requirements

- `yay` (AUR helper, installed automatically if missing)

## Setup

```bash
cd ~/dotfiles

./theme/setup.sh

# Or via the main setup
./setup.sh theme
```

## What it does

1. Installs `tokyonight-gtk-theme-git` from the AUR
2. Stows GTK3 settings (`~/.config/gtk-3.0/settings.ini`) and GTK4 settings
   (`~/.config/gtk-4.0/settings.ini`) with:
   - `gtk-application-prefer-dark-theme=1`
   - `gtk-theme-name=Tokyonight-Dark`
   - Cursor theme (`Banana-Blue`, size 24) — kept here rather than in
     `banana-cursor` since stow can't split ownership of one file
3. Applies live via `gsettings` (`color-scheme=prefer-dark`,
   `gtk-theme=Tokyonight-Dark`) for the current session

## Notes

- Run `banana-cursor/setup.sh` too if you want the cursor theme assets
  actually installed — this module only references the cursor theme name,
  it doesn't download it.
- Electron apps (Discord, yaak) and Firefox pick their own dark mode
  independently and aren't affected by this module.
