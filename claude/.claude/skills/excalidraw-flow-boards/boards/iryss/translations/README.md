# The old translation board

`frame_full`, "Translations: the full flow", was drawn by hand before the board engine existed, with bare ids
(`band_run`, `m0`). On 2026-10-14 it was ported to `b_translations.py`, key `trn`, in the same scene, and the
links on the Attributes, Categories, Products and platform boards were repointed to its `trn_band_*` lanes.
The hand-made drawing is the scene's named version `before translations port 2026-10-14`.

These scripts made the old board, in this order. None of them runs against the new one:

| Script | Did |
|---|---|
| `gen_full.py` | generated lanes 0 to 12 and printed the scene as JSON |
| `patch_links.py` | redrew the links between lanes in the margin channels |
| `patch_flagged.py` | rewrote the lanes for flagged pairs once translation review was removed |
| `reroute.py` | re-routed every arrow and re-placed its labels in place |
