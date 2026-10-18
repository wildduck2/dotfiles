# Ctrl+V pastes the newest copy, whatever it is. An image is put on the clipboard of the machine the
# window is ssh'd into (Claude Code on the Mac reads it from there) and Ctrl+V is sent to the program;
# text is pasted as kitty always pastes, so a copied image never shadows text copied after it.
import os
import subprocess

from kittens.tui.handler import result_handler

SCRIPT = os.path.expanduser('~/.config/net/clip-to-mac.sh')
# ssh options that take a value, so the destination is the first word after them.
VALUED = set('BbcDEeFIiJLlmOoPpQRSWw')


def main(args):
    pass


def ssh_destination(window):
    for process in window.child.foreground_processes:
        cmdline = process.get('cmdline') or []
        if not cmdline or os.path.basename(cmdline[0]) != 'ssh':
            continue
        words = iter(cmdline[1:])
        for word in words:
            if word == '--':
                return next(words, None)
            if word.startswith('-') and len(word) > 1:
                if word[-1] in VALUED and len(word) == 2:
                    next(words, None)
                continue
            return word
    return None


def clipboard_kind():
    try:
        out = subprocess.run([SCRIPT, '--kind'], capture_output=True, text=True, timeout=5, check=False)
        return out.stdout.strip()
    except (OSError, subprocess.SubprocessError):
        return 'text'


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    if clipboard_kind() == 'image':
        host = ssh_destination(window)
        if host:
            # Waits for the copy so the Ctrl+V below finds the image already there. A failed send has
            # already said why; Ctrl+V then would paste whatever the Mac held before.
            sent = subprocess.run([SCRIPT, '--image-only', host], timeout=20, check=False)
            if sent.returncode != 0:
                return
        # The program reads the image off its own clipboard when it sees Ctrl+V.
        window.write_to_child(b'\x16')
        return
    boss.paste_from_clipboard()
