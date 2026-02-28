- install [bat](https://github.com/sharkdp/bat)
- install [tldr](https://github.com/tldr-pages/tldr)
- install [btop](https://github.com/aristocratos/btop)
- install [neofetch](https://github.com/dylanaraps/neofetch)
- install [lazydocker](https://github.com/jesseduffield/lazydocker)
- install [lazygit](https://github.com/jesseduffield/lazygit)
- install [fzf](https://github.com/junegunn/fzf)
- install [fd](https://github.com/sharkdp/fd)
- install [ripgrep](https://github.com/BurntSushi/ripgrep)
- install [zoxide](https://github.com/ajeetdsouza/zoxide)
- install [yazi](https://github.com/ymattw/yazi)
- install [jq](https://github.com/stedolan/jq)
- install [cht.sh](https://github.com/tpope/cht.sh)
- install [onefetch](https://github.com/o2sh/onefetch)
- install [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- install [grex](https://github.com/pemistahl/grex)
- install [musikcube](https://github.com/clangen/musikcube)
- install [cowsay](https://github.com/tnalpgge/rank-amateur-cowsay)
- install [batdiff](https://github.com/so-fancy/diff-so-fancy)
- install [fzf-tmux](https://github.com/junegunn/fzf)
- install [atop](https://github.com/Atoptool/atop)
- install [dust](https://github.com/bootandy/dust)
- install [fx](https://github.com/antonmedv/fx)
- install [ripgrep-all](https://github.com/phiresky/ripgrep-all)


## To make the `s` in nvim open yazi in a new terminal
xdg-mime default terminator-folder.desktop inode/directory
xdg-mime default terminator-folder.desktop application/x-gnome-saved-search
gio mime inode/directory terminator-folder.desktop
update-desktop-database ~/.local/share/applications


[Desktop Entry]
Name=Terminator (Folder with Yazi)
Type=Application
MimeType=inode/directory;
Terminal=false
Exec=terminator -x zsh -c "cd '%f'; yazi; exec zsh"
~/.local/share/applications/terminator-folder.desktop


```
sudo pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
sudo systemctl enable lightdm

reboot
```
