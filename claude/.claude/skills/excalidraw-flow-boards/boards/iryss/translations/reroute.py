"""Re-routes every arrow in the translation flow and re-places its labels, patching the live frame in place."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "engine"))

from canvas import apply, live  # noqa: E402
from lib import arrow_el, fixed_points, text_el  # noqa: E402
from route import EDGE, SHAPES, Router  # noqa: E402

FRAME = "frame_full"
SIZE = 16
# a trunk the wires feeding it now reach their box through, and labels that repeat the box they point at
TRUNKS = {"lk_10"}
DROP = {"lk_t3", "lk_t4"}
NAMED = {"p2n": "muymyb15jgks9hucgrq", "w3n": "muymyb1533dtwxihhwk", "cn_q7": "muymyb1527eqkzhxhfq",
         "cn_k5": "muymyb151ng9zstrm9k", "cn_t8": "muymyb157ilfo7fj1cd", "cn_n8": "muymyb15c4ak4p3y8aj",
         "cn_x8": "muymyb157yv8lekftow", "lk_t1": "lk_1", "lk_t2": "lk_5", "lk_t5": "lk_12"}
TRUNK_LABELS = {"lk_1"}
# each map box sits under the lane it feeds; a decision sits level with the box that feeds it
MOVE = {"m_person": {"x": 1031}, "m_retry": {"x": 1380}, "m_sweep": {"x": 2042},
        "l5": {"y": 5263}, "l6": {"y": 5281}, "l5r": {"y": 5468}}
# a hop into the next lane is labelled where it enters that lane's first box; a feeder of a shared trunk by
# the box it leaves, so the label is never on the trunk
END_LABELS = {NAMED[k] for k in ("cn_t8", "cn_n8", "cn_k5", "cn_x8")}
START_LABELS = {NAMED[k] for k in ("w3n", "cn_q7")}
# the run's outcomes merge into one trunk, which reads as a mess drawn dashed
SOLID = {"muymyb159iuo97yqtoc", "muymyb1534kfxpn6y56", "muymyb156ap9vdk8rgi", "muymyb15rw39wls4xy"}


def pts_of(a):
    return [(a["x"] + p[0], a["y"] + p[1]) for p in a["points"]]


def gap(e, px, py):
    dx = max(e["x"] - px, 0, px - e["x"] - e["width"])
    dy = max(e["y"] - py, 0, py - e["y"] - e["height"])
    return (dx * dx + dy * dy) ** 0.5


def on_line(a, px, py, tol=3):
    for (ax, ay), (bx, by) in zip(pts_of(a), pts_of(a)[1:]):
        if min(ax, bx) - tol <= px <= max(ax, bx) + tol and min(ay, by) - tol <= py <= max(ay, by) + tol:
            return True
    return False


class Flow:
    def __init__(self):
        self.els = live()
        self.byid = {e["id"]: e for e in self.els}
        self.fr = self.byid[FRAME]
        self.mine = [e for e in self.els if e.get("frameId") == FRAME]
        self.shapes = [e for e in self.mine if e["type"] in SHAPES and not e["id"].startswith(("band_", "leg_"))]
        self.arrows = [e for e in self.mine if e["type"] == "arrow"]
        ids = {a["id"] for a in self.arrows}
        # a label bound to an arrow carries no frameId
        self.bound = {t["containerId"]: t for t in self.els if t["type"] == "text" and t.get("containerId") in ids}
        self.free = {t["id"]: t for t in self.mine if t["type"] == "text" and not t.get("containerId")
                     and (t["id"].startswith("al_") or t["id"] in NAMED or t["id"] in DROP)}

    def end(self, a, i, seen):
        b = a.get(("startBinding", "endBinding")[i])
        if b and b["elementId"] in {s["id"] for s in self.shapes}:
            return b["elementId"]
        p = pts_of(a)[-i]
        d, s = min(((gap(s, *p), s) for s in self.shapes), key=lambda t: t[0])
        if d <= 30:
            return s["id"]
        for o in self.arrows:
            if o["id"] not in seen and on_line(o, *p):
                return self.end(o, i, seen | {o["id"]})
        raise ValueError(f"{a['id']} end {i} reaches nothing")

    def label_of(self, a):
        t = self.bound.get(a["id"]) or self.free.get(f"al_{a['id']}")
        if not t:
            t = next((self.free[k] for k, v in NAMED.items() if v == a["id"] and k in self.free), None)
        return t

    def edges(self):
        out = []
        for a in self.arrows:
            if a["id"] in TRUNKS:
                continue
            src, dst = self.end(a, 0, {a["id"]}), self.end(a, 1, {a["id"]})
            t = self.label_of(a)
            out.append({"a": a, "src": src, "dst": dst, "label": t})
        return out

    def router(self):
        r = Router(step=8, margin=18, near=44)
        skip = {t["id"] for t in self.free.values()}
        for e in self.mine:
            if e["type"] in ("frame", "arrow") or e.get("containerId") or e["id"].startswith("band_"):
                continue
            if e["id"] in skip:
                continue
            r.box(e["x"], e["y"], e["x"] + e["width"], e["y"] + e["height"])
        for b in self.mine:
            if b["id"].startswith("band_"):
                body = [e for e in self.mine if e["type"] != "arrow" and not e.get("containerId")
                        and not e["id"].startswith(("band_", "title_", "sub_")) and b["y"] <= e["y"]
                        and e["y"] + e["height"] <= b["y"] + b["height"]]
                if body:
                    r.zones.append((min(e["x"] for e in body) - 20, b["y"], max(e["x"] + e["width"] for e in body) + 20,
                                    b["y"] + b["height"]))
        return r

    def manual(self):
        """The wires between lanes, which the grid search would thread through whatever lies between. A hop
        forward crosses in the gutter and drops into the top of the next lane's first box; a loop back climbs
        the right margin, the outermost loop furthest out; wires into one box share one trunk."""
        B = self.byid

        def L(i): return B[i]["x"]
        def R(i): return B[i]["x"] + B[i]["width"]
        def T(i): return B[i]["y"]
        def D(i): return B[i]["y"] + B[i]["height"]
        def X(i): return B[i]["x"] + B[i]["width"] / 2
        def Y(i): return B[i]["y"] + B[i]["height"] / 2

        bands = sorted((e for e in self.mine if e["id"].startswith("band_")), key=lambda e: e["y"])
        gut = {(a["id"][5:], b["id"][5:]): (a["y"] + a["height"] + b["y"]) / 2 for a, b in zip(bands, bands[1:])}
        edge = max(b["x"] + b["width"] for b in bands)
        r1, r2, r3 = edge - 90, edge - 60, edge - 30
        titles = [t for t in self.mine if t["id"].startswith(("title_", "sub_")) and T("b0") < t["y"] < T("l4")]
        xl = max(t["x"] + t["width"] for t in titles) + 28
        yb = D("api_n") + 18
        x7 = R("e7") + 26
        y2 = (max(D(i) for i in ("s2", "s4")) + min(T(i) for i in ("e1r", "e4r"))) / 2
        y5 = (max(D(i) for i in ("w0", "w1", "w2", "w3", "w4")) + min(T(i) for i in ("k3r", "k6r"))) / 2
        e = EDGE

        def drop(x, gap, i):
            """From a vertical at `x`, across the gutter and down into the top of `i`."""
            return [(x, gut[gap]), (X(i), gut[gap]), (X(i), T(i) - e)]

        def bus(i):
            return [(X("a6"), D("a6") + e), (X("a6"), yb), (xl, yb), (xl, Y(i)), (L(i) - e, Y(i))]

        # queue.add has three feeders, joined in turn on one run above its lane's notes: the requeue, then
        # after commit, then the sweep
        k0 = [(X("q7"), y5), (X("w3"), y5), (X("k0"), y5), (X("k0"), T("k0") - e)]
        return {
            "lk_1": ("bottom", "left", bus("s_def")),
            "lk_2": ("bottom", "left", bus("s_opt")),
            "lk_3": ("bottom", "left", bus("s_cat")),
            "lk_4": ("bottom", "left", bus("e0")),
            "lk_5": ("bottom", "top", [(X("e2"), D("e2") + e)] + drop(X("e2"), ("src", "man"), "p0")),
            "lk_6": ("bottom", "top", [(X("s3"), D("s3") + e), (X("s3"), y2), (x7, y2)] + drop(x7, ("man", "req"), "q0")),
            "lk_7": ("right", "top", [(R("e7") + e, Y("e7")), (x7, Y("e7"))] + drop(x7, ("man", "req"), "q0")),
            "lk_9": ("right", "top", [(R("o5") + e, Y("o5")), (r3, Y("o5"))] + drop(r3, ("man", "req"), "q0")),
            "lk_12": ("right", "top", [(R("x8") + e, Y("x8")), (r2, Y("x8")), (r2, y5)] + k0),
            NAMED["cn_q7"]: ("bottom", "top", [(X("q7"), D("q7") + e)] + k0),
            NAMED["w3n"]: ("bottom", "top", [(X("w3"), D("w3") + e)] + k0[1:]),
            NAMED["cn_k5"]: ("bottom", "top", [(X("k5"), D("k5") + e)] + drop(X("k5"), ("q", "run"), "u0")),
            NAMED["cn_t8"]: ("right", "top", [(R("t8") + e, Y("t8")), (r1, Y("t8"))] + drop(r1, ("tr", "ans"), "n0")),
            NAMED["cn_n8"]: ("bottom", "top", [(X("n8"), D("n8") + e)] + drop(X("n8"), ("ans", "end"), "x0")),
            NAMED["cn_x8"]: ("bottom", "top", [(X("x8"), D("x8") + e)] + drop(X("x8"), ("end", "rev"), "r_0")),
            "lk_11": ("top", "left", [(X("l4"), T("l4") - e), (X("l4"), gut[("ops", "loc")]), (xl, gut[("ops", "loc")]),
                                      (xl, Y("b0")), (L("b0") - e, Y("b0"))]),
        }

    def run(self, dry=False):
        edges = self.edges()
        r = self.router()
        fx0, fy0 = self.fr["x"] + 12, self.fr["y"] + 12
        fx1, fy1 = self.fr["x"] + self.fr["width"] - 12, self.fr["y"] + self.fr["height"] - 12

        def centre(i):
            e = self.byid[i]
            return e["x"] + e["width"] / 2, e["y"] + e["height"] / 2

        def span(ed):
            (ax, ay), (bx, by) = centre(ed["src"]), centre(ed["dst"])
            return abs(ax - bx) + abs(ay - by)

        edges.sort(key=span)
        update, create, delete = [], [], []
        placed = []

        def tags_of(ed):
            # a decision's yes and no leave by different vertices; a box's fan-out shares one trunk
            branch = self.byid[ed["src"]]["type"] == "diamond" and ed["label"]
            return frozenset({("d", ed["dst"])} | (set() if branch else {("s", ed["src"])}))

        def commit(ed, res):
            a, b = self.byid[ed["src"]], self.byid[ed["dst"]]
            sa, sb, pts = res
            tags = tags_of(ed)
            r.line(pts, tags)
            r.occupy(ed["src"], sa, tags)
            r.occupy(ed["dst"], sb, tags)
            el = arrow_el(ed["a"]["id"], pts, ed["a"]["strokeColor"], False, (ed["src"], sa), (ed["dst"], sb))
            fixed_points(el, {i: (e["x"], e["y"], e["width"], e["height"]) for i, e in ((ed["src"], a), (ed["dst"], b))})
            st = {k: el[k] for k in ("x", "y", "points", "width", "height", "startBinding", "endBinding")}
            st["boundElements"] = []
            if ed["a"]["id"] in SOLID:
                st["strokeStyle"] = "solid"
            update.append({"id": el["id"], "set": st})
            placed.append((ed, pts))

        manual = self.manual()
        for ed in edges:
            m = manual.get(ed["a"]["id"])
            if m:
                sa, sb, pts = m
                commit(ed, (sa, sb, [(round(x, 1), round(y, 1)) for x, y in pts]))
        rest = []
        for ed in edges:
            if ed["a"]["id"] in manual:
                continue
            res = r.direct(self.byid[ed["src"]], self.byid[ed["dst"]], tags=tags_of(ed))
            if res:
                commit(ed, res)
            else:
                rest.append(ed)
        print(f"manual {len(manual)}, direct {len(edges) - len(rest) - len(manual)}, routed {len(rest)}", file=sys.stderr)
        for ed in rest:
            a, b = self.byid[ed["src"]], self.byid[ed["dst"]]
            res = None
            for pad in (320, None):
                if pad is None:
                    bounds = (fx0, fy0, fx1, fy1)
                else:
                    bounds = (max(fx0, min(a["x"], b["x"]) - pad), max(fy0, min(a["y"], b["y"]) - pad),
                              min(fx1, max(a["x"] + a["width"], b["x"] + b["width"]) + pad),
                              min(fy1, max(a["y"] + a["height"], b["y"] + b["height"]) + pad))
                res = r.route(a, b, bounds, tags=tags_of(ed))
                if res:
                    break
            if not res:
                print(f"no route: {ed['src']} -> {ed['dst']} ({ed['a']['id']})", file=sys.stderr)
                continue
            commit(ed, res)
        # a label never straddles a lane's edge
        for e in self.mine:
            if e["id"].startswith("band_"):
                for y in (e["y"], e["y"] + e["height"]):
                    r.box(e["x"], y - 1, e["x"] + e["width"], y + 1)
                for x in (e["x"], e["x"] + e["width"]):
                    r.box(x - 1, e["y"], x + 1, e["y"] + e["height"])
        for ed, pts in placed:
            t = ed["label"]
            if not t:
                continue
            prefer = ("start" if self.byid[ed["src"]]["type"] == "diamond" or ed["a"]["id"] in START_LABELS else
                      "end" if ed["a"]["id"] in END_LABELS else None)
            lx, ly = r.label(pts, t["text"], SIZE, own=ed["a"]["id"] not in TRUNK_LABELS, prefer=prefer, name=ed["a"]["id"])
            lid = t["id"] if not t.get("containerId") else f"al_{ed['a']['id']}"
            new = text_el(lid, lx, ly, t["text"], SIZE, t["strokeColor"])
            r.box(new["x"], new["y"], new["x"] + new["width"], new["y"] + new["height"])
            if t.get("containerId"):
                delete.append(t["id"])
                new.update(frameId=FRAME, groupIds=list(self.fr.get("groupIds") or []) or ["g_translations_full"],
                           locked=True)
                create.append(new)
            else:
                update.append({"id": lid, "set": {k: new[k] for k in ("x", "y", "width", "height", "fontSize",
                                                                       "fontFamily", "lineHeight", "textAlign",
                                                                       "verticalAlign")}})
        delete += sorted((TRUNKS & set(self.byid)) | (DROP & set(self.free)))
        print(f"edges {len(edges)}, routed {len(placed)}, updates {len(update)}, creates {len(create)}, "
              f"deletes {len(delete)}", file=sys.stderr)
        if dry:
            for ed in edges:
                print(ed["a"]["id"], ed["src"], "->", ed["dst"], repr(ed["label"]["text"]) if ed["label"] else "")
            return
        for part in [p for p in ({"delete": delete}, {"update": update, "create": create}) if any(p.values())]:
            apply(part)


def move():
    els = {e["id"]: e for e in live()}
    up = []
    for k, to in MOVE.items():
        d = {a: v - els[k][a] for a, v in to.items()}
        if all(abs(v) < 0.5 for v in d.values()):
            continue
        up.append({"id": k, "set": dict(to)})
        up += [{"id": t["id"], "set": {a: els[t["id"]][a] + v for a, v in d.items()}}
               for t in els[k].get("boundElements") or [] if t["type"] == "text" and t["id"] in els]
    if up:
        print("moved", len(up), file=sys.stderr)
        apply({"update": up})


if "--dry" not in sys.argv:
    move()
Flow().run(dry="--dry" in sys.argv)
