import heapq
import sys

DIRS = ((1, 0), (-1, 0), (0, 1), (0, -1))
NORMAL = {"right": 0, "left": 1, "bottom": 2, "top": 3}
VEC = {"right": (1, 0), "left": (-1, 0), "bottom": (0, 1), "top": (0, -1)}
EDGE = 8
CELL = 256
INF = float("inf")
SHAPES = ("rectangle", "diamond", "ellipse")


def text_size(text, size):
    lines = text.split("\n")
    return max(len(s) for s in lines) * size * 0.52, len(lines) * size * 1.25


def simplify(pts):
    out = [pts[0]]
    for p, q in zip(pts[1:], pts[2:]):
        a = out[-1]
        if (abs(a[0] - p[0]) < 0.5 and abs(p[0] - q[0]) < 0.5) or (abs(a[1] - p[1]) < 0.5 and abs(p[1] - q[1]) < 0.5):
            continue
        out.append(p)
    out.append(pts[-1])
    return out


def ports(el, sides=None):
    x, y, w, h = el["x"], el["y"], el["width"], el["height"]
    fr = (0.5,) if el["type"] in ("diamond", "ellipse") else (0.5, 0.3, 0.7)
    out = []
    for side in sides or ("right", "bottom", "left", "top"):
        dx, dy = VEC[side]
        for f in fr:
            if dy:
                out.append((side, f, (x + w * f, y if dy < 0 else y + h)))
            else:
                out.append((side, f, (x if dx < 0 else x + w, y + h * f)))
    return out


def side_of(el, px, py, tol=14):
    """The side of `el` a line end sits just outside of, or None."""
    x0, y0, x1, y1 = el["x"], el["y"], el["x"] + el["width"], el["y"] + el["height"]
    if x0 - 2 <= px <= x1 + 2:
        if y0 - tol <= py <= y0 + 2:
            return "top"
        if y1 - 2 <= py <= y1 + tol:
            return "bottom"
    if y0 - 2 <= py <= y1 + 2:
        if x0 - tol <= px <= x0 + 2:
            return "left"
        if x1 - 2 <= px <= x1 + tol:
            return "right"
    return None


