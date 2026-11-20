"""Lists what collides inside one group: arrows through boxes, arrows over arrows, labels over lines.
Usage: audit.py <group> [patch.json | sceneId]: the creates of a dry run before it is applied, or what is live,
on a web scene or with CANVAS=local on the old canvas."""
import json
import sys

sys.path.insert(0, __file__.rsplit("/", 1)[0])

from canvas import live  # noqa: E402

SHAPES = ("rectangle", "diamond", "ellipse")


def load(group, src=None):
    els = json.load(open(src))["create"] if src and src.endswith(".json") else live(src)
    return [e for e in els if group in (e.get("groupIds") or [])], {e["id"]: e for e in els}


def segs(a):
    pts = [(a["x"] + p[0], a["y"] + p[1]) for p in a["points"]]
    return list(zip(pts, pts[1:]))


def ends(a, byid):
    out = set()
    for k in ("startBinding", "endBinding"):
        b = a.get(k)
        if b:
            out.add(b["elementId"])
    return out


def box(e, pad=0):
    return e["x"] - pad, e["y"] - pad, e["x"] + e["width"] + pad, e["y"] + e["height"] + pad


def hit(seg, bx, inset=3):
    (ax, ay), (bx_, by) = seg
    lx, hx, ly, hy = min(ax, bx_), max(ax, bx_), min(ay, by), max(ay, by)
    x0, y0, x1, y1 = bx
    return lx < x1 - inset and hx > x0 + inset and ly < y1 - inset and hy > y0 + inset


def cross(s, t):
    (a, b), (c, d) = s, t
    sh, th = abs(a[1] - b[1]) < 0.5, abs(c[1] - d[1]) < 0.5
    sv, tv = abs(a[0] - b[0]) < 0.5, abs(c[0] - d[0]) < 0.5
    if sh and tv:
        # a wire that stops on another, as siblings merging do, is a junction rather than a crossing
        return (min(a[0], b[0]) + 2 < c[0] < max(a[0], b[0]) - 2
                and min(c[1], d[1]) + 2 < a[1] < max(c[1], d[1]) - 2)
    if sv and th:
        return cross(t, s)
    return False


def overlap(s, t):
    (a, b), (c, d) = s, t
    if abs(a[1] - b[1]) < 0.5 and abs(c[1] - d[1]) < 0.5 and abs(a[1] - c[1]) < 6:
        return min(max(a[0], b[0]), max(c[0], d[0])) - max(min(a[0], b[0]), min(c[0], d[0])) > 10
    if abs(a[0] - b[0]) < 0.5 and abs(c[0] - d[0]) < 0.5 and abs(a[0] - c[0]) < 6:
        return min(max(a[1], b[1]), max(c[1], d[1])) - max(min(a[1], b[1]), min(c[1], d[1])) > 10
    return False


def main(group, patch=None):
    els, byid = load(group, patch)
    if not els:
        raise SystemExit(f"{group}: no element is in it, so there is nothing to audit. SKILL.md says which key.")
    arrows = [e for e in els if e["type"] == "arrow"]
    shapes = [e for e in els if e["type"] in SHAPES and "band" not in e["id"]]
    texts = [e for e in els if e["type"] == "text" and not e.get("containerId")]
    lbl = {e["id"] for e in els if e["type"] == "text" and e.get("containerId") in {a["id"] for a in arrows}}
    n = 0
    for a in arrows:
        diag = [s for s in segs(a) if abs(s[0][0] - s[1][0]) > 1 and abs(s[0][1] - s[1][1]) > 1]
        if diag:
            print("diagonal", a["id"], len(diag)); n += 1
        own = ends(a, byid)
        for s in segs(a):
            for e in shapes + texts:
                if e["id"] in own:
                    continue
                if hit(s, box(e)):
                    t = e.get("text") or next((byid[x["id"]].get("text") for x in (e.get("boundElements") or [])
                                               if x["type"] == "text" and x["id"] in byid), "")
                    print("through", a["id"], "->", e["id"], repr((t or "")[:30])); n += 1
                    break
    for i, a in enumerate(arrows):
        for b in arrows[i + 1:]:
            c = sum(cross(s, t) for s in segs(a) for t in segs(b))
            o = sum(overlap(s, t) for s in segs(a) for t in segs(b))
            same = ends(a, byid) & ends(b, byid)
            if o and not same:
                print("overlap", a["id"], b["id"]); n += 1
            if c:
                print("cross", a["id"], b["id"], c); n += 1
    print("issues", n)


main(*sys.argv[1:3])
