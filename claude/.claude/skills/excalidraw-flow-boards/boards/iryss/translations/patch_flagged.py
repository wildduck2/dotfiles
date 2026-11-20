import json, sys, urllib.request
els = json.load(urllib.request.urlopen("http://127.0.0.1:3100/api/elements"))
els = els.get("elements", els)
by = {e["id"]: e for e in els}
G, F = ["g_translations_full"], "frame_full"
INK, GREEN, GREY = "#1e1e1e", "#2f9e44", "#868e96"
upd, dele, create, touched = {}, set(), [], set()


def cur(i):
    e = dict(by[i]); e.update(upd.get(i, {})); return e


def setf(i, **kw):
    assert i in by, i
    upd.setdefault(i, {}).update(kw)


def label_of(i):
    return next((b["id"] for b in cur(i).get("boundElements") or [] if b["type"] == "text"), None)


def measure(text, fs, bound=True):
    if not bound:
        return round(max(len(l) for l in text.split("\n")) * 0.45 * fs)
    return round(max(sum(0.625 if c.isupper() or c == "_" else 0.465 for c in l) for l in text.split("\n")) * fs)


def relabel(i, text):
    lid = label_of(i); t = by[lid]
    setf(lid, text=text, originalText=text, width=measure(text, t["fontSize"]),
         height=len(text.split("\n")) * t["fontSize"] * t["lineHeight"])
    touched.add(i)


def note(i, text):
    t = by[i]
    setf(i, text=text, originalText=text, width=measure(text, t["fontSize"], False),
         height=round(len(text.split("\n")) * t["fontSize"] * t["lineHeight"], 2))


def box(i, x=None, y=None, w=None, h=None):
    e = cur(i)
    setf(i, x=e["x"] if x is None else x, y=e["y"] if y is None else y,
         width=e["width"] if w is None else w, height=e["height"] if h is None else h)
    touched.add(i)


def move(i, dx=0, dy=0):
    e = cur(i); setf(i, x=e["x"] + dx, y=e["y"] + dy)
    if e["type"] != "arrow" and e["type"] != "text": touched.add(i)
    if e["type"] == "arrow":
        lid = label_of(i)
        if lid:
            t = cur(lid); setf(lid, x=t["x"] + dx, y=t["y"] + dy)


def fp(i, side):
    e = cur(i); w, h = e["width"], e["height"]
    return {"left": [-8 / w, 0.5001], "right": [1 + 8 / w, 0.5001], "top": [0.5001, -8 / h], "bottom": [0.5001, 1 + 8 / h]}[side]


def arrow(i, x, y, pts, start=None, end=None):
    kw = dict(x=x, y=y, points=pts, width=max(abs(p[0]) for p in pts), height=max(abs(p[1]) for p in pts))
    if start: kw["startBinding"] = {"elementId": start[0], "mode": "orbit", "fixedPoint": fp(*start)}
    if end: kw["endBinding"] = {"elementId": end[0], "mode": "orbit", "fixedPoint": fp(*end)}
    setf(i, **kw)
    lid = label_of(i)
    if lid:
        t = cur(lid); mx, my = x + (pts[0][0] + pts[-1][0]) / 2, y + (pts[0][1] + pts[-1][1]) / 2
        setf(lid, x=mx - t["width"] / 2, y=my - t["height"] / 2)


def drop(*ids):
    for i in ids:
        if i not in by: continue
        dele.add(i)
        lid = label_of(i)
        if lid: dele.add(lid)
        if "al_" + i in by: dele.add("al_" + i)
        if by[i]["type"] != "arrow":
            for e in els:
                if e["type"] == "arrow" and i in ((e.get("startBinding") or {}).get("elementId"), (e.get("endBinding") or {}).get("elementId")):
                    drop(e["id"])


def shape(i, kind, x, y, w, h, text, bg="#ffffff", stroke=INK):
    create.append({"id": i, "type": kind, "x": x, "y": y, "width": w, "height": h, "text": text, "fontSize": 20,
                   "fontFamily": 5, "strokeColor": stroke, "backgroundColor": bg, "fillStyle": "solid", "strokeWidth": 2,
                   "roughness": 0, "roundness": None, "groupIds": G, "locked": True, "frameId": F})


