# Ctrl+V in a window running ssh: an image on this machine's clipboard is put into the remote
# machine's clipboard first, so programs there (Claude Code on the Mac) paste it. Text paste over
# ssh already works, so for text, and in every other window, this is a plain Ctrl+V.
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


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    host = ssh_destination(window)
    if host:
        # Waits for the copy so the Ctrl+V below finds the image already there.
        subprocess.run([SCRIPT, '--image-only', host], timeout=20, check=False)
    window.write_to_child(b'\x16')
