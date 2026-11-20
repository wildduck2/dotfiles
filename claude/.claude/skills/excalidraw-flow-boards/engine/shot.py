"""Renders a board, or some of its lanes, to <name>.png in the working directory.
Usage: shot.py <key> <lane,lane|all> <name> [scale]"""
import sys
sys.path.insert(0, __file__.rsplit("/", 1)[0])
from canvas import live  # noqa: E402
from snap import snap  # noqa: E402

key, lane, name = sys.argv[1], sys.argv[2], sys.argv[3]
scale = sys.argv[4] if len(sys.argv) > 4 else "1"
els = live()
mine = [e for e in els if e["id"].startswith(key + "_") and e.get("type") != "frame" and not e.get("containerId")]
if lane != "all":
    lanes = lane.split(",")
    bands = [e for e in mine if e["id"] in [f"{key}_band_{l}" for l in lanes]]
    y0 = min(b["y"] for b in bands) - 5
    y1 = max(b["y"] + b["height"] for b in bands) + 5
    mine = [e for e in mine if y0 <= e["y"] <= y1]
ids = [e["id"] for e in mine]
snap(ids, f"{name}.png", float(scale))
print(name, len(ids))