def new_arrow(i, x, y, pts, stroke=INK, head=True, start=None, end=None):
    el = {"id": i, "type": "arrow", "x": x, "y": y, "points": pts, "strokeColor": stroke, "strokeWidth": 2,
          "roughness": 0, "groupIds": G, "locked": True, "frameId": F, "endArrowhead": "arrow" if head else None}
    if start: el["startBinding"] = {"elementId": start[0], "mode": "orbit", "fixedPoint": start[1]}
    if end: el["endBinding"] = {"elementId": end[0], "mode": "orbit", "fixedPoint": end[1]}
    create.append(el)


def word(i, x, y, s):
    create.append({"id": i, "type": "text", "x": x, "y": y, "width": round(len(s) * 16 * 0.58) + 4, "height": 20,
                   "text": s, "fontSize": 16, "fontFamily": "helvetica", "strokeColor": INK, "groupIds": G,
                   "locked": True, "frameId": F})


def dfp(w, h, side):
    return {"left": [-8 / w, 0.5001], "right": [1 + 8 / w, 0.5001], "top": [0.5001, -8 / h], "bottom": [0.5001, 1 + 8 / h]}[side]


# ============================================================================
# Header and map
# ============================================================================
note("doc_sub", by["doc_sub"]["text"].replace("each answer, review, and", "each answer, flagged words, and"))
note("api_n", by["api_n"]["text"].replace("lanes 2, 3, 10, 11 and 12", "lanes 2, 3, 11 and 12"))
relabel("m6", "8 · each answer:\nlive, or flagged")
box("m8", x=3757, w=214); relabel("m8", "10 · flagged words\nwait for a person")
arrow("muymyb14bh1f6oil1rf", 3645, -4124, [[0, 0], [104, 0]], ("m7", "right"), ("m8", "left"))
arrow("muymyb14pyv6y8zhc2t", 3979, -4124, [[0, 0], [110, 0]], ("m8", "right"), ("m9", "left"))
relabel("m_retry", "11 · a person\nretries an\noperation")

# ============================================================================
# Lane 3: a person's words
# ============================================================================
drop("p3", "p4")
D3 = -668
for i in ("p5", "p6", "p6r", "p7", "p8", "p7n", "al_muymyb151h6ctf397oe", "muymyb151bi7cm0yuym",
          "muymyb151h6ctf397oe", "muymyb15zwfez5fu0qc", "muymyb15h3euvj5embd"):
    move(i, D3)
arrow("muymyb154sp8u0gs0ur", cur("muymyb154sp8u0gs0ur")["x"], cur("muymyb154sp8u0gs0ur")["y"], [[0, 0], [109, 0]],
      ("p2", "right"), ("p5", "left"))
setf("muymyb15jgks9hucgrq", points=[[0, 0], [0, 62], [692, 62], [692, -25]], width=692)
relabel("p5", "translation_\nmemory:\nupserted")
note("p2n", "no: an empty field records nothing, and the engine translates it later")
note("p7n", "A person's words stand until the source text\nchanges, and replace the engine's in memory.")

# ============================================================================
# Lane 4: queue an operation
# ============================================================================
drop("q3", "q4")
move("q5", 2066 - by["q5"]["x"])
a = cur("muymyb1574de9gx4vxi")
arrow("muymyb1574de9gx4vxi", a["x"], a["y"], [[0, 0], [111, 0]], ("q2", "right"), ("q5", "left"))
arrow("muymyb1512evylmz97t", 2066 + 242 + 8, -1239, [[0, 0], [867.5, 0], [867.5, 86]], ("q5", "right"), ("q6", "top"))
relabel("q0", "request(): from 2\n(source_changed),\n11 (retry)")
note("lk_t3", "request(): from lanes 2 and 11")

# ============================================================================
# Lane 6: a run
# ============================================================================
drop("u7", "u8")
arrow("muymyb15s9d9fl8az9r", 3183.5, 390, [[0, 0], [0, 87], [-2244.5, 87], [-2244.5, 267], [-2151.5, 267]])
relabel("v1", "a hit is written\nas it is, without\nthe checks")
lines = by["run_n"]["text"].split("\n")
note("run_n", "\n".join(lines[:2] + ["Memory holds only words a person typed or the checks passed."]))

# ============================================================================
# Lane 7: provider failures
# ============================================================================
f4 = cur("f4"); box("f4", y=f4["y"] + 12.5, h=109)
relabel("f4", "blocked (safety): no\ntext; the pair goes\nto errors (lane 10)")

