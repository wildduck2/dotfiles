"""Builds IRYSS flow boards: python3 -I build.py <board ...|all> dry|apply|scene

A board is a b_<board>.py beside this file. On the web app, the default, each board is a scene of its own in
SCENES: it rebuilds where its frame stands, or at the origin, and dry writes patch-<board>.json to the working
directory and changes nothing. scene creates a new board's scene in FOLDER and prints its id for SCENES.

With CANVAS=local every board shares the old canvas: a new board goes past the last one on its side of the
translation flow, a board that grows pushes its outward neighbours along, a board in ABOVE sits over all the
others and never moves them, and dry writes patch.json."""
import importlib
import json
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path[:0] = [str(HERE), str(HERE.parents[1] / "engine")]

import canvas  # noqa: E402
from canvas import MODE, apply, live, new_scene, prepare  # noqa: E402
from lib import BLUE, arrow_el, fixed_points, obstacles, text_el  # noqa: E402
from route import Router  # noqa: E402

WORKSPACE = "3effc6f2-639c-4d16-9eee-2522eb56354c"
FOLDER = "faa392a9-dcdd-4ee2-b4d4-aa6d689873a5"
SCENES = {
    "": "b73840a7-8d74-4bad-aae7-9a13fc8c77d8",
    "hosts": "2d82ae3d-e5fc-41d8-bd60-3c6c1bf67e61",
    "auth": "ad5764b8-e4e6-4efc-9ec9-cfcda226f322",
    "iam": "e0b392b4-fa4f-4986-96f0-b62a64972d77",
    "attrs": "7bbca40e-3aec-4593-92a5-521e82025495",
    "cats": "dd361a86-9da0-4684-b713-4cea55c88c39",
    "products": "4ad0d614-6ff0-4fb2-b2bd-26f37ea35136",
    "platform": "a514035d-9559-4cd8-80bb-6b13d77e2da2",
    "upload": "e51dd23f-14c5-450e-abf0-35e939520a92",
    "translations": "b73840a7-8d74-4bad-aae7-9a13fc8c77d8",
}

ANCHOR = "frame_full"
LEFT = ["hosts", "auth", "iam"]
RIGHT = ["words", "attrs", "cats", "products"]
ABOVE = ["platform"]
GAP = 400
MIN_GAP = 200
ABOVE_GAP = 700


def above(b, f, frames):
    """Centred over every other board. A rebuild keeps the frame's bottom edge, so a taller board grows away from
    the boards beneath it."""
    if f:
        return f["x"], f["y"] + f["height"] - b.height()
    rest = [g for k, g in frames.items() if k != b.id("frame")]
    x0, x1 = min(g["x"] for g in rest), max(g["x"] + g["width"] for g in rest)
    return (x0 + x1 - b.width()) / 2, min(g["y"] for g in rest) - ABOVE_GAP - b.height()


def place(made, frames, rebuild):
    full = frames[ANCHOR]
    mid = full["x"] + full["width"] / 2
    pos, shift, sides = {}, {}, {"left": [], "right": []}
    for n, b in made.items():
        f = frames.get(b.id("frame"))
        if n in ABOVE:
            if n in rebuild:
                pos[n] = above(b, f, frames)
        elif f:
            sides["left" if f["x"] + f["width"] / 2 < mid else "right"].append(n)
        elif n in rebuild:
            sides["left" if n in LEFT else "right"].append(n)

    def walk(names, order, start, sign):
        edge = start
        for n in sorted(names, key=lambda n: (order.index(n) if n in order else len(order),
                                              sign * frames[made[n].id("frame")]["x"] if made[n].id("frame") in frames
                                              else float("inf"))):
            f = frames.get(made[n].id("frame"))
            w = made[n].width() if n in rebuild else f["width"]
            if sign > 0:
                x = f["x"] if f and f["x"] - edge >= MIN_GAP else edge + GAP
                edge = x + w
            else:
                right = f["x"] + f["width"] if f and edge - (f["x"] + f["width"]) >= MIN_GAP else edge - GAP
                x = edge = right - w
            if n in rebuild:
                pos[n] = (x, f["y"] if f else full["y"])
            elif abs(x - f["x"]) > 0.5:
                shift[n] = x - f["x"]

    walk(sides["right"], RIGHT, full["x"] + full["width"], 1)
    walk(sides["left"], LEFT[::-1], full["x"], -1)
    return pos, shift


