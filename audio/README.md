# Audio Configuration

PipeWire + WirePlumber settings for Bluetooth headphones (tested with the Sony WH-CH520).

## Quick Start

```bash
cd ~/dotfiles
./audio/setup.sh
```

## What You Get

- **Music** plays over A2DP (AAC) at full quality.
- **Calls** switch the headphones to the headset profile automatically when an app opens the mic, and back to A2DP when the call ends.
- **Call codec** is mSBC (16 kHz wideband) instead of CVSD (8 kHz), so voices sound clearer.

## Notes

- The laptop's built-in mic (ROG Strix G614FR) is a digital mic on the AMD audio coprocessor. Its kernel driver only starts on models it lists, and the G614FR is missing, so `internal-mic.sh` (run by `setup.sh` on this model) rebuilds the driver with the model added, through DKMS so kernel updates keep it.
- If calls start cutting out (`corrupted SCO packet` in `journalctl -k`), set `bluez5.enable-msbc = false` in `51-bluez-calls.conf` to fall back to CVSD.
- Profiles can be switched by hand in pavucontrol's Configuration tab.
