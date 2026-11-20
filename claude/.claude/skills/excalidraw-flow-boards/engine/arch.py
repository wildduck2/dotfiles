"""System-design boards: cards carrying an icon, a name, a line of detail and a status, inside zones, joined by
routed and labelled links. A board file's make() returns an Arch, which build.py places and applies like a flow
Board. Every position is the board file's; this draws, routes and checks."""
import sys

from icons import glyph
from lib import INK, arrow_el, fixed_points, link, text_el, text_w
from route import Router

W, H = 272, 76
BADGE = 44
SUB = "#5c636a"
MUTED = "#868e96"
STATUS = {"built": "#2f9e44", "progress": "#f08c00", "planned": "#adb5bd"}
NAMES = {"built": "built", "progress": "in progress", "planned": "planned"}
LINE = {"built": "#343a40", "planned": "#909296"}


def tint(color, k):
    """`color` taken k of the way to white."""
    c = [int(color[i:i + 2], 16) for i in (1, 3, 5)]
    return "#" + "".join(f"{round(v + (255 - v) * k):02x}" for v in c)


def rect(id, x, y, w, h, fill, stroke, width=1.5, dashed=False, radius=14):
    el = {"id": id, "type": "rectangle", "x": round(x), "y": round(y), "width": round(w), "height": round(h),
          "backgroundColor": fill, "fillStyle": "solid", "strokeColor": stroke, "strokeWidth": width, "roughness": 0,
          "roundness": {"type": 3, "value": radius} if radius else None}
    if dashed:
        el["strokeStyle"] = "dashed"
    return el


def dot(id, cx, cy, d, color):
    return {"id": id, "type": "ellipse", "x": round(cx - d / 2, 1), "y": round(cy - d / 2, 1), "width": d, "height": d,
            "backgroundColor": color, "fillStyle": "solid", "strokeColor": color, "strokeWidth": 1, "roughness": 0}


