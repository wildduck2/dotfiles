# Network Configuration

Firewall and SSH settings so the Linux box and the Mac can reach each other's dev servers on the home LAN.

## Quick Start

```bash
cd ~/dotfiles
./net/setup.sh
```

## What You Get

- **firewalld**: `192.168.1.0/24` goes to the `trusted` zone (all ports open to the LAN). Anything else hits the `public` zone, which only allows ssh.
- **sshd** enabled, so the Mac can `ssh` in.
- **`~/.ssh/config`** with keepalives, agent loading and a `mac` host (`ssh mac`).

Change `LAN_SUBNET` in `setup.sh` if the router hands out a different range.

## Clipboard over SSH

Copying inside tmux or nvim on a remote machine lands in the local clipboard through OSC 52:

- tmux on **both** machines needs `set -g set-clipboard on` (already in this repo's `tmux.conf`).
- The local terminal must support OSC 52: kitty does. Terminator (VTE) does not, so inside local tmux `clipboard-sync.sh` copies every new tmux buffer to the clipboard instead (Terminator without tmux still cannot receive remote copies). On the Mac, use kitty, Ghostty or iTerm2 (enable "Applications in terminal may access clipboard"); Terminal.app does not support it.

## Reaching dev servers

Servers must listen on `0.0.0.0`, not `localhost`:

| Tool | Flag |
|------|------|
| Vite | `vite --host` |
| Next.js | `next dev -H 0.0.0.0` |
| drizzle-kit | `drizzle-kit studio --host 0.0.0.0` |

Then open `http://192.168.1.6:<port>` (Linux) or `http://wildducks-MacBook-Air.local:<port>` (Mac).

## kitty over SSH

A host that lacks kitty's `xterm-kitty` terminfo redraws every keystroke twice. Copy it over once per host:

```bash
infocmp -a xterm-kitty | ssh <host> 'mkdir -p ~/.terminfo && tic -x -o ~/.terminfo /dev/stdin'
```

## Images and text to the Mac clipboard

Terminal paste over ssh is text only, so an image has to land in the Mac's own clipboard for a Mac app
(Claude Code, for one) to paste it. In kitty, `Ctrl+V` in a window running ssh does that by itself: an
image on this machine's clipboard is copied into the remote clipboard (`clip-to-mac.sh --image-only`,
once per image), then Ctrl+V goes through as usual. Text and every other window paste as before.
The ssh connection to the Mac is reused (`ControlMaster` in `.ssh/config`), so this takes a fraction
of a second after the first time.

Run `~/.config/net/clip-to-mac.sh` by hand to send the clipboard, image or text, to `CLIP_TO_MAC_HOST`
(default `mac`).

## Images and text from the Mac clipboard

The other way runs by itself: whatever is copied on the Mac (Cmd+C in any app, a screenshot to the
clipboard, a copy in its terminal) lands on this machine's clipboard a moment later. The
`clip-from-mac` user service runs `clip-from-mac.sh`, which sends `mac-clipboard-watch.js` to the Mac over
ssh and sets this clipboard from each change it reports, so nothing is installed on the Mac. It starts
again on its own when the Mac sleeps or leaves the network, and skips what `clip-to-mac.sh` has just sent
so a copy never bounces back. `systemctl --user status clip-from-mac` shows whether it is connected.