# ============================================================================
# Lane 8: each answer
# ============================================================================
drop("n4", "n4r")
drop("muymyb15hi47byvdxuk")
for i, dx in (("n1", 296), ("n2", 301), ("n2r", 301), ("muymyb157veyyhjumme", 301), ("al_muymyb157veyyhjumme", 301),
              ("n3", 313), ("n3r", 313), ("muymyb15vmso0xn1brc", 313), ("al_muymyb15vmso0xn1brc", 313)):
    move(i, dx)
NF = (1345, 2374.5, 220, 130)
shape("nf", "diamond", *NF, "flagged or\nfailed?")
shape("nfr", "rectangle", 1330, 2170, 250, 134, "operation errors:\nWORDS_FLAGGED with\nissues + text, or the\nprovider's code")
arrow("muymyb15u70bhauirwc", 1261, 2439.5, [[0, 0], [76, 0]], ("n0", "right"))
setf("muymyb15u70bhauirwc", endBinding={"elementId": "nf", "mode": "orbit", "fixedPoint": dfp(220, 130, "left")})
new_arrow("a_nf_n1", 1573, 2439.5, [[0, 0], [74, 0]], start=("nf", dfp(220, 130, "right")), end=("n1", fp("n1", "left")))
word("al_a_nf_n1", 1599, 2414, "no")
new_arrow("a_nf_nfr", 1455, 2366.5, [[0, 0], [0, -54.5]], start=("nf", dfp(220, 130, "top")), end=("nfr", dfp(250, 134, "bottom")))
word("al_a_nf_nfr", 1463, 2330, "yes")
arrow("muymyb15iyzgkwabof", 1913, 2440, [[0, 0], [74, 0]], ("n1", "right"), ("n2", "left"))
arrow("muymyb15g0elhyj6z0m", 2263, 2439, [[0, 0], [74, 0]], ("n2", "right"), ("n3", "left"))
arrow("muymyb15xqdfyvr2esa", 2618, 2439, [[0, 0], [89, 0]], ("n3", "right"), ("n5", "left"))
relabel("n0", "outcomes of one\ncall (or the\nmemory hits)")
relabel("n1", "lock sources + owner;\nre-read sources\nand targets")
n2r = cur("n2r"); box("n2r", x=n2r["x"] - 10, y=n2r["y"] - 7, w=200, h=84); relabel("n2r", "dropped: the\nsource moved on")
relabel("n3r", "skipped: already\nwritten")
box("n5r", x=2739, w=210); relabel("n5r", "errors:\nWORDS_WAITING")
relabel("n6", "write the owner row\n(machine): live now")
relabel("n7", "translation_\nmemory learns\nthem, never over\nan entry")
note("ans_n", "No review: words that pass the checks go live at once, as machine words. Memory hits skip the checks.\n"
     "A flagged pair, a failed one and a waiting one go only on translation_operations.errors, never on the owner row (lane 10).\n"
     "An emptied source field clears the target.")

# ============================================================================
# Lane 9: the run ends
# ============================================================================
note("cn_x8", "failures wait on the operation for a person")
setf("cn_x8", x=3864 - 8 - measure("failures wait on the operation for a person", 15, False))

# ============================================================================
# Lane 10: flagged words
# ============================================================================
drop("r_2", "r_3", "r_3r", "r_4", "r_4r", "r_5", "r_5r", "r_6", "r_ap", "r_ed", "r_rj", "r_rt", "r_acc", "r_ok", "r_kept",
     "r_rq", "lk_8", "muymyb15ox09m9c4w7", "muymyb15dv0ge30kq7v", "muymyb15ajuydd4h0s7", "muymyb15wcd1c9svtic")
note("title_rev", "10 · Flagged words")
note("sub_rev", "on the operation,\nnever on the row;\nread in lane 11")
note("rev_n", "Nothing a check flagged reaches the owner row, so no storefront serves it. Until it is settled,\n"
     "GET status counts the owner missing or stale in that language, and a missing row holds back\n"
     "lane 12's go-live. A retry or a new source can be flagged again.")
