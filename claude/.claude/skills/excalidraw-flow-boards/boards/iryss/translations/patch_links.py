import json, sys, urllib.request
els = json.load(urllib.request.urlopen("http://127.0.0.1:3100/api/elements"))
els = els.get("elements", els)
by = {e["id"]: e for e in els}
INK, GRAY = "#1e1e1e", "#868e96"
frame = by["frame_full"]
OX = frame["x"] + 40
BW = OX + 3720
M = OX + 225
M2 = OX + 280
CH, CH2, CH3 = BW + 20, BW + 32, BW + 8


def g(id):
    e = by[id]
    return e["x"], e["y"], e["width"], e["height"]


def cxy(id):
    x, y, w, h = g(id)
    return x + w / 2, y + h / 2


def top(id):
    x, y, w, h = g(id)
    return x + w / 2, y


def bot(id):
    x, y, w, h = g(id)
    return x + w / 2, y + h


def lft(id):
    x, y, w, h = g(id)
    return x, y + h / 2


def rgt(id):
    x, y, w, h = g(id)
    return x + w, y + h / 2


def gap(band):
    return by[band]["y"] - 20


create = []
n = 0


def poly(pts, head=True, color=INK):
    global n
    n += 1
    x0, y0 = pts[0]
    el = {"id": f"lk_{n}", "type": "arrow", "x": round(x0), "y": round(y0),
          "points": [[round(x - x0), round(y - y0)] for x, y in pts],
          "strokeColor": color, "strokeWidth": 2, "roughness": 0, "frameId": "frame_full"}
    if not head:
        el["endArrowhead"] = None
    create.append(el)


def text(id, x, y, s, size=15):
    create.append({"id": id, "type": "text", "x": round(x), "y": round(y), "width": round(len(s) * size * 0.5),
                   "height": round(size * 1.3), "text": s, "fontSize": size, "fontFamily": "helvetica",
                   "strokeColor": INK, "frameId": "frame_full"})


g12, g23, g34, g45 = gap("band_src"), gap("band_man"), gap("band_req"), gap("band_q")

ax, ay = bot("a6")
sx, sy = lft("s_def")
poly([(ax, ay + 8), (ax, g12), (M, g12), (M, sy), (sx - 8, sy)])
for b in ("s_opt", "s_cat", "e0"):
    bx, by_ = lft(b)
    poly([(M, sy), (M, by_), (bx - 8, by_)])
text("lk_t1", ax - 330, g12 - 24, "the service runs one of the writes below")

ex, ey = bot("e2")
px, py = top("p0")
poly([(ex, ey + 8), (ex, g23), (px, g23), (px, py - 8)])
text("lk_t2", ex + 10, ey + 14, "no", 16)

s3x, s3y = top("s3")
rowtop = by["s4"]["y"] - 45
poly([(s3x, s3y - 4), (s3x, rowtop), (CH, rowtop), (CH, g34)], head=False)
e7x, e7y = rgt("e7")
poly([(e7x + 8, e7y), (CH, e7y), (CH, g34)], head=False)
for src in ("r_rq", "o5"):
    rx, ry = rgt(src)
    poly([(rx + 8, ry), (CH, ry), (CH, g34)], head=False)
qx, qy = top("q0")
poly([(CH, g34), (qx, g34), (qx, qy - 8)])
text("lk_t3", qx + 12, by["band_req"]["y"] + 40, "request(): from lanes 2, 10 and 11")

lx, ly = rgt("l4")
b0x, b0y = lft("b0")
poly([(lx + 8, ly), (CH2, ly), (CH2, g34 + 10), (M2, g34 + 10), (M2, b0y), (b0x - 8, b0y)])
text("lk_t4", M2 + 14, by["b0"]["y"] - 34, "requestBackfill(): from lane 12")

xx, xy = rgt("x8")
q7x, _ = bot("q7")
poly([(xx + 8, xy), (CH3, xy), (CH3, g45), (q7x + 2, g45)], head=False)
text("lk_t5", CH3 - 330, g45 - 22, "requeued by lane 9: back to the queue")

drop = ["s3j", "e7j", "e2j", "s3j-label", "e7j-label", "e2j-label"]
for e in els:
    if e["type"] == "arrow":
        ends = {(e.get("startBinding") or {}).get("elementId"), (e.get("endBinding") or {}).get("elementId")}
        if ends & {"s3j", "e7j", "e2j"}:
            drop.append(e["id"])
            drop += [t["id"] for t in els if t.get("containerId") == e["id"]]

update = [
    {"id": "t1-label", "set": {"text": "split: many languages\nin one call, within\nthe provider's limits",
                                "originalText": "split: many languages\nin one call, within\nthe provider's limits"}},
    {"id": "m5-label", "set": {"text": "7 · Translator: many\nlanguages per call",
                                "originalText": "7 · Translator: many\nlanguages per call"}},
]
json.dump({"create": create, "update": update, "delete": drop}, sys.stdout, ensure_ascii=False)
print(f"create {len(create)}, update {len(update)}, delete {len(drop)}", file=sys.stderr)
