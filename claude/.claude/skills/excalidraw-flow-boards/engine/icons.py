"""Lucide icons drawn as native Excalidraw shapes, so a tile needs no image support in the canvas.
The icons are vendored in icons/lucide from lucide-static 1.53.0 (ISC, see its LICENSE), drawn on a 24 grid."""
import math
import re
from pathlib import Path

DIR = Path(__file__).resolve().parent / "icons" / "lucide"
NUM = re.compile(r"-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?")
TAG = re.compile(r"<(path|circle|ellipse|rect|line|polyline|polygon)\b([^>]*?)/?>")
ATTR = re.compile(r'([\w-]+)="([^"]*)"')


class Scan:
    def __init__(self, d):
        self.d, self.i = d, 0

    def ws(self):
        while self.i < len(self.d) and self.d[self.i] in " ,\t\r\n":
            self.i += 1

    def done(self):
        self.ws()
        return self.i >= len(self.d)

    def cmd(self):
        self.ws()
        if self.d[self.i].isalpha():
            self.i += 1
            return self.d[self.i - 1]
        return None

    def num(self):
        self.ws()
        m = NUM.match(self.d, self.i)
        self.i = m.end()
        return float(m.group())

    def flag(self):
        # arc flags may be written run together, as in `a2 2 0 012-2`
        self.ws()
        self.i += 1
        return self.d[self.i - 1] == "1"


def cubic(p0, p1, p2, p3):
    n = min(24, max(4, int((math.dist(p0, p1) + math.dist(p1, p2) + math.dist(p2, p3)) / 1.2)))
    out = []
    for k in range(1, n + 1):
        t = k / n
        u = 1 - t
        out.append((u ** 3 * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t ** 3 * p3[0],
                    u ** 3 * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t ** 3 * p3[1]))
    return out


def quad(p0, p1, p2):
    return cubic(p0, (p0[0] + 2 / 3 * (p1[0] - p0[0]), p0[1] + 2 / 3 * (p1[1] - p0[1])),
                 (p2[0] + 2 / 3 * (p1[0] - p2[0]), p2[1] + 2 / 3 * (p1[1] - p2[1])), p2)


def arc(x1, y1, rx, ry, rot, large, sweep, x2, y2):
    """SVG's endpoint arc, sampled through its centre form."""
    if not rx or not ry:
        return [(x2, y2)]
    phi = math.radians(rot)
    c, s = math.cos(phi), math.sin(phi)
    dx, dy = (x1 - x2) / 2, (y1 - y2) / 2
    xp, yp = c * dx + s * dy, -s * dx + c * dy
    rx, ry = abs(rx), abs(ry)
    lam = xp * xp / (rx * rx) + yp * yp / (ry * ry)
    if lam > 1:
        rx, ry = rx * math.sqrt(lam), ry * math.sqrt(lam)
    den = rx * rx * yp * yp + ry * ry * xp * xp
    co = math.sqrt(max(0.0, (rx * rx * ry * ry - den) / den)) if den else 0.0
    if large == sweep:
        co = -co
    cxp, cyp = co * rx * yp / ry, -co * ry * xp / rx
    cx, cy = c * cxp - s * cyp + (x1 + x2) / 2, s * cxp + c * cyp + (y1 + y2) / 2

    def ang(ux, uy, vx, vy):
        return math.atan2(ux * vy - uy * vx, ux * vx + uy * vy)

    t1 = ang(1, 0, (xp - cxp) / rx, (yp - cyp) / ry)
    dt = ang((xp - cxp) / rx, (yp - cyp) / ry, (-xp - cxp) / rx, (-yp - cyp) / ry)
    if not sweep and dt > 0:
        dt -= 2 * math.pi
    elif sweep and dt < 0:
        dt += 2 * math.pi
    n = max(2, math.ceil(abs(dt) / (math.pi / 12)))
    return [(cx + rx * math.cos(t1 + dt * k / n) * c - ry * math.sin(t1 + dt * k / n) * s,
             cy + rx * math.cos(t1 + dt * k / n) * s + ry * math.sin(t1 + dt * k / n) * c) for k in range(1, n + 1)]