def cross(made, els):
    """Board to board wires, routed over every board at once so they keep to the gaps and the margins."""
    r = Router(step=24, margin=22)
    obstacles(r, els)
    frames = {e["id"]: e for e in els if e["type"] == "frame"}
    for f in frames.values():
        r.box(f["x"], f["y"] - 34, f["x"] + len(f.get("name") or "") * 10 + 24, f["y"] - 4)
    byid = {e["id"]: e for e in els}
    out, n, labels = [], 0, []
    for b in made.values():
        for a, t, label, sides in b.remote:
            if a not in byid or t not in byid:
                print(f"no such element: {a if a not in byid else t}", file=sys.stderr)
                continue
            fa, ft = frames[byid[a]["frameId"]], frames[byid[t]["frameId"]]
            lo, hi = sorted((fa, ft), key=lambda f: f["x"])
            fs = [f for f in frames.values() if lo["x"] <= f["x"] <= hi["x"]]
            bounds = (lo["x"] - 240, min(f["y"] for f in fs) - 420, hi["x"] + hi["width"] + 240,
                      max(f["y"] + f["height"] for f in fs) + 240)
            tags = frozenset({("s", a), ("d", t)})
            t0 = time.time()
            res = r.route(byid[a], byid[t], bounds, *sides, tags=tags)
            print(f"  {a} -> {t}: {time.time() - t0:.1f}s", file=sys.stderr)
            if not res:
                print(f"no route: {a} -> {t}", file=sys.stderr)
                continue
            sa, sb, pts = res
            n += 1
            out.append(arrow_el(f"xb_{n}", pts, BLUE, True, (a, sa), (t, sb)))
            r.line(pts, tags)
            r.occupy(a, sa, tags)
            r.occupy(t, sb, tags)
            if label:
                labels.append((n, pts, label))
    for n, pts, label in labels:
        lx, ly = r.label(pts, label, 18)
        lab = text_el(f"xb_{n}_lbl", lx, ly, label, 18, BLUE)
        out.append(lab)
        r.box(lab["x"], lab["y"], lab["x"] + lab["width"], lab["y"] + lab["height"])
    dims = {e["id"]: (e["x"], e["y"], e["width"], e["height"]) for e in els}
    for el in out:
        fixed_points(el, dims)
        el["groupIds"] = ["g_xboard"]
        el["locked"] = True
    return out


def members(els, key):
    frame, group = f"{key}_frame", f"g_{key}"
    ids = {e["id"] for e in els if e["id"] == frame or e.get("frameId") == frame or group in (e.get("groupIds") or [])
           or e["id"].startswith(key + "_")}
    return ids | {e["id"] for e in els if e.get("containerId") in ids}


