#!/usr/bin/env python3
# Prints what each special key sends, with the scancode a hwdb remap needs (see hwdb/90-asus-keys.hwdb).
# Letters, digits and modifiers are never printed, so nothing typed meanwhile is recorded. Needs root:
#   sudo python3 key-probe.py [seconds]
import glob
import os
import select
import struct
import sys
import time

EVENT = struct.Struct('llHHi')
EV_KEY, EV_MSC, MSC_SCAN = 1, 4, 4

names = {}
for line in open('/usr/include/linux/input-event-codes.h'):
    parts = line.split()
    if len(parts) >= 3 and parts[0] == '#define' and parts[1].startswith('KEY_'):
        try:
            names.setdefault(int(parts[2], 0), parts[1])
        except ValueError:
            pass


def special(code):
    # F1-F12, F13-F24, and everything from KEY_MUTE up: media, brightness, vendor and launch keys.
    return code in range(59, 69) or code in (87, 88) or code >= 113


devices = {}
for path in sorted(glob.glob('/dev/input/event*')):
    with open(f'/sys/class/input/{os.path.basename(path)}/device/name') as handle:
        name = handle.read().strip()
    if os.path.exists(f'/sys/class/input/{os.path.basename(path)}/device/capabilities/key'):
        devices[os.open(path, os.O_RDONLY | os.O_NONBLOCK)] = name

seconds = int(sys.argv[1]) if len(sys.argv) > 1 else 40
print(f'Press each special key once, slowly. Listening for {seconds} seconds.', flush=True)
scans = {}
end = time.time() + seconds
while (left := end - time.time()) > 0:
    ready, _, _ = select.select(list(devices), [], [], left)
    for fd in ready:
        data = os.read(fd, EVENT.size * 64)
        for offset in range(0, len(data) - EVENT.size + 1, EVENT.size):
            _, _, kind, code, value = EVENT.unpack_from(data, offset)
            if kind == EV_MSC and code == MSC_SCAN:
                scans[fd] = value
            elif kind == EV_KEY and value == 1 and special(code):
                scan = scans.pop(fd, None)
                shown = f'{scan & 0xffffffff:x}' if scan is not None else '-'
                print(f'{devices[fd]}: {names.get(code, code)} ({code}), scancode {shown}', flush=True)
print('Done.')