class Arch:
    def __init__(self, key, name):
        self.key, self.name = key, name
        self.remote = []
        self.items, self.wires, self.links = {}, [], {}
        self.title = self.subtitle = ""

    def id(self, local):
        return f"{self.key}_{local}"

    def head(self, title, sub):
        self.title, self.subtitle = title, sub

    def card(self, id, x, y, icon, color, title, sub=None, status="built", to=None, w=W):
        """A card at (x, y). `status` None is an actor rather than a part, so it carries no dot."""
        lines = sub.count("\n") + 1 if sub else 0
        h = H + max(0, lines - 1) * 16
        self.items[id] = {"kind": "card", "icon": icon, "color": color, "title": title, "sub": sub, "status": status,
                          "box": (x, y, x + w, y + h)}
        if to:
            self.links[self.id(id)] = to
        return self.items[id]["box"]

    def zone(self, id, title, icon, color, members, fill=None, dashed=False, pad=(28, 68, 28, 28), box=None, to=None):
        """A container around `members`, or at `box`. Declared after its members, it draws beneath them."""
        if box is None:
            boxes = [self.items[m]["box"] for m in members]
            box = (min(b[0] for b in boxes) - pad[0], min(b[1] for b in boxes) - pad[1],
                   max(b[2] for b in boxes) + pad[2], max(b[3] for b in boxes) + pad[3])
        self.items[id] = {"kind": "zone", "title": title, "icon": icon, "color": color,
                          "fill": tint(color, 0.94) if fill is None else fill, "dashed": dashed, "box": box}
        if to:
            self.links[self.id(f"band_{id}")] = to
        return box

    def panel(self, id, x, y, title, lines, color, w):
        """A boxed list of short statements."""
        h = 68 + 26 * len(lines) + 14
        self.items[id] = {"kind": "panel", "title": title, "lines": lines, "color": color, "box": (x, y, x + w, y + h)}
        return self.items[id]["box"]

    def link(self, a, b, label=None, status="built", sides=(None, None), both=False, merge=False, at=None, bus=False):
        """merge=True lets links that share an end run as one trunk; by default each link keeps its own path.
        at="end" or "start" keeps a branch's label off the trunk it shares. bus=True skips the straight shortcut, so
        a fan of links shares one trunk instead of crossing."""
        self.wires.append((a, b, label, status, sides, both, merge, at, bus))

    def ref(self, local):
        return self.id(f"band_{local}" if self.items[local]["kind"] == "zone" else local)

    def box(self, k):
        return self.items[k]["box"]

    def counts(self):
        out = {s: 0 for s in STATUS}
        for t in self.items.values():
            if t["kind"] == "card" and t["status"]:
                out[t["status"]] += 1
        return out

    def layout(self):
        self.w = max(b["box"][2] for b in self.items.values()) + 60
        self.h = max(b["box"][3] for b in self.items.values()) + 60
        return self

    def width(self):
        return self.w

    def height(self):
        return self.h

    # =========================================================================
    # Elements
    # =========================================================================

    def emit(self):
        els, solid = [], []
        zones = sorted((k for k, v in self.items.items() if v["kind"] == "zone"),
                       key=lambda k: -(self.box(k)[2] - self.box(k)[0]) * (self.box(k)[3] - self.box(k)[1]))
        for k in zones:
            z = self.items[k]
            x0, y0, x1, y1 = z["box"]
            els.append(rect(self.id(f"band_{k}"), x0, y0, x1 - x0, y1 - y0, z["fill"], z["color"],
                            2 if z["dashed"] else 1.5, z["dashed"], 20))
            els.append(rect(self.id(f"{k}_badge"), x0 + 18, y0 + 18, 32, 32, z["color"], z["color"], 1, radius=8))
            els += glyph(z["icon"], x0 + 34, y0 + 34, 20, "#ffffff", 1.75, self.id(f"{k}_badge_i"))
            els.append(text_el(self.id(f"{k}_title"), x0 + 62, y0 + 22, z["title"], 20, z["color"]))
            solid.append(els[-1])
        for k, t in self.items.items():
            if t["kind"] == "card":
                els += self.card_els(k, t, solid)
            elif t["kind"] == "panel":
                x0, y0, x1, y1 = t["box"]
                els.append(rect(self.id(k), x0, y0, x1 - x0, y1 - y0, "#ffffff", t["color"], 1.5, radius=20))
                solid.append(els[-1])
                els.append(text_el(self.id(f"{k}_title"), x0 + 28, y0 + 24, t["title"], 20, t["color"]))
                for i, line in enumerate(t["lines"]):
                    y = y0 + 68 + 26 * i
                    els.append(dot(self.id(f"{k}_d{i}"), x0 + 34, y + 10, 7, t["color"]))
                    els.append(text_el(self.id(f"{k}_l{i}"), x0 + 50, y, line, 16, INK))
        els.append(text_el(self.id("doc_title"), 40, 30, self.title, 44, INK))
        els.append(text_el(self.id("doc_sub"), 42, 98, self.subtitle, 20, SUB))
        solid += els[-2:]
        els += self.legend(solid)
        return els, solid

    def card_els(self, k, t, solid):
        x0, y0, x1, y1 = t["box"]
        w, h, c, st = x1 - x0, y1 - y0, t["color"], t["status"]
        planned = st == "planned"
        out = [rect(self.id(k), x0, y0, w, h, "#ffffff", tint(c, 0.15) if planned else c, 1.5, planned)]
        solid.append(out[0])
        by = y0 + (h - BADGE) / 2
        tw = max([text_w(t["title"], 16)] + [text_w(s, 13) for s in (t["sub"] or "").split("\n")])
        bx = x0 + 16 if w <= W else x0 + (w - BADGE - 14 - tw) / 2
        out.append(rect(self.id(f"{k}_badge"), bx, by, BADGE, BADGE, tint(c, 0.87) if planned else c,
                        tint(c, 0.87) if planned else c, 1, radius=10))
        out += glyph(t["icon"], bx + BADGE / 2, by + BADGE / 2, 26, c if planned else "#ffffff", 2, self.id(f"{k}_i"))
        lines = t["sub"].count("\n") + 1 if t["sub"] else 0
        ty = y0 + (h - 20 - (4 + 16.25 * lines if lines else 0)) / 2
        out.append(text_el(self.id(f"{k}_title"), bx + BADGE + 14, ty, t["title"], 16, INK))
        if t["sub"]:
            out.append(text_el(self.id(f"{k}_sub"), bx + BADGE + 14, ty + 24, t["sub"], 13, SUB))
        if st:
            out.append(dot(self.id(f"{k}_st"), x1 - 17, y0 + 17, 10, STATUS[st]))
        for el in out[1:]:
            el["_own"] = self.id(k)
        return out

    def legend(self, solid):
        n = self.counts()
        items = [("card", s, f"{NAMES[s]} ({n[s]})") for s in STATUS] + [("link", "built", "working link"),
                                                                          ("link", "planned", "planned link")]
        widths = [(40 if kind == "card" else 56) + 12 + text_w(t, 18) for kind, _, t in items]
        x = self.w - 60 - sum(widths) - 36 * (len(items) - 1)
        out = []
        for i, (kind, st, label) in enumerate(items):
            if kind == "card":
                out.append(rect(self.id(f"leg_{i}"), x, 40, 40, 30, "#ffffff", "#495057" if st != "planned" else "#adb5bd",
                                1.5, st == "planned", 8))
                out.append(dot(self.id(f"leg_{i}d"), x + 30, 50, 8, STATUS[st]))
                tx = x + 52
            else:
                el = arrow_el(self.id(f"leg_{i}"), [(x, 55), (x + 56, 55)], LINE[st], st == "planned")
                el["endArrowhead"] = "arrow"
                out.append(el)
                tx = x + 68
            out.append(text_el(self.id(f"leg_t{i}"), tx, 44, label, 18, INK))
            solid.append(out[-1])
            x += widths[i] + 36
        return out

    # =========================================================================
    # Links
    # =========================================================================

    def route(self, els, solid):
        r = Router(step=16, margin=20, near=40)
        for e in solid:
            r.box(e["x"], e["y"], e["x"] + e["width"], e["y"] + e["height"])
        byid = {e["id"]: e for e in els}
        # a zone's border costs like a drawn wire, so links cross it square on instead of running along it
        borders = frozenset(("zone", k) for k, it in self.items.items() if it["kind"] == "zone")
        for k, it in self.items.items():
            if it["kind"] == "zone":
                z = byid[self.ref(k)]
                x0, y0, x1, y1 = z["x"], z["y"], z["x"] + z["width"], z["y"] + z["height"]
                for pts in (((x0, y0), (x1, y0)), ((x1, y0), (x1, y1)), ((x0, y1), (x1, y1)), ((x0, y0), (x0, y1))):
                    r.line(list(pts), frozenset({("zone", k)}))
        out, labels = [], []
        for n, (a, b, label, st, sides, both, merge, at, bus) in enumerate(self.wires, 1):
            ia, ib = self.ref(a), self.ref(b)
            tags = frozenset({("s", ia), ("d", ib)} if merge else {("w", n)})
            ea, eb = byid[ia], byid[ib]
            ea, eb = self.aim(a, ea, eb, sides[0]), self.aim(b, eb, ea, sides[1])
            res = (not bus and r.direct(ea, eb, *sides, tags=tags | borders, busy=True)) or r.route(ea, eb, (8, 170, self.w - 8, self.h - 8), *sides, tags=tags)
            if not res:
                print(f"no route: {a} -> {b}", file=sys.stderr)
                continue
            sa, sb, pts = res
            el = arrow_el(self.id(f"ar{n}"), pts, LINE[st], st == "planned", (ia, sa), (ib, sb))
            el["endArrowhead"] = "arrow"
            el["startArrowhead"] = "arrow" if both else None
            out.append(el)
            r.line(pts, tags)
            r.occupy(ia, sa, tags)
            r.occupy(ib, sb, tags)
            if label:
                labels.append((n, pts, label, st, at))
        for n, pts, label, st, at in labels:
            lx, ly = r.label(pts, label, 14, prefer=at, name=f"ar{n}")
            t = text_el(self.id(f"ar{n}_lbl"), lx, ly, label, 14, SUB if st == "built" else MUTED)
            out.append(t)
            r.box(t["x"], t["y"], t["x"] + t["width"], t["y"] + t["height"])
        return out

    def aim(self, k, el, other, sides):
        """A zone or wide card end narrowed to a window facing the other end, so the link meets it square on
        instead of jogging to its middle. The binding still names the whole box."""
        wide = self.items[k]["kind"] == "card" and el["width"] > W
        if (self.items[k]["kind"] != "zone" and not wide) or not sides or len(sides) != 1:
            return el
        flat = sides[0] in ("left", "right")
        pos, size = ("y", "height") if flat else ("x", "width")
        lo, hi = max(el[pos], other[pos]), min(el[pos] + el[size], other[pos] + other[size])
        mid = (lo + hi) / 2 if lo < hi else other[pos] + other[size] / 2
        mid = min(max(mid, el[pos] + 60), el[pos] + el[size] - 60)
        return dict(el, **{pos: mid - 32, size: 64})

    def check(self, scene, solid):
        seen = set()
        for e in scene:
            if e["id"] in seen:
                print(f"duplicate id: {e['id']}", file=sys.stderr)
            seen.add(e["id"])
        boxes = [(e["id"], e["x"], e["y"], e["x"] + e["width"], e["y"] + e["height"]) for e in solid]
        boxes += [(e["id"], e["x"], e["y"], e["x"] + e["width"], e["y"] + e["height"]) for e in scene
                  if e["id"].endswith("_lbl") and e["id"].startswith(self.id("ar"))]
        for i, a in enumerate(boxes):
            for b in boxes[i + 1:]:
                if a[1] < b[3] - 3 and b[1] < a[3] - 3 and a[2] < b[4] - 3 and b[2] < a[4] - 3:
                    print(f"overlap: {a[0]} / {b[0]}", file=sys.stderr)
        for e in scene:
            if e["type"] != "arrow" or e["id"].startswith(self.id("leg_")):
                continue
            ends = {(e.get("startBinding") or {}).get("elementId"), (e.get("endBinding") or {}).get("elementId")}
            pts = [(e["x"] + p[0], e["y"] + p[1]) for p in e["points"]]
            for b in boxes:
                if b[0] in ends:
                    continue
                if any(min(ax, bx) < b[3] - 3 and max(ax, bx) > b[1] + 3 and min(ay, by) < b[4] - 3
                       and max(ay, by) > b[2] + 3 for (ax, ay), (bx, by) in zip(pts, pts[1:])):
                    print(f"link {e['id']} crosses {b[0]}", file=sys.stderr)

    def build(self, fx, fy):
        els, solid = self.emit()
        scene = els + self.route(els, solid)
        self.check(scene, solid)
        dims = {e["id"]: (e["x"], e["y"], e["width"], e["height"]) for e in scene}
        for el in scene:
            fixed_points(el, dims)
        frame, group = self.id("frame"), f"g_{self.key}"
        for el in scene:
            el["x"] += fx
            el["y"] += fy
            el["frameId"] = frame
            own = el.pop("_own", None) or (el["id"] if self.items.get(el["id"][len(self.key) + 1:], {}).get("kind") == "card"
                                           else None)
            el["groupIds"] = [f"{own}_g", group] if own else [group]
            el["locked"] = True
            if el["id"] in self.links:
                el["link"] = link(self.links[el["id"]])
        scene.append({"id": frame, "type": "frame", "name": self.name, "x": fx, "y": fy, "width": self.w,
                      "height": self.h, "groupIds": [group], "locked": True})
        return scene
