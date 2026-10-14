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

- The laptop's built-in mic (ROG Strix G614FR, AMD ACP digital mic) is not detected by Linux, so the headphone mic or a wired headset is the only mic.
- If calls start cutting out (`corrupted SCO packet` in `journalctl -k`), set `bluez5.enable-msbc = false` in `51-bluez-calls.conf` to fall back to CVSD.
- Profiles can be switched by hand in pavucontrol's Configuration tab.
