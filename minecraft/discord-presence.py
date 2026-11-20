#!/usr/bin/env python3
# Shows "Playing Minecraft" with the game's icon on Discord while Minecraft runs. Discord cannot spot the
# game on Linux (its list only knows the Windows and Mac programs), so this tells it over Discord's local
# socket, using Discord's own Minecraft entry for the name and icon.
import json
import os
import socket
import struct
import time
import uuid
from pathlib import Path

CLIENT_ID = '1402418491272986635'
# The game's main classes: Fabric's loader, and plain Minecraft.
GAME = {b'net.fabricmc.loader.impl.launch.knot.KnotClient', b'net.minecraft.client.main.Main'}
POLL = 5
# TLauncher's own Discord status would read "TLauncher" and show before the game's.
TLAUNCHER = Path.home() / '.tlauncher/tlauncher-2.0.properties'


def game_pid():
    for entry in Path('/proc').iterdir():
        if not entry.name.isdigit():
            continue
        try:
            args = (entry / 'cmdline').read_bytes().split(b'\0')
        except OSError:
            continue
        if GAME.intersection(args):
            return int(entry.name)
    return None


def untick_tlauncher():
    # TLauncher writes its settings back when it saves or quits and reads them when it starts, so the
    # box is turned off again whenever it reappears; it takes effect from TLauncher's next start.
    try:
        text = TLAUNCHER.read_text()
    except OSError:
        return
    if 'gui.discord.checkbox=true' in text:
        TLAUNCHER.write_text(text.replace('gui.discord.checkbox=true', 'gui.discord.checkbox=false'))
        print("turned off TLauncher's Discord status for its next start", flush=True)


def started_at(pid):
    # Field 22 of /proc/<pid>/stat is when the process started, in clock ticks after boot.
    ticks = int(Path(f'/proc/{pid}/stat').read_text().rsplit(')', 1)[1].split()[19])
    boot = next(int(line.split()[1]) for line in Path('/proc/stat').read_text().splitlines() if line.startswith('btime'))
    return boot + ticks // os.sysconf('SC_CLK_TCK')


def sockets():
    runtime = Path(os.environ.get('XDG_RUNTIME_DIR', f'/run/user/{os.getuid()}'))
    # The plain install, then the Flatpak and Snap ones, which keep the socket in their own folders.
    for folder in (runtime, runtime / 'app/com.discordapp.Discord', runtime / 'snap.discord'):
        for n in range(10):
            yield folder / f'discord-ipc-{n}'


class Discord:
    def __init__(self):
        self.sock = None
        for path in sockets():
            if not path.exists():
                continue
            try:
                sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
                sock.connect(str(path))
            except OSError:
                continue
            self.sock = sock
            self.send(0, {'v': 1, 'client_id': CLIENT_ID})
            self.receive()
            return
        raise ConnectionError('Discord is not running')

    def send(self, op, payload):
        data = json.dumps(payload).encode()
        self.sock.sendall(struct.pack('<II', op, len(data)) + data)

    def read(self, size):
        data = b''
        while len(data) < size:
            chunk = self.sock.recv(size - len(data))
            if not chunk:
                raise ConnectionError('Discord closed the connection')
            data += chunk
        return data

    def receive(self):
        _, length = struct.unpack('<II', self.read(8))
        return json.loads(self.read(length))

    def activity(self, activity):
        self.send(1, {'cmd': 'SET_ACTIVITY', 'args': {'pid': os.getpid(), 'activity': activity}, 'nonce': str(uuid.uuid4())})
        self.receive()

    def close(self):
        if self.sock:
            self.sock.close()


def main():
    discord = None
    shown = None
    while True:
        untick_tlauncher()
        pid = game_pid()
        try:
            if pid and pid != shown:
                discord = discord or Discord()
                discord.activity({'timestamps': {'start': started_at(pid)}})
                shown = pid
                print(f'showing Minecraft on Discord (game pid {pid})', flush=True)
            elif not pid and discord:
                # Closing the connection takes the game off the profile.
                discord.close()
                discord, shown = None, None
                print('game closed, Minecraft taken off Discord', flush=True)
        except (OSError, ConnectionError, struct.error, ValueError) as error:
            # Discord closed or restarted; connect again on the next look.
            if shown or discord:
                print(f'lost Discord ({error}); trying again', flush=True)
            if discord:
                discord.close()
            discord, shown = None, None
        time.sleep(POLL)


if __name__ == '__main__':
    main()
