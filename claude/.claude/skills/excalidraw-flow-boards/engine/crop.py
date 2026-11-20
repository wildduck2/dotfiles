"""Renders the whole flow once and cuts canvas regions out of it, so a wire crossing a cut still shows.
Usage: crop.py <group> name:x0:y0:x1:y1[:zoom] ...   Writes whole.svg and <name>.png to the working directory."""
import re, subprocess, sys
sys.path.insert(0, __file__.rsplit("/", 1)[0])
from canvas import live  # noqa: E402
from snap import snap  # noqa: E402

els = live()
mine = [e for e in els if sys.argv[1] in (e.get("groupIds") or []) and e["type"] != "frame"
        and not e.get("containerId")]
xs, ys = [], []
for e in mine:
    if e["type"] in ("arrow", "line"):
        xs += [e["x"] + p[0] for p in e["points"]]
        ys += [e["y"] + p[1] for p in e["points"]]
    else:
        xs += [e["x"], e["x"] + e["width"]]
        ys += [e["y"], e["y"] + e["height"]]
svg = "whole.svg"
snap([e["id"] for e in mine], "whole.png", 0.1)
head = open(svg).read(2000)
w, h = (float(v) for v in re.search(r'width="([\d.]+)"[^>]*height="([\d.]+)"', head).groups())
px, py = (w - (max(xs) - min(xs))) / 2, (h - (max(ys) - min(ys))) / 2
for arg in sys.argv[2:]:
    name, *nums = arg.split(":")
    x0, y0, x1, y1 = map(float, nums[:4])
    z = float(nums[4]) if len(nums) > 4 else 0.6
    sx, sy = x0 - min(xs) + px, y0 - min(ys) + py
    subprocess.run(["rsvg-convert", "-z", str(z), f"--left={-sx * z}", f"--top={-sy * z}", f"--page-width={(x1 - x0) * z}",
                    f"--page-height={(y1 - y0) * z}", "-b", "white", "-o", f"{name}.png", svg], check=True)
    print(name)