def web(made, rebuild, mode):
    canvas.SCENES.update({"": SCENES[""], **{b.key: SCENES[n] for n, b in made.items() if n in SCENES}})
    if mode == "scene":
        for n in rebuild:
            if n in SCENES:
                sys.exit(f"{n} already has a scene, {SCENES[n]}")
            res = new_scene(made[n].name, WORKSPACE, FOLDER)
            sid = res.get("id") or (res.get("scene") or {}).get("id") if isinstance(res, dict) else None
            if not sid:
                sys.exit(f"create_scene answered no id: {json.dumps(res)[:400]}")
            print(f'"{n}": "{sid}",')
        return
    missing = [n for n in rebuild if n not in SCENES]
    if missing:
        sys.exit(f"no scene for {missing}: run build.py {' '.join(missing)} scene, then add each id to SCENES")
    for n in rebuild:
        b, scene = made[n], SCENES[n]
        els = live(scene)
        f = next((e for e in els if e["id"] == b.id("frame")), None)
        x, y = (f["x"], f["y"]) if f else (0, 0)
        b.layout()
        delete = sorted(members(els, b.key))
        create = prepare(b.build(x, y), els)
        if b.remote:
            print(f"{b.key}: {len(b.remote)} wires to other boards are drawn on the local canvas only",
                  file=sys.stderr)
        json.dump({"scene": scene, "delete": delete, "create": create}, open(f"patch-{n}.json", "w"),
                  ensure_ascii=False)
        print(f"{b.key}: {len(create)} elements at {x:.0f},{y:.0f} size {b.width():.0f}x{b.height():.0f}, "
              f"replacing {len(delete)}; patch-{n}.json", file=sys.stderr)
        if mode == "apply":
            before = f"before {n} {time.strftime('%Y-%m-%d %H:%M')}"
            if delete:
                apply({"delete": delete}, scene, before)
            apply({"create": create}, scene, None if delete else before)


def main(names, mode):
    files = sorted(p.stem[2:] for p in HERE.glob("b_*.py"))
    if MODE != "local":
        made = {n: importlib.import_module(f"b_{n}").make() for n in files}
        rebuild = list(made) if names == ["all"] else names
        unknown = [n for n in rebuild if n not in made]
        if unknown:
            sys.exit(f"no board file for {unknown}; have {sorted(made)}")
        return web(made, rebuild, mode)
    els = live()
    frames = {e["id"]: e for e in els if e["type"] == "frame"}
    # the board-to-board wires route in this order, each one an obstacle to the next
    order = [n for n in LEFT + RIGHT if n in files] + [n for n in files if n not in LEFT + RIGHT]
    made = {n: importlib.import_module(f"b_{n}").make() for n in order}
    rebuild = list(made) if names == ["all"] else names
    unknown = [n for n in rebuild if n not in made]
    if unknown:
        sys.exit(f"no board file for {unknown}; have {sorted(made)}")
    for n in rebuild:
        made[n].layout()
    pos, shift = place(made, frames, rebuild)

    create, delete = [], set()
    for n in rebuild:
        b = made[n]
        delete |= members(els, b.key)
        scene = b.build(*pos[n])
        create += scene
        print(f"{b.key}: {len(scene)} elements at {pos[n][0]:.0f},{pos[n][1]:.0f} size {b.width():.0f}x{b.height():.0f}",
              file=sys.stderr)
    moved = {}
    for n, dx in shift.items():
        for i in members(els, made[n].key):
            moved[i] = dx
        print(f"{made[n].key}: moves {dx:+.0f} to keep the gap", file=sys.stderr)
    update = [{"id": e["id"], "x": e["x"] + moved[e["id"]]} for e in els if e["id"] in moved]

    touched = {made[n].key + "_" for n in [*rebuild, *shift]}
    links = [(a, t) for b in made.values() for a, t, *_ in b.remote]
    if any(a.startswith(k) or t.startswith(k) for a, t in links for k in touched):
        delete |= {e["id"] for e in els if e["id"].startswith("xb_")}
        after = [dict(e, x=e["x"] + moved.get(e["id"], 0)) for e in els if e["id"] not in delete]
        create += cross(made, after + create)

    patch = {k: v for k, v in (("delete", sorted(delete)), ("create", create), ("update", update)) if v}
    json.dump(patch, open("patch.json", "w"), ensure_ascii=False)
    print(f"patch.json: delete {len(delete)}, create {len(create)}, update {len(update)}", file=sys.stderr)
    if mode == "apply":
        if delete:
            apply({"delete": sorted(delete)})
        if create or update:
            apply({k: v for k, v in (("create", create), ("update", update)) if v})


if len(sys.argv) < 3 or sys.argv[-1] not in ("dry", "apply", "scene"):
    sys.exit(__doc__)
main(sys.argv[1:-1], sys.argv[-1])
