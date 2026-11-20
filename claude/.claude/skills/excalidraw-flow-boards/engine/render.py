"""Renders a board to PNGs without a browser: the whole board, then each lane cut into pieces of at most
`span` canvas pixels wide. Usage: render.py <patch-x.json | sceneId> <key> <name> [zoom] [span]
Writes <name>.svg, <name>.png and <name>-<lane>-<n>.png to the working directory. Fonts are stand-ins:
Comic Sans MS for Excalifont, Helvetica, Menlo for Cascadia."""
import html
import json
import math
import subprocess
import sys

sys.path.insert(0, __file__.rsplit("/", 1)[0])

FONTS = {1: "Comic Sans MS", 2: "Helvetica", 3: "Menlo", 5: "Comic Sans MS", 6: "Helvetica", 8: "Menlo"}


def load(src):
    if src.endswith(".json"):
        return json.load(open(src))["create"]
    from canvas import live
    return live(src)


def dash(e):
    sw = e.get("strokeWidth", 2)
    return {"dashed": f' stroke-dasharray="8 {8 + sw}"', "dotted": f' stroke-dasharray="1.5 {6 + sw}"'}.get(
        e.get("strokeStyle"), "")


def paint(e):
    bg = e.get("backgroundColor") or "transparent"
    return (f'fill="{"none" if bg == "transparent" else bg}" stroke="{e.get("strokeColor", "#1e1e1e")}" '
            f'stroke-width="{e.get("strokeWidth", 2)}"{dash(e)}')


def shape(e):
    x, y, w, h = e["x"], e["y"], e["width"], e["height"]
    if e["type"] == "rectangle":
        m = min(w, h)
        r = (m * 0.25 if m <= 128 else 32) if e.get("roundness") else 0
        return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" {paint(e)}/>'
    if e["type"] == "diamond":
        return f'<polygon points="{x + w / 2},{y} {x + w},{y + h / 2} {x + w / 2},{y + h} {x},{y + h / 2}" {paint(e)}/>'
    if e["type"] == "ellipse":
        return f'<ellipse cx="{x + w / 2}" cy="{y + h / 2}" rx="{w / 2}" ry="{h / 2}" {paint(e)}/>'
    if e["type"] == "frame":
        return (f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="none" stroke="#adb5bd" stroke-width="2"/>'
                f'<text x="{x}" y="{y - 12}" font-family="Helvetica" font-size="20" fill="#868e96">'
                f'{html.escape(e.get("name") or "")}</text>')
    return ""


def text(e):
    size = e.get("fontSize", 20)
    lh = size * e.get("lineHeight", 1.25)
    align = e.get("textAlign", "left")
    anchor, ax = {"left": ("start", e["x"]), "center": ("middle", e["x"] + e["width"] / 2),
                  "right": ("end", e["x"] + e["width"])}[align]
    font = FONTS.get(e.get("fontFamily", 5), "Helvetica")
    return "".join(
        f'<text x="{ax}" y="{e["y"] + i * lh + lh / 2 + size * 0.35}" font-family="{font}" font-size="{size}" '
        f'fill="{e.get("strokeColor", "#1e1e1e")}" text-anchor="{anchor}" xml:space="preserve">'
        f'{html.escape(line)}</text>' for i, line in enumerate(e["text"].split("\n")))


def arrow(e):
    pts = [(e["x"] + p[0], e["y"] + p[1]) for p in e["points"]]
    color, sw = e.get("strokeColor", "#1e1e1e"), e.get("strokeWidth", 2)
    out = (f'<polyline points="{" ".join(f"{x},{y}" for x, y in pts)}" fill="none" stroke="{color}" '
           f'stroke-width="{sw}"{dash(e)}/>')
    for head, (a, b) in ((e["endArrowhead"] if "endArrowhead" in e else "arrow", pts[-2:]),
                         (e.get("startArrowhead"), pts[1::-1])):
        if not head:
            continue
        ang, n = math.atan2(b[1] - a[1], b[0] - a[0]), min(16, math.dist(a, b) / 2)
        for d in (0.45, -0.45):
            out += (f'<line x1="{b[0]}" y1="{b[1]}" x2="{b[0] - n * math.cos(ang + d)}" '
                    f'y2="{b[1] - n * math.sin(ang + d)}" stroke="{color}" stroke-width="{sw}"/>')
    return out


def edge(e):
    if e["type"] in ("arrow", "line"):
        return e["x"] + max(p[0] for p in e["points"])
    return e["x"] + e["width"]


def svg(els, x0, y0, w, h):
    body = []
    for e in els:
        if e["type"] == "text":
            body.append(text(e))
        elif e["type"] in ("arrow", "line"):
            body.append(arrow(e))
        else:
            body.append(shape(e))
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">'
            f'<rect width="{w}" height="{h}" fill="white"/><g transform="translate({-x0},{-y0})">'
            + "".join(body) + "</g></svg>")


def main(src, key, name, zoom=0.5, span=2200):
    zoom, span = float(zoom), float(span)
    els = load(src)
    group = f"g_{key}"
    mine = {e["id"] for e in els if group in (e.get("groupIds") or [])}
    els = [e for e in els if e["id"] in mine or e.get("containerId") in mine]
    if all(isinstance(e.get("index"), str) for e in els):
        els.sort(key=lambda e: e["index"])
    frame = next(e for e in els if e["type"] == "frame")
    x0, y0 = frame["x"] - 40, frame["y"] - 60
    w, h = frame["width"] + 80, frame["height"] + 100
    open(f"{name}.svg", "w").write(svg(els, x0, y0, w, h))
    run = lambda *a: subprocess.run(["rsvg-convert", *a, "-b", "white", f"{name}.svg"], check=True)
    run("-z", str(min(0.2, 2400 / w)), "-o", f"{name}.png")
    print(f"{name}.png {w:.0f}x{h:.0f}")
    bands = sorted((e for e in els if e["id"].startswith(f"{key}_band_")), key=lambda e: e["y"])
    for b in bands:
        lane = b["id"][len(f"{key}_band_"):]
        right = min(frame["x"] + frame["width"], max(edge(e) for e in els if e["type"] != "frame"
                                                     and b["y"] <= e["y"] < b["y"] + b["height"]))
        parts = max(1, math.ceil((right - b["x"] + 20) / span))
        for i in range(parts):
            cx = b["x"] - 10 + i * (right - b["x"] + 20) / parts
            cw = (right - b["x"] + 20) / parts
            run("-z", str(zoom), f"--left={-(cx - x0) * zoom}", f"--top={-(b['y'] - 10 - y0) * zoom}",
                f"--page-width={cw * zoom}", f"--page-height={(b['height'] + 20) * zoom}",
                "-o", f"{name}-{lane}-{i + 1}.png")
        print(f"{name}-{lane}: {parts} piece(s), {right - b['x']:.0f}x{b['height']:.0f}")


main(*sys.argv[1:])
