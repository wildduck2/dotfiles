import sys

import canvas

INK = "#1e1e1e"
RED = "#e03131"
GREEN = "#2f9e44"
GRAY = "#868e96"
ORANGE = "#f08c00"
BLUE = "#1971c2"
SUB = "#495057"
PAL = {
    "plain": ("#ffffff", INK),
    "table": ("#f1f3f5", INK),
    "red": ("#fff5f5", RED),
    "ok": ("#ebfbee", GREEN),
    "gray": ("#ffffff", GRAY),
    "jump": ("#e7f5ff", BLUE),
}
SLOTS = ["up2", "up", "main", "down", "down2", "down3", "data", "foot"]
X0 = 320
COL_GAP = 110
SLOT_GAP = 84
LANE_PAD = 56
LANE_GAP = 40
EDGE = 8


def char_w(c):
    if c in "iljtfr.,:;'|!()[]{} ":
        return 6.5
    if c.isupper() or c in "_@#%&mwMW<>=+":
        return 13.3
    if c.isdigit():
        return 11.5
    return 11


def line_w(s):
    return sum(char_w(c) for c in s)


def shape_size(kind, text):
    lines = text.split("\n")
    lw = max(line_w(s) for s in lines)
    n = len(lines)
    if kind == "dia":
        return max(220, lw * 2.3 + 60), max(124, n * 50 + 44)
    if kind in ("table", "jump"):
        return max(190, lw * 1.42 + 52), max(84, n * 25 * 1.42 + 44)
    return max(170, lw + 40), max(74, n * 25 + 38)


