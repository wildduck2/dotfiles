"""Renders everything inside a canvas box, and every arrow touching it, to <name>.png in the working directory.
Usage: shotbox.py x0 y0 x1 y1 <name> [scale]"""
import sys
sys.path.insert(0, __file__.rsplit("/", 1)[0])
from canvas import live  # noqa: E402
from snap import snap  # noqa: E402

x0, y0, x1, y1 = map(float, sys.argv[1:5])
name = sys.argv[5]
scale = sys.argv[6] if len(sys.argv) > 6 else "1"
els = live()


def inside(e):
    return x0 <= e["x"] and e["x"] + e["width"] <= x1 and y0 <= e["y"] and e["y"] + e["height"] <= y1


def touches(e):
    pts = [(e["x"] + p[0], e["y"] + p[1]) for p in e["points"]]
    return any(x0 <= px <= x1 and y0 <= py <= y1 for px, py in pts)


ids = [e["id"] for e in els if e["type"] != "frame" and not e.get("containerId")
       and (touches(e) if e["type"] == "arrow" else inside(e))]
snap(ids, f"{name}.png", float(scale))
print(name, len(ids))