def path(d):
    s = Scan(d)
    polys, cur, c = [], None, None
    x = y = sx = sy = 0.0
    last_c = last_q = None
    while not s.done():
        c = s.cmd() or c
        if c is None:
            break
        ox, oy = (x, y) if c.islower() else (0.0, 0.0)
        k = c.upper()
        if k == "Z":
            if cur:
                cur.append((sx, sy))
            x, y, cur, c, last_c, last_q = sx, sy, None, None, None, None
            continue
        if k == "M":
            x, y = s.num() + ox, s.num() + oy
            sx, sy = x, y
            cur = [(x, y)]
            polys.append(cur)
            c = "l" if c.islower() else "L"
            last_c = last_q = None
            continue
        if cur is None:
            cur = [(x, y)]
            polys.append(cur)
        if k == "L":
            x, y = s.num() + ox, s.num() + oy
            cur.append((x, y))
        elif k == "H":
            x = s.num() + ox
            cur.append((x, y))
        elif k == "V":
            y = s.num() + oy
            cur.append((x, y))
        elif k in "CS":
            p1 = (s.num() + ox, s.num() + oy) if k == "C" else ((2 * x - last_c[0], 2 * y - last_c[1]) if last_c else (x, y))
            p2 = (s.num() + ox, s.num() + oy)
            p3 = (s.num() + ox, s.num() + oy)
            cur += cubic((x, y), p1, p2, p3)
            x, y = p3
            last_c, last_q = p2, None
            continue
        elif k in "QT":
            p1 = (s.num() + ox, s.num() + oy) if k == "Q" else ((2 * x - last_q[0], 2 * y - last_q[1]) if last_q else (x, y))
            p2 = (s.num() + ox, s.num() + oy)
            cur += quad((x, y), p1, p2)
            x, y = p2
            last_c, last_q = None, p1
            continue
        elif k == "A":
            rx, ry, rot = s.num(), s.num(), s.num()
            large, sweep = s.flag(), s.flag()
            ex, ey = s.num() + ox, s.num() + oy
            cur += arc(x, y, rx, ry, rot, large, sweep, ex, ey)
            x, y = ex, ey
        last_c = last_q = None
    return polys


def parts(name):
    """The icon as ("poly", points) and ("ellipse" | "rect", x, y, w, h, radius) on its 24 grid."""
    out = []
    for tag, attrs in TAG.findall((DIR / f"{name}.svg").read_text()):
        a = {k: v for k, v in ATTR.findall(attrs)}
        f = {k: float(v) for k, v in a.items() if NUM.fullmatch(v)}
        if tag == "path":
            out += [("poly", p) for p in path(a["d"]) if len(p) > 1]
        elif tag == "circle":
            out.append(("ellipse", f["cx"] - f["r"], f["cy"] - f["r"], 2 * f["r"], 2 * f["r"], 0))
        elif tag == "ellipse":
            out.append(("ellipse", f["cx"] - f["rx"], f["cy"] - f["ry"], 2 * f["rx"], 2 * f["ry"], 0))
        elif tag == "rect":
            out.append(("rect", f.get("x", 0), f.get("y", 0), f["width"], f["height"], f.get("rx", f.get("ry", 0))))
        elif tag == "line":
            out.append(("poly", [(f["x1"], f["y1"]), (f["x2"], f["y2"])]))
        else:
            v = [float(n) for n in NUM.findall(a["points"])]
            pts = list(zip(v[0::2], v[1::2]))
            out.append(("poly", pts + pts[:1] if tag == "polygon" else pts))
    return out


def glyph(name, cx, cy, size, color, width, idp):
    """Elements drawing icon `name` centred on (cx, cy), `size` across, ids `idp`0, `idp`1 and on."""
    k = size / 24
    x0, y0 = cx - size / 2, cy - size / 2
    els = []
    for n, p in enumerate(parts(name)):
        base = {"id": f"{idp}{n}", "strokeColor": color, "backgroundColor": "transparent", "strokeWidth": width,
                "roughness": 0}
        if p[0] == "poly" and sum(math.dist(a, b) for a, b in zip(p[1], p[1][1:])) < 0.5:
            # a dot, `h.01` in the source, which a zero-length line would not draw
            (px, py), d = p[1][0], width * 1.1
            base.update({"type": "ellipse", "x": round(x0 + px * k - d / 2, 2), "y": round(y0 + py * k - d / 2, 2),
                         "width": round(d, 2), "height": round(d, 2), "backgroundColor": color, "fillStyle": "solid"})
        elif p[0] == "poly":
            pts = [(x0 + px * k, y0 + py * k) for px, py in p[1]]
            ax, ay = pts[0]
            rel = [[round(px - ax, 2), round(py - ay, 2)] for px, py in pts]
            xs, ys = [q[0] for q in rel], [q[1] for q in rel]
            base.update({"type": "line", "x": round(ax, 2), "y": round(ay, 2), "points": rel,
                         "width": round(max(xs) - min(xs), 2), "height": round(max(ys) - min(ys), 2),
                         "roundness": None, "startArrowhead": None, "endArrowhead": None})
        else:
            kind, x, y, w, h, r = p
            base.update({"type": kind if kind == "ellipse" else "rectangle", "x": round(x0 + x * k, 2),
                         "y": round(y0 + y * k, 2), "width": round(w * k, 2), "height": round(h * k, 2)})
            if kind == "rect":
                base["roundness"] = {"type": 3, "value": round(r * k, 2)} if r else None
        els.append(base)
    return els
