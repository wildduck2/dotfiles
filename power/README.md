# power

Hibernate Linux, work in Windows for days or weeks, and come back to every window where it was.

`./setup.sh power` makes a swapfile as big as RAM (`/swapfile`, priority 10, so it is the swap systemd
hibernates into; the old partition stays as extra swap) and adds `resume=UUID=... resume_offset=...` to GRUB.
The initramfs uses the systemd hook, which reads `resume=` itself, and the NVIDIA driver already keeps video
memory across a hibernate (`NVreg_PreserveVideoMemoryAllocations=1`, nvidia-hibernate and nvidia-resume
enabled). Reboot once after running it. `Mod+Ctrl+Shift+.` hibernates.

Before this, a hibernate failed with `No space left on device` (the image is about 12 GiB and the 16.6 GiB
partition was mostly in use), and one that did write could not come back, since nothing told the kernel where
to resume from.

## Windows must not touch what Linux has open

A hibernated Linux still holds every mounted filesystem in memory, as it was. If Windows writes to one of
them meanwhile, Linux resumes over a disk that has changed under it and can wreck it. So, while Linux is
hibernated:

- **`duck` (`nvme1n1p1`, NTFS) and `New Volume` (`sda3`, exFAT) are Linux's.** Either keep Windows off them
  (Disk Management: right-click the disk, Offline, and Online again only once Linux is shut down rather than
  hibernated), or close what Linux has open on them and unmount them before hibernating.
- **Turn off Windows Fast Startup**, from an administrator prompt: `powercfg /h off`. It leaves Windows'
  own partitions half-mounted on every shutdown.
- The Windows partitions (`OS`, `RESTORE`) are never mounted in Linux, so Windows may use them freely.

## Checking it

Plug the laptop in for the first try: the one hibernate that wrote an image ran at 1% battery, and the NVIDIA
driver logged errors as it went down. Then hibernate, boot Windows and back, and read what the last boot did:

```bash
journalctl -b -1 | grep -i 'PM: hibernation'
journalctl -b | grep -i 'PM: Image'
```