class Router:
    """Orthogonal A* on a `step` grid plus a line through every port, so a route meets its port square on.
    Boxes block. Drawn lines only cost: crossing one is cheap unless it is near where that line meets a box,
    and running along or within `near` of one is dear. A side a line already uses is dear too. Lines that share
    a source or a target with the route are free to it, so siblings leave or arrive as one trunk."""

    BEND, ALONG, NEAR, CROSS, END, SIDE, OFF = 260, 900, 260, 300, 1400, 1600, 60
    # per unit of vertical run inside a zone: a wire between lanes keeps to the margins
    ZONE = 3

    def __init__(self, step=16, margin=18, near=44):
        self.step, self.m, self.near = step, margin, near
        self.boxes, self.raw, self.index = [], [], {}
        self.h, self.v, self.occ = {}, {}, {}
        self.zones = []

    def box(self, x0, y0, x1, y1):
        m = self.m
        r = (x0 - m, y0 - m, x1 + m, y1 + m)
        k = len(self.boxes)
        self.boxes.append(r)
        self.raw.append((x0, y0, x1, y1))
        for gx in range(int(r[0] // CELL), int(r[2] // CELL) + 1):
            for gy in range(int(r[1] // CELL), int(r[3] // CELL) + 1):
                self.index.setdefault((gx, gy), []).append(k)
        return k

    def blocked(self, x, y, skip=()):
        for k in self.index.get((int(x // CELL), int(y // CELL)), ()):
            if k in skip:
                continue
            x0, y0, x1, y1 = self.boxes[k]
            if x0 < x < x1 and y0 < y < y1:
                return True
        return False

    def hits(self, x0, y0, x1, y1, pad=6):
        seen = set()
        for gx in range(int((x0 - pad) // CELL), int((x1 + pad) // CELL) + 1):
            for gy in range(int((y0 - pad) // CELL), int((y1 + pad) // CELL) + 1):
                for k in self.index.get((gx, gy), ()):
                    if k in seen:
                        continue
                    seen.add(k)
                    a0, b0, a1, b1 = self.raw[k]
                    if x0 - pad < a1 and x1 + pad > a0 and y0 - pad < b1 and y1 + pad > b0:
                        return True
        return False

    def line(self, pts, tags=frozenset()):
        s, n = self.step, len(pts) - 1
        for i, ((ax, ay), (bx, by)) in enumerate(zip(pts, pts[1:])):
            first, last = i == 0, i == n - 1
            if abs(ay - by) < 0.5 and abs(ax - bx) >= 0.5:
                lo, hi = (first, last) if ax < bx else (last, first)
                self.h.setdefault(round(ay / s), []).append((min(ax, bx), max(ax, bx), ay, tags, lo, hi))
            elif abs(ax - bx) < 0.5 and abs(ay - by) >= 0.5:
                lo, hi = (first, last) if ay < by else (last, first)
                self.v.setdefault(round(ax / s), []).append((min(ay, by), max(ay, by), ax, tags, lo, hi))

    def occupy(self, el_id, side, tags=frozenset()):
        self.occ.setdefault((el_id, side), []).append(tags)

    def line_hits(self, x0, y0, x1, y1):
        s = self.step
        for b in range(round(y0 / s) - 1, round(y1 / s) + 2):
            for a0, a1, yy, *_ in self.h.get(b, ()):
                if y0 < yy < y1 and a0 < x1 and a1 > x0:
                    return True
        for b in range(round(x0 / s) - 1, round(x1 / s) + 2):
            for b0, b1, xx, *_ in self.v.get(b, ()):
                if x0 < xx < x1 and b0 < y1 and b1 > y0:
                    return True
        return False

    def cost(self, x, y, nx, ny, tags=frozenset()):
        s, near, c = self.step, self.near, 0
        k = int(near * 2.5 // s) + 1
        horizontal = abs(y - ny) < 0.5
        along, across = (self.h, self.v) if horizontal else (self.v, self.h)
        at, frm, to = (y, x, nx) if horizontal else (x, y, ny)
        lo, hi = (frm, to) if frm < to else (to, frm)
        for b in range(round(at / s) - k, round(at / s) + k + 1):
            for a0, a1, pos, t, *_ in along.get(b, ()):
                d = abs(pos - at)
                if d < s * 0.5:
                    # end to end on one line reads as one wire
                    if a0 < hi + near and a1 > lo - near:
                        c += 0 if t & tags else self.ALONG
                elif a0 < hi and a1 > lo and d < (near * 2.5 if t & tags else near):
                    c += self.NEAR
        for b in range(round(lo / s) - 1, round(hi / s) + 2):
            for b0, b1, pos, t, e0, e1 in across.get(b, ()):
                # a wire that stops on another reads as joining it
                if lo < pos <= hi and b0 - s * 0.5 < at < b1 + s * 0.5 and not (t & tags):
                    c += self.CROSS
                    if (e0 and at - b0 < 44) or (e1 and b1 - at < 44):
                        c += self.END
        return c

    def _ends(self, el, sides, skip, start, tags):
        clear = self.m + 8
        out = []
        for side, f, (px, py) in ports(el, sides):
            dx, dy = VEC[side]
            a = (round(px + dx * EDGE, 1), round(py + dy * EDGE, 1))
            p = (round(px + dx * clear, 1), round(py + dy * clear, 1))
            if self.blocked(*p, skip=skip):
                continue
            c = self.cost(*(a + p) if start else (p + a), tags=tags)
            c += self.SIDE * sum(1 for t in self.occ.get((el["id"], side), ()) if not (t & tags))
            c += 0 if f == 0.5 else self.OFF
            out.append((p, NORMAL[side] if start else NORMAL[side] ^ 1, c, (side, a)))
        return out

    def direct(self, a, b, sides_a=None, sides_b=None, tags=frozenset(), busy=False):
        """A straight wire between two faces that look at each other, however close: the A* needs a clearance
        a tight gap does not have. A diamond or an ellipse only meets it at a vertex. `busy` lets it share a face
        another wire already uses, for a wide box that many straight wires meet side by side."""
        best = None
        for sa, sb in (("right", "left"), ("left", "right"), ("bottom", "top"), ("top", "bottom")):
            if (sides_a and sa not in sides_a) or (sides_b and sb not in sides_b):
                continue
            if not busy and any(not (t & tags) for t in [*self.occ.get((a["id"], sa), ()),
                                                         *self.occ.get((b["id"], sb), ())]):
                continue
            dx, dy = VEC[sa]
            flat = bool(dx)
            pos, length, cross, cw = ("x", "width", "y", "height") if flat else ("y", "height", "x", "width")
            fa = a[pos] + (a[length] if dx + dy > 0 else 0)
            fb = b[pos] + (0 if dx + dy > 0 else b[length])
            if (fb - fa) * (dx + dy) < 2 * EDGE + 14:
                continue

            def span(e):
                if e["type"] in ("diamond", "ellipse"):
                    m = e[cross] + e[cw] / 2
                    return m, m
                return e[cross] + e[cw] * 0.2, e[cross] + e[cw] * 0.8

            (la, ha), (lb, hb) = span(a), span(b)
            lo, hi = max(la, lb), min(ha, hb)
            if lo > hi + 0.5:
                continue
            c = (lo + hi) / 2
            for e in (a, b):
                m = e[cross] + e[cw] / 2
                if lo - 0.5 <= m <= hi + 0.5:
                    c = m
                    break
            p0, p1 = fa + (dx + dy) * EDGE, fb - (dx + dy) * EDGE
            seg = ((p0, c), (p1, c)) if flat else ((c, p0), (c, p1))
            (x0, y0), (x1, y1) = seg
            box = (min(x0, x1), min(y0, y1), max(x0, x1), max(y0, y1))
            mine = [(e["x"], e["y"], e["x"] + e["width"], e["y"] + e["height"]) for e in (a, b)]
            if self._crowded(box, mine) or self.cost(x0, y0, x1, y1, tags) >= self.CROSS:
                continue
            if best is None or abs(p1 - p0) < best[0]:
                best = (abs(p1 - p0), sa, sb, [seg[0], seg[1]])
        return best and best[1:]

    def _crowded(self, box, mine, pad=10):
        x0, y0, x1, y1 = box
        for gx in range(int((x0 - pad) // CELL), int((x1 + pad) // CELL) + 1):
            for gy in range(int((y0 - pad) // CELL), int((y1 + pad) // CELL) + 1):
                for k in self.index.get((gx, gy), ()):
                    r = self.raw[k]
                    if any(all(abs(u - v) < 1 for u, v in zip(r, m)) for m in mine):
                        continue
                    if x0 - pad < r[2] and x1 + pad > r[0] and y0 - pad < r[3] and y1 + pad > r[1]:
                        return True
        return False

    def route(self, a, b, bounds, sides_a=None, sides_b=None, skip=(), tags=frozenset()):
        s = self.step
        starts = self._ends(a, sides_a, skip, True, tags)
        goals = self._ends(b, sides_b, skip, False, tags)
        if not starts or not goals:
            return None
        special_x = {p[0] for p, *_ in starts + goals}
        special_y = {p[1] for p, *_ in starts + goals}
        # a sibling's trunk is a track this route can ride exactly
        for lines, special, (lo, hi) in ((self.v, special_x, bounds[0::2]), (self.h, special_y, bounds[1::2])):
            for row in lines.values():
                for _, _, pos, t, *_ in row:
                    if t & tags and lo <= pos <= hi:
                        special.add(round(pos, 1))

        def axis(lo, hi, special):
            first = -(-lo // s) * s
            base = [round(first + k * s, 1) for k in range(int((hi - first) / s) + 1)]
            base = [v for v in base if all(abs(v - q) >= 4 for q in special)]
            return sorted(set(base) | special)

        X, Y = axis(bounds[0], bounds[2], special_x), axis(bounds[1], bounds[3], special_y)
        xi, yi = {v: i for i, v in enumerate(X)}, {v: i for i, v in enumerate(Y)}
        goal_at = {}
        for p, need, c, info in goals:
            goal_at.setdefault((xi[p[0]], yi[p[1]]), []).append((need, c, info))
        gl = [p for p, *_ in goals]

        def hfun(x, y):
            return min(abs(x - gx) + abs(y - gy) for gx, gy in gl)

        heap, best, parent = [], {}, {}
        for p, d, c, info in starts:
            st = (xi[p[0]], yi[p[1]], d)
            if c < best.get(st, INF):
                best[st], parent[st] = c, ("start", info)
                heapq.heappush(heap, (c + hfun(*p), c, st))
        done, blocked, found = set(), {}, None
        while heap:
            f, g, st = heapq.heappop(heap)
            if st in done:
                continue
            done.add(st)
            i, j, d = st
            for need, c, info in goal_at.get((i, j), ()):
                if need == d:
                    total = g + c
                    if found is None or total < found[0]:
                        found = (total, st, info)
            if found and f >= found[0]:
                break
            x, y = X[i], Y[j]
            for nd, (di, dj) in enumerate(DIRS):
                if nd == d ^ 1:
                    continue
                ni, nj = i + di, j + dj
                if not (0 <= ni < len(X) and 0 <= nj < len(Y)):
                    continue
                key = (ni, nj)
                if key not in blocked:
                    blocked[key] = self.blocked(X[ni], Y[nj], skip)
                if blocked[key]:
                    continue
                nx, ny = X[ni], Y[nj]
                ng = g + abs(nx - x) + abs(ny - y) + self.cost(x, y, nx, ny, tags) + (self.BEND if nd != d else 0)
                if di == 0 and self.zones:
                    mx, my = x, (y + ny) / 2
                    if any(z[0] < mx < z[2] and z[1] < my < z[3] for z in self.zones):
                        ng += abs(ny - y) * self.ZONE
                ns = (ni, nj, nd)
                if ng < best.get(ns, INF):
                    best[ns], parent[ns] = ng, st
                    heapq.heappush(heap, (ng + hfun(nx, ny), ng, ns))
        if not found:
            return None
        _, st, (sb, pb) = found
        cells = []
        while True:
            cells.append((X[st[0]], Y[st[1]]))
            p = parent[st]
            if p[0] == "start":
                sa, pa = p[1]
                break
            st = p
        cells.reverse()
        return sa, sb, simplify([pa] + cells + [pb])

    def shared(self, a, b):
        """Whether another line runs along most of this segment besides the wire's own: a label there reads as
        a sibling's."""
        (ax, ay), (bx, by) = a, b
        flat = abs(ay - by) < 0.5
        at, lo, hi = (ay, min(ax, bx), max(ax, bx)) if flat else (ax, min(ay, by), max(ay, by))
        n = 0
        for a0, a1, pos, *_ in (self.h if flat else self.v).get(round(at / self.step), ()):
            if abs(pos - at) < 2 and min(a1, hi) - max(a0, lo) > (hi - lo) * 0.5:
                n += 1
        return n > 1

    def label(self, pts, text, size=15, own=True, prefer=None, name=""):
        """A clear spot beside a drawn wire, once every wire is drawn: a run of its own before one a sibling
        shares, horizontal before vertical, longest first, sliding out from each run's middle. A short run is
        tried last with a tighter clearance. `own=False` lets a trunk's label sit on the shared run. `prefer`
        "start" keeps a branch's label by its decision, "end" puts it by the box the wire enters."""
        w, h = text_size(text, size)
        segs = list(zip(pts, pts[1:]))
        if prefer == "end":
            segs = [(b, a) for a, b in reversed(segs)]
        order = segs if prefer else sorted(segs, key=lambda ab: (own and self.shared(*ab), abs(ab[0][1] - ab[1][1]) >= 0.5,
                                                                 -(abs(ab[1][0] - ab[0][0]) + abs(ab[1][1] - ab[0][1]))))
        for slack, pad in ((60, 10), (22, 5), (6, 3)):
            for (ax, ay), (bx, by) in order:
                if prefer and own and self.shared((ax, ay), (bx, by)):
                    continue
                flat = abs(ay - by) < 0.5
                lo, hi = (min(ax, bx), max(ax, bx)) if flat else (min(ay, by), max(ay, by))
                need = w if flat else h
                if hi - lo < need + slack:
                    continue
                if prefer:
                    d = 1 if (bx - ax if flat else by - ay) > 0 else -1
                    room = hi - lo - need - slack / 1.25
                    cs = [(ax if flat else ay) + d * (need / 2 + slack / 2.5 + room * f) for f in (0, 0.15, 0.3, 0.5, 0.75, 1)]
                else:
                    cs = [min(max(lo + (hi - lo) * f, lo + need / 2 + slack / 2.5), hi - need / 2 - slack / 2.5)
                          for f in (0.5, 0.38, 0.62, 0.26, 0.74, 0.14, 0.86)]
                for c in cs:
                    spots = ([(c - w / 2, ay - 8 - h), (c - w / 2, ay + 8)] if flat
                             else [(ax + 12, c - h / 2), (ax - 12 - w, c - h / 2)])
                    for lx, ly in spots:
                        if not self.hits(lx, ly, lx + w, ly + h, pad) and not self.line_hits(lx - 4, ly - 4, lx + w + 4,
                                                                                             ly + h + 4):
                            return lx, ly
        (ax, ay), (bx, by) = max(segs, key=lambda ab: abs(ab[1][0] - ab[0][0]) + abs(ab[1][1] - ab[0][1]))
        print(f"label has no clear spot: {text!r} {name}", file=sys.stderr)
        if abs(ay - by) < 0.5:
            return (ax + bx) / 2 - w / 2, ay - 8 - h
        return ax + 12, (ay + by) / 2 - h / 2