def wrap(text, n=72):
    out = []
    for para in text.split("\n"):
        if len(para) <= n:
            out.append(para)
            continue
        k = -(-len(para) // n)
        target = -(-len(para) // k) + 4
        line = ""
        for word in para.split(" "):
            if line and len(line) + 1 + len(word) > target:
                out.append(line)
                line = word
            else:
                line = f"{line} {word}" if line else word
        out.append(line)
    return "\n".join(out)


def text_w(text, size, mono=False):
    k = 0.6 if mono else 0.52
    return max(len(s) for s in text.split("\n")) * size * k


def text_el(id, x, y, text, size=16, color=SUB, mono=False):
    return {"id": id, "type": "text", "x": round(x), "y": round(y), "width": round(text_w(text, size, mono)),
            "height": round(len(text.split("\n")) * size * 1.25), "text": text, "fontSize": size,
            "fontFamily": 3 if mono else 2, "strokeColor": color, "lineHeight": 1.25, "textAlign": "left",
            "verticalAlign": "top"}


def arrow_el(id, pts, color, dashed=False, a=None, b=None, width=2):
    x0, y0 = pts[0]
    rel = [[round(px - x0), round(py - y0)] for px, py in pts]
    el = {"id": id, "type": "arrow", "x": round(x0), "y": round(y0), "points": rel,
          "width": max(abs(p[0]) for p in rel), "height": max(abs(p[1]) for p in rel),
          "strokeColor": color, "strokeWidth": width, "roughness": 0, "roundness": None}
    if dashed:
        el["strokeStyle"] = "dashed"
    if a:
        el["startBinding"] = {"elementId": a[0], "mode": "orbit", "_side": a[1]}
    if b:
        el["endBinding"] = {"elementId": b[0], "mode": "orbit", "_side": b[1]}
    return el


def obstacles(router, els):
    from route import SHAPES, side_of
    shapes = []
    for e in els:
        if e.get("isDeleted") or e["type"] in ("frame", "arrow") or e.get("containerId"):
            continue
        if "_band_" in e["id"] or e["id"].startswith("band_"):
            continue
        router.box(e["x"], e["y"], e["x"] + e["width"], e["y"] + e["height"])
        if e["type"] in SHAPES:
            shapes.append(e)
    cells = {}
    for e in shapes:
        for gx in range(int((e["x"] - 16) // 256), int((e["x"] + e["width"] + 16) // 256) + 1):
            for gy in range(int((e["y"] - 16) // 256), int((e["y"] + e["height"] + 16) // 256) + 1):
                cells.setdefault((gx, gy), []).append(e)
    for e in els:
        if e.get("isDeleted") or e["type"] != "arrow":
            continue
        pts = [(e["x"] + p[0], e["y"] + p[1]) for p in e["points"]]
        router.line(pts)
        for px, py in (pts[0], pts[-1]):
            for el in cells.get((int(px // 256), int(py // 256)), ()):
                side = side_of(el, px, py)
                if side:
                    router.occupy(el["id"], side)
                    break


def fixed_points(el, dims):
    for k, i in (("startBinding", 0), ("endBinding", -1)):
        if k in el and "_side" in el[k]:
            x, y, w, h = dims[el[k]["elementId"]]
            px, py = el["x"] + el["points"][i][0], el["y"] + el["points"][i][1]
            el[k].pop("_side")
            fx_, fy_ = (px - x) / w, (py - y) / h
            el[k]["fixedPoint"] = [0.5001 if abs(fx_ - 0.5) < 1e-3 else round(fx_, 4),
                                   0.5001 if abs(fy_ - 0.5) < 1e-3 else round(fy_, 4)]


def link(eid):
    return canvas.link(eid)


class Node:
    def __init__(self, id, col, slot, kind, text, pal, to=None, size=16, color=SUB, tag=None):
        self.id, self.col, self.slot, self.kind, self.text, self.pal, self.to = id, col, slot, kind, text, pal, to
        self.size, self.color, self.tag = size, color, tag
        if kind == "note":
            self.w, self.h = text_w(text, size), len(text.split("\n")) * size * 1.25
        elif kind == "sticker":
            lines = text.split("\n")
            self.w = max(len(s) for s in lines) * 9.0 + 30
            self.h = len(lines) * 15 * 1.25 + 26 + 26
        else:
            self.w, self.h = shape_size(kind, text)
        self.x = self.y = 0

    def edge(self, side):
        if self.kind == "sticker":
            top = self.y - self.h / 2 + 26
            return {"top": (self.x, top - 30), "left": (self.x - self.w / 2, top + 20),
                    "right": (self.x + self.w / 2, top + 20)}[side]
        return {"left": (self.x - self.w / 2, self.y), "right": (self.x + self.w / 2, self.y),
                "top": (self.x, self.y - self.h / 2), "bottom": (self.x, self.y + self.h / 2)}[side]

    def box(self):
        return self.x - self.w / 2, self.y - self.h / 2, self.x + self.w / 2, self.y + self.h / 2


class Grid:
    """One lane: columns sized to what they hold, fixed row slots, arrows routed on the grid."""

    def __init__(self, board, key, slots=None, gap=SLOT_GAP):
        self.b, self.key = board, key
        self.slots, self.gap = slots or SLOTS, gap
        self.nodes, self.edges, self.spans, self.flows, self.ties = {}, [], [], [], []

    def n(self, id, col, slot, kind, text, pal="plain", to=None):
        assert id not in self.nodes, id
        if kind == "jump":
            pal = "jump"
        self.nodes[id] = Node(id, col, slot, kind, text, pal, to)
        return id

    def row(self, slot, start, items, chain=True):
        """Items left to right from column `start`: (id, kind, text[, pal]); a jump's fourth field is its target."""
        ids = []
        for i, it in enumerate(items):
            if it is None:
                continue
            id, kind, text, *rest = it
            if kind == "jump":
                ids.append(self.n(id, start + i, slot, kind, text, "jump", rest[0]))
            else:
                ids.append(self.n(id, start + i, slot, kind, text, rest[0] if rest else "plain"))
        if chain:
            self.chain(*ids)
        return ids

    def s(self, id, col, tag, text, slot="data", of=None):
        """A data sticker; `of` draws a dotted tie from the step that produces it, straight up or down its column."""
        self.nodes[id] = Node(id, col, slot, "sticker", text, None, tag=tag)
        if of:
            self.ties.append((of, id))
        return id

    def becomes(self, *ids):
        """Orange dashed arrows: each sticker's data becomes the next one's. Same slot only."""
        self.flows += list(zip(ids, ids[1:]))

    def note(self, id, col, slot, text, size=16, color=SUB, span=True):
        """Free text. A spanning note takes no width from its column, so it may run right across empty cells."""
        self.nodes[id] = Node(id, col, slot, "note", wrap(text), None, size=size, color=color)
        if span:
            self.spans.append(id)
        return id

    def e(self, a, b, label=None, color=None, dashed=False, off=0, under=False):
        """`off` shifts a straight arrow sideways, so a pair running both ways stays apart; `under` bends a
        same-row arrow down through the gap beneath the row, past the steps between."""
        self.edges.append((a, b, label, color, dashed, off, under))

    def chain(self, *ids):
        for a, b in zip(ids, ids[1:]):
            self.e(a, b)

    # =========================================================================
    # Layout
    # =========================================================================

    def _color(self, b):
        return {"red": RED, "ok": GREEN, "jump": BLUE, "gray": GRAY}.get(self.nodes[b].pal, INK)

    def layout(self, top):
        ncol = max(n.col for n in self.nodes.values()) + 1
        widths = [0] * ncol
        for n in self.nodes.values():
            if n.id not in self.spans:
                widths[n.col] = max(widths[n.col], n.w)
        gaps = [COL_GAP] * ncol
        for a, b, label, *_ in self.edges:
            na, nb = self.nodes[a], self.nodes[b]
            if label and na.slot == nb.slot and abs(na.col - nb.col) == 1:
                c = min(na.col, nb.col)
                gaps[c] = max(gaps[c], text_w(label, 15) + 40)
        xs, x = [], self.b.x0
        for c in range(ncol):
            w = widths[c] or 100
            widths[c] = w
            xs.append(x + w / 2)
            x += w + gaps[c]
        same = {}
        for n in self.nodes.values():
            if n.kind == "box":
                same.setdefault(n.slot, []).append(n)
        for group in same.values():
            h = max(n.h for n in group)
            for n in group:
                n.h = h
        heights = {}
        for n in self.nodes.values():
            heights[n.slot] = max(heights.get(n.slot, 0), n.h)
        ys, y = {}, top + LANE_PAD
        for s in self.slots:
            if s in heights:
                ys[s] = y
                y += heights[s] + (SLOT_GAP if s in ("data", "foot") else self.gap)
        self.bottom = y - SLOT_GAP + LANE_PAD
        for n in self.nodes.values():
            n.x = xs[n.col] - widths[n.col] / 2 + n.w / 2 if n.id in self.spans else xs[n.col]
            n.y = ys[n.slot] + (n.h / 2 if n.kind in ("sticker", "note") else heights[n.slot] / 2)
        self.right = max(n.box()[2] for n in self.nodes.values())

    def _hits(self, pts, skip):
        for n in self.nodes.values():
            if n.id in skip:
                continue
            x0, y0, x1, y1 = n.box()
            for (ax, ay), (bx, by) in zip(pts, pts[1:]):
                lx, hx, ly, hy = min(ax, bx), max(ax, bx), min(ay, by), max(ay, by)
                if lx < x1 - 2 and hx > x0 + 2 and ly < y1 - 2 and hy > y0 + 2:
                    return n.id
        return None

    def route(self, a, b, off=0, under=False):
        na, nb = self.nodes[a], self.nodes[b]
        if under:
            p, q = na.edge("bottom"), nb.edge("bottom")
            y = max(p[1], q[1]) + self.gap / 2
            return ("bottom", "bottom"), [p, (p[0], y), (q[0], y), q]
        if na.slot == nb.slot:
            sa, sb = ("right", "left") if nb.x > na.x else ("left", "right")
            p, q = na.edge(sa), nb.edge(sb)
            opts = [((sa, sb), [(p[0], p[1] + off), (q[0], q[1] + off)])]
        elif abs(na.x - nb.x) < 2:
            sa, sb = ("bottom", "top") if nb.y > na.y else ("top", "bottom")
            p, q = na.edge(sa), nb.edge(sb)
            opts = [((sa, sb), [(p[0] + off, p[1]), (q[0] + off, q[1])])]
        else:
            down, right = nb.y > na.y, nb.x > na.x
            sa, sb = ("bottom" if down else "top"), ("left" if right else "right")
            p, q = na.edge(sa), nb.edge(sb)
            sa2, sb2 = ("right" if right else "left"), ("top" if down else "bottom")
            p2, q2 = na.edge(sa2), nb.edge(sb2)
            opts = [((sa, sb), [p, (p[0], q[1]), q]), ((sa2, sb2), [p2, (q2[0], p2[1]), q2])]
        for opt in opts:
            if not self._hits(opt[1], {a, b}):
                return opt
        print(f"route crosses {self._hits(opts[0][1], {a, b})}: {self.b.key}.{a} -> {b}", file=sys.stderr)
        return opts[0]

    def emit(self):
        b = self.b
        P = lambda i: f"{self.key}_{i}"
        for n in self.nodes.values():
            if n.kind == "note":
                b.text(P(n.id), n.x - n.w / 2, n.y - n.h / 2, n.text, n.size, n.color)
            elif n.kind == "sticker":
                b.sticker(P(n.id), n.x - n.w / 2, n.y - n.h / 2 + 26, n.tag, n.text, n.w)
            else:
                kind = {"box": "rectangle", "dia": "diamond", "table": "ellipse", "jump": "ellipse"}[n.kind]
                b.shape(P(n.id), kind, n, n.pal, n.to)
        for a, bb, label, color, dashed, off, under in self.edges:
            sides, pts = self.route(a, bb, off, under)
            color = color or self._color(bb)
            dashed = dashed or self.nodes[bb].kind == "jump"
            b.bound_arrow(P(a), P(bb), sides, pts, color, dashed)
            if label:
                (ax, ay), (bx, by) = pts[1:3] if under else pts[:2]
                lines = label.count("\n") + 1
                if abs(ay - by) < 1:
                    lx = (ax + bx) / 2 - text_w(label, 15) / 2
                    ly = ay + 6 if off > 0 else ay - 6 - 19 * lines
                else:
                    lx, ly = ax + 10, (ay + by) / 2 - 10 * lines
                b.text(P(f"lbl_{a}_{bb}"), lx, ly, label, 15, color)
        for x, y in self.flows:
            pa, pb = self.nodes[x].edge("right"), self.nodes[y].edge("left")
            if abs(pa[1] - pb[1]) > 1:
                print(f"becomes needs one slot: {self.b.key}.{x} -> {y}", file=sys.stderr)
            b.line([(pa[0] + EDGE, pa[1]), (pb[0] - EDGE, pb[1])], ORANGE, dashed=True)
        for src, sid in self.ties:
            m, n = self.nodes[src], self.nodes[sid]
            if abs(m.x - n.x) > 2:
                print(f"tie not in one column: {self.b.key}.{src} -> {sid}", file=sys.stderr)
            if n.y > m.y:
                p, q = m.edge("bottom"), n.edge("top")
                b.line([(p[0], p[1] + EDGE), (p[0], q[1])], GRAY, dotted=True, head=False, width=1)
            else:
                p = m.edge("top")
                b.line([(p[0], p[1] - EDGE), (p[0], n.y + n.h / 2 + 4)], GRAY, dotted=True, head=False, width=1)


class Board:
    def __init__(self, key, name, x0=X0, square=False):
        self.key, self.name, self.x0, self.square = key, name, x0, square
        self.lanes, self.els, self.links = [], [], {}
        self.wires, self.remote, self.trunks = [], [], []
        self.next = 190
        self.arrows = 0
        self.legend = [("rectangle", "plain", "step"), ("diamond", "plain", "decision"), ("ellipse", "table", "table"),
                       ("rectangle", "red", "refused"), ("rectangle", "ok", "success"),
                       ("ellipse", "jump", "other board"), ("sticky", None, "data"), ("wire", INK, "lane link"),
                       ("wire", BLUE, "board link")]

    def id(self, local):
        return f"{self.key}_{local}"

    def ref(self, local):
        lane, node = local.split(".")
        return f"{self.key}_{lane}_{node}"

    def wire(self, a, b, label=None, sides=(None, None)):
        """A plain black arrow between lanes, or a blue dashed one to `key:lane.node` on another board, routed
        around everything already drawn."""
        if ":" in b:
            key, local = b.split(":")
            target = local if key == "full" else f"{key}_{local.replace('.', '_')}"
            self.remote.append((self.ref(a), target, label, sides))
        else:
            self.wires.append((self.ref(a), self.ref(b), label, sides))

    def trunk(self, src, targets, label=None, x=None):
        """One black line from `src` down the left margin, branching into each target's left face: a request
        fanning out to the lanes it runs. Drawn before the wires, which route around it."""
        self.trunks.append((src, targets, label, x))

    def lane(self, key, title, sub, slots=None, gap=SLOT_GAP):
        g = Grid(self, key, slots, gap)
        g.title, g.sub = title, sub
        self.lanes.append(g)
        return g

    # =========================================================================
    # Elements
    # =========================================================================

    def shape(self, id, kind, n, pal, to):
        bg, st = PAL[pal]
        el = {"id": self.id(id), "type": kind, "x": round(n.x - n.w / 2), "y": round(n.y - n.h / 2),
              "width": round(n.w), "height": round(n.h), "text": n.text, "fontSize": 20, "fontFamily": 5,
              "backgroundColor": bg, "strokeColor": st, "fillStyle": "solid", "strokeWidth": 2, "roughness": 0}
        if kind == "rectangle" and not self.square:
            el["roundness"] = {"type": 3}
        if pal == "jump":
            el["strokeStyle"] = "dashed"
        if to:
            self.links[el["id"]] = to
        self.els.append(el)

    def text(self, id, x, y, text, size=16, color=SUB, mono=False):
        self.els.append(text_el(self.id(id), x, y, text, size, color, mono))

    def sticker(self, id, x, y, tag, text, w):
        h = len(text.split("\n")) * 15 * 1.25 + 26
        self.text(f"{id}_tag", x + 2, y - 24, tag, 15, "#e67700")
        self.els.append({"id": self.id(id), "type": "rectangle", "x": round(x), "y": round(y), "width": round(w),
                         "height": round(h), "backgroundColor": "#fff9db", "strokeColor": "#f59f00",
                         "fillStyle": "solid", "roughness": 0, "strokeWidth": 1, "roundness": {"type": 3}})
        self.text(f"{id}_txt", x + 15, y + 13, text, 15, INK, mono=True)

    def bound_arrow(self, a, b, sides, pts, color, dashed):
        self.arrows += 1
        pts = [list(p) for p in pts]
        out = {"left": (-1, 0), "right": (1, 0), "top": (0, -1), "bottom": (0, 1)}
        for i, side in ((0, sides[0]), (-1, sides[1])):
            dx, dy = out[side]
            pts[i][0] += dx * EDGE
            pts[i][1] += dy * EDGE
        x0, y0 = pts[0]
        rel = [[round(px - x0), round(py - y0)] for px, py in pts]
        el = {"id": self.id(f"ar{self.arrows}"), "type": "arrow", "x": round(x0), "y": round(y0), "points": rel,
              "width": max(abs(p[0]) for p in rel), "height": max(abs(p[1]) for p in rel),
              "strokeColor": color, "strokeWidth": 2, "roughness": 0, "roundness": None,
              "startBinding": {"elementId": self.id(a), "mode": "orbit", "_side": sides[0]},
              "endBinding": {"elementId": self.id(b), "mode": "orbit", "_side": sides[1]}}
        if dashed:
            el["strokeStyle"] = "dashed"
        self.els.append(el)

    def line(self, pts, color, dashed=False, dotted=False, head=True, width=2):
        self.arrows += 1
        x0, y0 = pts[0]
        rel = [[round(px - x0), round(py - y0)] for px, py in pts]
        el = {"id": self.id(f"ln{self.arrows}"), "type": "arrow", "x": round(x0), "y": round(y0), "points": rel,
              "width": max(abs(p[0]) for p in rel), "height": max(abs(p[1]) for p in rel),
              "strokeColor": color, "strokeWidth": width, "roughness": 0, "roundness": None}
        if not head:
            el["endArrowhead"] = None
        if dashed:
            el["strokeStyle"] = "dashed"
        if dotted:
            el["strokeStyle"] = "dotted"
        self.els.append(el)

    # =========================================================================
    # Board
    # =========================================================================

    def head(self, title, sub):
        self.title, self.subtitle = title, sub

    def layout(self):
        y = self.next
        for g in self.lanes:
            g.top = y
            g.layout(y)
            y = g.bottom + LANE_GAP
        self.height_ = y + 20
        self.band_w = max([g.right for g in self.lanes] + [self.x0 + 9 * 190 + 260]) + 210
        return self

    def width(self):
        return self.band_w + 80

    def height(self):
        return self.height_

    def emit(self):
        bands = []
        for i, g in enumerate(self.lanes):
            bands.append({"id": self.id(f"band_{g.key}"), "type": "rectangle", "x": 0, "y": round(g.top),
                          "width": round(self.band_w), "height": round(g.bottom - g.top),
                          "backgroundColor": "#f8f9fa" if i % 2 == 0 else "#ffffff", "strokeColor": "#dee2e6",
                          "fillStyle": "solid", "roughness": 0, "strokeWidth": 1})
            nt = g.title.count("\n") + 1
            self.text(f"title_{g.key}", 22, g.top + 18, g.title, 22, INK)
            self.text(f"sub_{g.key}", 22, g.top + 26 + 28 * nt, g.sub, 14, SUB)
            g.emit()
        self.text("doc_title", 20, 24, self.title, 44, INK)
        self.text("doc_sub", 22, 92, self.subtitle, 20, SUB)
        items = self.legend
        lx = self.band_w - len(items) * 190
        for i, (kind, pal, label) in enumerate(items):
            x = lx + i * 190
            if kind == "wire":
                self.els.append(arrow_el(self.id(f"leg_{i}"), [(x, 57), (x + 48, 57)], pal, pal == BLUE))
                self.text(f"leg_t{i}", x + 60, 46, label, 20, INK)
                continue
            if kind == "sticky":
                el = {"type": "rectangle", "backgroundColor": "#fff9db", "strokeColor": "#f59f00", "strokeWidth": 1,
                      "roundness": {"type": 3}}
            else:
                bg, st = PAL[pal]
                el = {"type": kind, "backgroundColor": bg, "strokeColor": st, "strokeWidth": 2}
                if pal == "jump":
                    el["strokeStyle"] = "dashed"
                if kind == "rectangle" and not self.square:
                    el["roundness"] = {"type": 3}
            el.update({"id": self.id(f"leg_{i}"), "x": x, "y": 40, "width": 48, "height": 34, "fillStyle": "solid",
                       "roughness": 0})
            self.els.append(el)
            self.text(f"leg_t{i}", x + 60, 46, label, 20, INK)
        for src, targets, label, x in self.trunks:
            self.draw_trunk(src, targets, label, x)
        return bands + self.els

    def node(self, local):
        lane, node = local.split(".")
        return next(g for g in self.lanes if g.key == lane).nodes[node]

    def draw_trunk(self, src, targets, label, x):
        s, ts = self.node(src), [self.node(t) for t in targets]
        lane = next(g for g in self.lanes if s in g.nodes.values())
        x = x or self.x0 - 80
        yc = lane.bottom + LANE_GAP / 2
        sx, sy = s.edge("bottom")
        self.arrows += 1
        el = arrow_el(self.id(f"tr{self.arrows}"), [(sx, sy + EDGE), (sx, yc), (x, yc), (x, max(t.y for t in ts))], INK,
                      a=(self.ref(src), "bottom"))
        el["endArrowhead"] = None
        self.els.append(el)
        for local, t in zip(targets, ts):
            self.arrows += 1
            self.els.append(arrow_el(self.id(f"tr{self.arrows}"), [(x, t.y), (t.x - t.w / 2 - EDGE, t.y)], INK,
                                     b=(self.ref(local), "left")))
        if label:
            self.text(f"tr{self.arrows}_lbl", (sx + x) / 2 - text_w(label, 15) / 2, yc + 6, label, 15, INK)

    def check(self, scene):
        seen = set()
        for e in scene:
            if e["id"] in seen:
                print(f"duplicate id: {e['id']}", file=sys.stderr)
            seen.add(e["id"])
        boxes = [(e["id"], e["x"], e["y"], e["x"] + e["width"], e["y"] + e["height"]) for e in scene
                 if e["type"] in ("rectangle", "diamond", "ellipse", "text") and "_band_" not in e["id"]
                 and not e["id"].endswith("_txt")]
        for i, a in enumerate(boxes):
            for b in boxes[i + 1:]:
                if a[1] < b[3] - 3 and b[1] < a[3] - 3 and a[2] < b[4] - 3 and b[2] < a[4] - 3:
                    if b[0] == a[0] + "_tag" or a[0] == b[0] + "_tag":
                        continue
                    print(f"overlap: {a[0]} / {b[0]}", file=sys.stderr)
        for e in scene:
            if e["type"] != "arrow":
                continue
            for b in boxes:
                if b[0].startswith(self.id("sub_")) or b[0].startswith(self.id("title_")):
                    continue
                ends = {(e.get("startBinding") or {}).get("elementId"), (e.get("endBinding") or {}).get("elementId")}
                if b[0] in ends or b[0].endswith("_tag"):
                    continue
                pts = [(e["x"] + p[0], e["y"] + p[1]) for p in e["points"]]
                for (ax, ay), (bx, by) in zip(pts, pts[1:]):
                    lx, hx, ly, hy = min(ax, bx), max(ax, bx), min(ay, by), max(ay, by)
                    if lx < b[3] - 3 and hx > b[1] + 3 and ly < b[4] - 3 and hy > b[2] + 3:
                        print(f"arrow {e['id']} crosses {b[0]}", file=sys.stderr)
                        break

    def route_wires(self, scene):
        from route import Router
        r = Router()
        obstacles(r, scene)
        byid = {e["id"]: e for e in scene}
        bounds = (8, 160, self.band_w - 8, self.height_ - 8)
        labels = []
        for a, b, label, sides in self.wires:
            tags = frozenset({("s", a), ("d", b)})
            res = r.route(byid[a], byid[b], bounds, *sides, tags=tags)
            if not res:
                print(f"no route: {a} -> {b}", file=sys.stderr)
                continue
            sa, sb, pts = res
            self.arrows += 1
            n = self.arrows
            scene.append(arrow_el(self.id(f"wr{n}"), pts, INK, False, (a, sa), (b, sb)))
            r.line(pts, tags)
            r.occupy(a, sa, tags)
            r.occupy(b, sb, tags)
            if label:
                labels.append((n, pts, label))
        for n, pts, label in labels:
            lx, ly = r.label(pts, label)
            t = text_el(self.id(f"wr{n}_lbl"), lx, ly, label, 15, INK)
            scene.append(t)
            r.box(t["x"], t["y"], t["x"] + t["width"], t["y"] + t["height"])

    def build(self, fx, fy):
        scene = self.emit()
        self.route_wires(scene)
        self.check(scene)
        ox, oy = fx + 40, fy + 20
        frame = self.id("frame")
        group = [f"g_{self.key}"]
        dims = {e["id"]: (e["x"], e["y"], e["width"], e["height"]) for e in scene}
        for el in scene:
            fixed_points(el, dims)
        for el in scene:
            el["x"] += ox
            el["y"] += oy
            el["frameId"] = frame
            el["groupIds"] = group
            el["locked"] = True
            if el["id"] in self.links:
                el["link"] = link(self.links[el["id"]])
        scene.append({"id": frame, "type": "frame", "name": self.name, "x": fx, "y": fy, "width": self.width(),
                      "height": self.height(), "groupIds": group, "locked": True})
        return scene