setf("rev_n", y=4000)
box("r_0", y=3803.5, w=200, h=109); relabel("r_0", "an operation ends\nwith exceptions or\nfailed (lane 9)")
box("r_1", y=3803.5, h=109); relabel("r_1", "errors: a code per\nlanguage and field\nleft without words")
arrow("muymyb15t5vzdmivbps", 1262, 3858, [[0, 0], [106, 0]], ("r_0", "right"), ("r_1", "left"))
shape("fl_code", "diamond", 1708, 3793, 200, 130, "which\ncode?")
arrow("muymyb15uyob4ipgzr", 1600, 3858, [[0, 0], [100, 0]], ("r_1", "right"))
setf("muymyb15uyob4ipgzr", endBinding={"elementId": "fl_code", "mode": "orbit", "fixedPoint": dfp(200, 130, "left")})
ROWS = (3640, 3803, 3966)
shape("fl_flag", "rectangle", 2034, ROWS[0], 250, 109, "WORDS_FLAGGED: the\nissues + the words\nthat came back")
shape("fl_wait", "rectangle", 2034, ROWS[1], 250, 109, "WORDS_WAITING: a\nrequired field has\nnot landed")
shape("fl_prov", "rectangle", 2034, ROWS[2], 250, 109, "a provider code:\nblocked, refused or\nout of retries")
shape("fl_who", "diamond", 2404, 3793, 200, 130, "settled\nhow?")
shape("fl_type", "rectangle", 2714, ROWS[0], 260, 109, "a person types the\nwords (lane 3): live\nat once, memory learns")
shape("fl_retry", "rectangle", 2714, ROWS[1], 260, 109, "retry (lane 11): a\nnew operation asks\nthe provider again")
shape("fl_src", "rectangle", 2714, ROWS[2], 260, 109, "the source changes\n(lane 2): a new\noperation runs")
shape("fl_ok", "rectangle", 3094, 3803.5, 230, 109, "the pair has words;\nstatus counts it\ncurrent", bg="#ebfbee", stroke=GREEN)
for n, dy in (("flag", -163.5), ("wait", 0), ("prov", 162.5)):
    pts = [[0, 0], [110, 0]] if dy == 0 else [[0, 0], [59, 0], [59, dy], [110, dy]]
    new_arrow(f"a_code_{n}", 1916, 3858, pts)
    pts = [[0, 0], [104, 0]] if dy == 0 else [[0, 0], [52, 0], [52, -dy]]
    new_arrow(f"a_{n}_who", 2292, 3858 + dy, pts, head=dy == 0)
for n, dy in (("type", -163.5), ("retry", 0), ("src", 162.5)):
    pts = [[0, 0], [94, 0]] if dy == 0 else [[0, 0], [51, 0], [51, dy], [94, dy]]
    new_arrow(f"a_who_{n}", 2612, 3858, pts)
    pts = [[0, 0], [104, 0]] if dy == 0 else [[0, 0], [52, 0], [52, -dy]]
    new_arrow(f"a_{n}_ok", 2982, 3858 + dy, pts, stroke=GREEN, head=dy == 0)

# ============================================================================
# Lane 11: watching
# ============================================================================
drop("o9", "o10", "o10r", "o11")
dele.add("ops_n")
note("title_ops", "11 · Watching")
box("o7", y=4770.5, h=109); relabel("o7", "per owner type ×\nlanguage: current,\nstale, missing")

# ============================================================================
# Labels, bindings, output
# ============================================================================
for i in touched:
    lid = label_of(i)
    if not lid: continue
    e, t = cur(i), cur(lid)
    setf(lid, x=e["x"] + e["width"] / 2 - t["width"] / 2, y=e["y"] + e["height"] / 2 - t["height"] / 2)

for i in ("muymyb15uyob4ipgzr", "muymyb154sp8u0gs0ur", "muymyb1574de9gx4vxi", "muymyb15xqdfyvr2esa"):
    dele.discard(i); dele.discard(i + "-label")

bound = {}
for e in [cur(x["id"]) for x in els if x["id"] not in dele and x["type"] == "arrow"] + [c for c in create if c["type"] == "arrow"]:
    for k in ("startBinding", "endBinding"):
        t = (e.get(k) or {}).get("elementId")
        if t: bound.setdefault(t, set()).add(e["id"])
for e in els:
    if e["id"] in dele: continue
    old = e.get("boundElements") or []
    keep = [b for b in old if b["id"] not in dele and (b["type"] == "text" or b["id"] in bound.get(e["id"], set()))]
    have = {b["id"] for b in keep}
    keep += [{"id": a, "type": "arrow"} for a in sorted(bound.get(e["id"], set())) if a not in have]
    if keep != old: setf(e["id"], boundElements=keep)

missing = [i for i in dele if i not in by]
assert not missing, missing
json.dump({"create": create, "update": [{"id": i, "set": s} for i, s in upd.items()], "delete": sorted(dele)},
          open(sys.argv[1], "w"))
print("create", len(create), "update", len(upd), "delete", len(dele), file=sys.stderr)
print(sorted(dele), file=sys.stderr)
