#!/usr/bin/env python3
# The fan key and the keyboard light keys are handled by the firmware and never reach i3, so this shows their
# popup when the kernel reports the change.
import os
import select
import subprocess

KEYS = os.path.expanduser('~/.config/i3/keys.sh')
WATCHED = {
    '/sys/firmware/acpi/platform_profile': 'profile',
    '/sys/class/leds/asus::kbd_backlight/brightness_hw_changed': 'kbd',
}

poller = select.poll()
watching = {}
for path, action in WATCHED.items():
    try:
        handle = open(path)
    except OSError:
        continue
    # sysfs only wakes a poll for a value read at least once.
    handle.read()
    poller.register(handle, select.POLLPRI | select.POLLERR)
    watching[handle.fileno()] = (handle, action)

while watching:
    for fd, _ in poller.poll():
        handle, action = watching[fd]
        handle.seek(0)
        handle.read()
        subprocess.run([KEYS, action], check=False)
