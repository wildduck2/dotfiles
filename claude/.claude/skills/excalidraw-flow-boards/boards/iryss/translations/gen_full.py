import json
import sys

PITCH = 340
CX0 = 430
MARGIN_X = 225
NCOL = 10
BAND_W = CX0 + PITCH * (NCOL - 1) + 230
GAP = 40


def cx(i):
    return CX0 + PITCH * i


def char_w(c):
    if c in "iljtfr.,:;'|!()[]{} ":
        return 6.5
    if c.isupper() or c in "_@#%&mwMW→×·<>=+≤≠":
        return 14
    if c.isdigit():
        return 12
    return 11


def line_w(s):
    return sum(char_w(c) for c in s)


def size(kind, text):
    lines = text.split("\n")
    lw = max(line_w(s) for s in lines)
    n = len(lines)
    if kind == "rectangle":
        return max(180, lw + 44), max(70, n * 25 + 34)
    if kind == "diamond":
        return max(200, lw * 2 + 50), max(120, n * 50 + 30)
    return max(200, lw * 1.45 + 56), max(80, n * 25 * 1.45 + 40)


INK = "#1e1e1e"
RED = "#e03131"
GREEN = "#2f9e44"
GRAY = "#868e96"
PAL = {
    "plain": ("#ffffff", INK),
    "table": ("#f1f3f5", INK),
    "red": ("#fff5f5", RED),
    "ok": ("#ebfbee", GREEN),
    "gray": ("#ffffff", GRAY),
    "jump": ("#ffffff", "#495057"),
}

bands, shapes, texts, arrows = [], [], [], []
geo = {}
lane_top = {}
lane_idx = 0
cur = {}


def node(id, kind, x, y, text, pal="plain", **extra):
    w, h = size(kind, text)
    w = extra.pop("w", w)
    h = extra.pop("h", h)
    bg, st = PAL[pal]
    geo[id] = (x, y, w, h)
    if w > PITCH - 36 and not extra.pop("wide", False):
        print(f"warn: {id} is {w:.0f} wide", file=sys.stderr)
    if pal == "jump":
        extra.setdefault("strokeStyle", "dashed")
    shapes.append({
        "id": id, "type": kind, "x": round(x - w / 2), "y": round(y - h / 2),
        "width": round(w), "height": round(h), "text": text,
        "backgroundColor": bg, "strokeColor": st, "fillStyle": "solid", "roughness": 0, **extra,
    })


def box(id, x, y, text, pal="plain", **extra):
    node(id, "rectangle", x, y, text, pal, **extra)


def dia(id, x, y, text, **extra):
    node(id, "diamond", x, y, text, "plain", **extra)


def table(id, x, y, text, **extra):
    node(id, "ellipse", x, y, text, "table", **extra)


def jump(id, x, y, text):
    node(id, "ellipse", x, y, text, "jump")


def note(id, x, y, text, size=18, color="#495057"):
    lines = text.split("\n")
    texts.append({
        "id": id, "type": "text", "x": round(x), "y": round(y),
        "width": round(max(len(s) for s in lines) * size * 0.5), "height": round(len(lines) * size * 1.3),
        "text": text, "fontSize": size, "fontFamily": "helvetica", "strokeColor": color,
    })


def arrow(a, b, color=INK, label=None, dashed=False):
    el = {"type": "arrow", "x": 0, "y": 0, "startElementId": a, "endElementId": b, "strokeColor": color, "roughness": 0}
    if label:
        el["text"] = label
    if dashed:
        el["strokeStyle"] = "dashed"
    arrows.append(el)


def chain(ids, color=INK):
    for a, b in zip(ids, ids[1:]):
        arrow(a, b, color)


def poly(points, color=INK, dashed=False, head=True):
    x0, y0 = points[0]
    el = {
        "type": "arrow", "x": round(x0), "y": round(y0), "points": [[round(x - x0), round(y - y0)] for x, y in points],
        "strokeColor": color, "strokeWidth": 2, "roughness": 0,
    }
    if not head:
        el["endArrowhead"] = None
    if dashed:
        el["strokeStyle"] = "dashed"
    arrows.append(el)


def top(id):
    x, y, w, h = geo[id]
    return x, y - h / 2


def bottom(id):
    x, y, w, h = geo[id]
    return x, y + h / 2


def left(id):
    x, y, w, h = geo[id]
    return x - w / 2, y


def right(id):
    x, y, w, h = geo[id]
    return x + w / 2, y


def up(src, dst, color=RED, label=None, dashed=False):
    arrow(src, dst, color, label, dashed)


def fan_right(src, dsts, color=INK):
    sx, sy, sw, sh = geo[src]
    bus = sx + sw / 2 + 50
    for d in dsts:
        dx, dy, dw, dh = geo[d]
        poly([(sx + sw / 2 + 4, sy), (bus, sy), (bus, dy), (dx - dw / 2 - 8, dy)], color)


def collect_up(srcs, dst, bus_y, color=INK):
    dx, dy = top(dst)
    for s in srcs:
        sx, sy = top(s)
        poly([(sx, sy - 4), (sx, bus_y), (dx, bus_y), (dx, dy - 8)], color, dashed=True)


def start_lane(key, title, sub):
    global lane_idx
    T = cur.get("next", 200)
    lane_top[key] = T
    cur.update(key=key, T=T, title=title, sub=sub, s=len(shapes), t=len(texts), a=len(arrows))
    return T


def end_lane():
    global lane_idx
    T = cur["T"]
    low = T + 120
    for el in shapes[cur["s"]:] + texts[cur["t"]:]:
        low = max(low, el["y"] + el["height"])
    for el in arrows[cur["a"]:]:
        if "points" in el:
            low = max(low, max(el["y"] + p[1] for p in el["points"]))
    height = low - T + 60
    bg = "#f8f9fa" if lane_idx % 2 == 0 else "#ffffff"
    lane_idx += 1
    bands.append({
        "id": f"band_{cur['key']}", "type": "rectangle", "x": 0, "y": T, "width": BAND_W, "height": round(height),
        "backgroundColor": bg, "strokeColor": "#dee2e6", "fillStyle": "solid", "roughness": 0, "strokeWidth": 1,
    })
    texts.append({
        "id": f"title_{cur['key']}", "type": "text", "x": 20, "y": T + 14, "width": 190,
        "height": 28 * (cur["title"].count("\n") + 1),
        "text": cur["title"], "fontSize": 22, "fontFamily": "helvetica", "strokeColor": INK,
    })
    note(f"sub_{cur['key']}", 20, T + 20 + 28 * (cur["title"].count("\n") + 1), cur["sub"], size=14)
    cur["next"] = T + round(height) + GAP


def connect(src, dst, label=None, edge=False):
    sx, sy = bottom(src)
    dx, dy = left(dst)
    gap_y = next(lane_top[k] for k in lane_order if lane_top[k] > sy) - GAP / 2
    if edge:
        rx, ry = right(src)
        sx = BAND_W - 30
        poly([(rx + 8, ry), (sx, ry), (sx, gap_y), (MARGIN_X, gap_y), (MARGIN_X, dy), (dx - 8, dy)])
    else:
        poly([(sx, sy + 8), (sx, gap_y), (MARGIN_X, gap_y), (MARGIN_X, dy), (dx - 8, dy)])
    if label:
        note(f"cn_{src}", sx - 8 - len(label) * 7.5, gap_y - 22, label, size=15, color=INK)


lane_order = []


def lane(key, title, sub):
    lane_order.append(key)
    return start_lane(key, title, sub)


# =============================================================================
# 0 The map
# =============================================================================

T = lane("map", "0 · The map", "each box is a lane below")
y1, y2 = T + 120, T + 300
steps = [
    ("m0", "1 · an admin call:\nhost, auth, IAM, body"),
    ("m1", "2 · English source\ncreated or edited"),
    ("m2", "4 · one operation\nqueued per owner"),
    ("m3", "5 · BullMQ wakes\na worker"),
    ("m4", "6 · run: the pairs\nthat need words,\nmemory first"),
    ("m5", "7 · Translator calls\nthe provider"),
    ("m6", "8 · each answer:\naccepted or review"),
    ("m7", "9 · run ends: done,\nrequeued or failed"),
    ("m8", "10 · a person\nreviews"),
    ("m9", "12 · the language\ngoes live"),
]
for i, (id, text) in enumerate(steps):
    box(id, cx(i), y1, text)
chain([id for id, _ in steps])
box("m_person", cx(1), y2, "3 · a person types\na language's words:\nlive at once, no run")
box("m_backfill", cx(2), y2, "12 · a language\nmoves to backfilling")
box("m_retry", cx(3), y2, "10, 11 · a person\nretries a result\nor an operation")
box("m_sweep", cx(4), y2, "5 · sweep every 30s:\nlost jobs, dead runs")
arrow("m0", "m_person")
arrow("m_backfill", "m2")
arrow("m_retry", "m2")
arrow("m_sweep", "m3")
end_lane()

# =============================================================================
# 1 Every admin call
# =============================================================================

T = lane("api", "1 · Every admin call", "marketplace-api\n(NestJS)")
ty, my = T + 100, T + 330
box("a0", cx(0), my, "helmet, trust proxy,\nrequest id + log")
dia("a1", cx(1), my, "host\nknown?")
dia("a2", cx(2), my, "signed\nin?")
dia("a3", cx(3), my, "IAM\nallows?")
dia("a4", cx(4), my, "body\nvalid?")
box("a5", cx(5), my, "controller\n(nestia route)")
box("a6", cx(6), my, "service method\n@Throws")
box("a7", cx(7), my, "200 {ok, code, data}\n<CODE>_SUCCEEDED", "ok")
box("r1", cx(1), ty, "404\nHOST_NOT_\nREGISTERED", "red")
box("r2", cx(2), ty, "401\nAUTH_\nUNAUTHENTICATED", "red")
box("r3", cx(3), ty, "403\nIAM_FORBIDDEN", "red")
box("r4", cx(4), ty, "400\nbody rejected\nby typia", "red")
box("r6", cx(6), ty, "error filter →\n{ok: false, code}", "red")
box("r7", cx(7), ty, "the caller reads\nthe code", "red")
for a, b, lab in [("a0", "a1", None), ("a1", "a2", "yes"), ("a2", "a3", "yes"), ("a3", "a4", "yes"), ("a4", "a5", "yes"),
                  ("a5", "a6", None), ("a6", "a7", None)]:
    arrow(a, b, INK, lab)
for i in range(1, 5):
    up(f"a{i}", f"r{i}", RED, "no")
for a, b in [("r1", "r2"), ("r2", "r3"), ("r3", "r4"), ("r4", "r6"), ("r6", "r7")]:
    arrow(a, b, RED, dashed=True)
up("a6", "r6", RED, "throws", dashed=True)
note("api_n", cx(0) - 140, my + 100,
     "Every route in lanes 2, 3, 10, 11 and 12 runs this first. Translations writes are held at the company scope "
     "(IAM resource translations).")
end_lane()

# =============================================================================
# 2 Source writes
# =============================================================================

T = lane("src", "2 · Source writes", "the English text\nis created or edited")
ya = T + 250
box("s_def", cx(0), ya - 110, "POST /admin/\nattributeDefinitions")
box("s_opt", cx(0), ya, "POST …/:id/options")
box("s_cat", cx(0), ya + 110, "POST /admin/categories")
box("s1", cx(1), ya, "one transaction:\ninsert the owner row")
box("s1r", cx(1), ya - 150, "options only: not an\noption definition →\n422 NOT_OPTION_TYPE", "red")
box("s2", cx(2), ya, "insert the en source\nrow: isSource, a\nhash per field")
box("s3", cx(3), ya, "request(tx,\nsource_changed)")
jump("s3j", cx(3), ya - 150, "to 4 · request()")
box("s4", cx(4), ya, "read the row back\n(option: emits\noption_added)")
box("s5", cx(5), ya, "200, saved in\nEnglish only", "ok")
for s in ("s_def", "s_opt", "s_cat"):
    arrow(s, "s1")
up("s1", "s1r", RED)
chain(["s1", "s2", "s3", "s4", "s5"])
arrow("s3", "s3j", INK, dashed=True)

yb, yr = T + 680, T + 530
box("e0", cx(0), yb, "PUT …/translations/\n:localeCode\n(definition, option\nor category)")
dia("e1", cx(1), yb, "language\ntakes words?")
box("e1r", cx(1), yr, "404 *_LOCALE_\nNOT_FOUND", "red")
dia("e2", cx(2), yb, "row is the\nsource?")
jump("e2j", cx(2), yb + 190, "to 3 · own words")
box("e3", cx(3), yb, "lock the source\nrow for update")
dia("e4", cx(4), yb, "version\nmatches?")
box("e4r", cx(4), yr, "409 *_TRANSLATION_\nCHANGED", "red")
box("e5", cx(5), yb, "write the text, new\nhashes, version + 1")
dia("e6", cx(6), yb, "a field's hash\nmoved?")
box("e6n", cx(6), yb + 190, "saved;\nnothing queued", "gray")
box("e7", cx(7), yb, "request(tx,\nsource_changed);\na definition also\nemits definition_\nchanged")
jump("e7j", cx(8), yb, "to 4 · request()")
arrow("e0", "e1")
arrow("e1", "e2", INK, "yes")
up("e1", "e1r", RED, "no")
arrow("e2", "e3", INK, "yes")
arrow("e2", "e2j", INK, "no")
arrow("e3", "e4")
arrow("e4", "e5", INK, "yes")
up("e4", "e4r", RED, "no")
arrow("e5", "e6")
arrow("e6", "e7", INK, "yes")
arrow("e6", "e6n", GRAY, "no")
arrow("e7", "e7j", INK, dashed=True)
note("src_n", cx(3) - 140, yb + 160,
     "PATCH on a definition or an option (code, type, flags,\nposition) touches no words and queues nothing.")
end_lane()

# =============================================================================
# 3 A person's own words
# =============================================================================

T = lane("man", "3 · A person's words", "a target language\ntyped by hand")
ya, yr = T + 240, T + 90
box("p0", cx(0), ya, "from 2: a PUT on a\nrow that is not the\nsource")
box("p1", cx(1), ya, "recordManual(tx):\nlock sources, owner\nlock (update)")
dia("p2", cx(2), ya, "field has\ntext and a\nsource?")
box("p3", cx(3), ya, "open reviews for\nthose fields →\nsuperseded")
table("p4", cx(4), ya, "translation_\nresults: human,\naccepted, manual")
table("p5", cx(5), ya, "translation_\nmemory:\nreviewed")
dia("p6", cx(6), ya, "version\nmatches?")
box("p6r", cx(6), yr, "409 *_TRANSLATION_\nCHANGED", "red")
box("p7", cx(7), ya, "write the target row,\nsource: human,\nversion + 1")
box("p8", cx(8), ya, "200: live in that\nlanguage now", "ok")
chain(["p0", "p1", "p2"])
arrow("p2", "p3", INK, "yes")
chain(["p3", "p4", "p5", "p6"])
up("p6", "p6r", RED, "no")
arrow("p6", "p7", INK, "yes")
arrow("p7", "p8", GREEN)
bx, by = bottom("p2")
ex, ey = bottom("p6")
low = T + 400
poly([(bx, by + 8), (bx, low), (ex, low), (ex, ey + 8)])
note("p2n", cx(2) + 30, low + 8, "no: an empty field records nothing, and the engine proposes it later", size=16)
note("p7n", cx(7) - 140, ya + 90, "A human-written target sends any later\nengine words for it to review.")

yb, yr = T + 680, T + 530
box("d0", cx(0), yb, "DELETE …/translations/\n:localeCode")
dia("d1", cx(1), yb, "is the\nsource?")
box("d1r", cx(1), yr, "409 *_TRANSLATION_\nIS_SOURCE", "red")
dia("d2", cx(2), yb, "language\nactive?")
box("d2r", cx(2), yr, "409 *_TRANSLATION_\nLOCALE_ACTIVE", "red")
box("d3", cx(3), yb, "row deleted; status\nshows it missing", "gray")
arrow("d0", "d1")
up("d1", "d1r", RED, "yes")
arrow("d1", "d2", INK, "no")
up("d2", "d2r", RED, "yes")
arrow("d2", "d3", GRAY, "no")
end_lane()

# =============================================================================
# 4 Queue an operation
# =============================================================================

T = lane("req", "4 · Queue an operation", "TranslationsService,\ninside the caller's\ntransaction")
ya, ym, yb = T + 140, T + 290, T + 440
box("q0", cx(0), ya, "request(): from 2\n(source_changed),\n10 + 11 (retry)")
box("q1", cx(1), ya, "share-lock every\nlocale row")
box("q2", cx(2), ya, "owner advisory lock\n(share)")
box("q3", cx(3), ya, "read the owner's\nsource hashes")
box("q4", cx(4), ya, "open reviews whose\nsource moved →\nstale")
box("q5", cx(5), ya, "upsert the owner's\none queued operation")
table("q6", cx(6), ym, "translation_\noperations")
box("q7", cx(7), ym, "after commit:\nqueue.add(ops)")
chain(["q0", "q1", "q2", "q3", "q4", "q5", "q6", "q7"])
box("b0", cx(0), yb, "requestBackfill():\nfrom 12, a language\nmoves to backfilling")
box("b1", cx(1), yb, "backfill lock\n(update)")
box("b2", cx(2), yb, "each owner type:\nowners with no row in\nthis language")
box("b3", cx(3), yb, "in chunks of 1,000")
box("b4", cx(4), yb, "upsert, reason\nlocale_enabled; an\nedit's queued one\nkeeps its reason")
chain(["b0", "b1", "b2", "b3", "b4", "q6"])
note("req_n", cx(0) - 140, yb + 110,
     "Every locale row is locked, not only active ones, so a language moving to backfilling cannot miss this owner.\n"
     "uq_translation_operations_owner_queued: one queued operation per owner. A second request resets its reason, "
     "attempts and due time.\nSo an owner has at most one queued and one running operation.")
end_lane()

# =============================================================================
# 5 BullMQ
# =============================================================================

T = lane("q", "5 · BullMQ wakes\na worker", "Valkey; every process\nadds jobs, one runs\nthem")
ys, yr, ya = T + 120, T + 300, T + 470
box("w0", cx(0), ys, "job scheduler:\nevery 30s")
box("w1", cx(1), ys, "queue\n\"translations-sweep\"\n(a 429 never\npauses it)")
box("w2", cx(2), ys, "sweep(),\none at a time")
box("w3", cx(3), ys, "queued, due, idle:\nedits + retries first,\nthen backfill, ≤ 500")
box("w4", cx(4), ys, "expired leases:\nreclaim, end as\nstopped (→ 9)")
chain(["w0", "w1", "w2", "w3", "w4"])
box("k0", cx(0), ya, "queue.add: a job per\noperation, id = op +\ndue time, 1 try")
box("k1", cx(1), ya, "delay until due;\npriority 1 edit or\nretry, 10 backfill")
box("k2", cx(2), ya, "queue \"translations\"")
dia("k3", cx(3), ya, "process runs\nworkers?")
box("k3r", cx(3), yr, "TRANSLATION_\nWORKER=false:\nonly adds jobs", "gray")
box("k4", cx(4), ya, "TranslationsProcessor\nconcurrency 2")
box("k5", cx(5), ya, "runner.run(op,\nshutdown signal)")
dia("k6", cx(6), ya, "rate\nlimited?")
box("k6r", cx(6), yr, "queue.rateLimit(ms):\nthe whole queue\npauses", "gray")
box("k7", cx(7), ya, "job removed\n(done or failed)", "gray")
chain(["k0", "k1", "k2", "k3"])
arrow("k3", "k4", INK, "yes")
up("k3", "k3r", GRAY, "no")
chain(["k4", "k5", "k6"])
up("k6", "k6r", GRAY, "yes")
arrow("k6", "k7", GRAY, "no")
sx, sy = bottom("w3")
kx, ky = top("k0")
poly([(sx, sy + 8), (sx, T + 215), (kx, T + 215), (kx, ky - 8)])
note("w3n", cx(1) - 60, T + 222, "re-adds lost jobs", size=16)
note("q_n", cx(0) - 140, ya + 100,
     "Shutdown aborts the run before the worker closes. A run that throws\nis only logged; its lease lets the sweep "
     "reclaim it.")
end_lane()

# =============================================================================
# 6 A run
# =============================================================================

T = lane("run", "6 · A run", "TranslationRunner:\nclaim, then work out\nwhat is needed")
ya, yr = T + 270, T + 100
box("u0", cx(0), ya, "run(operationId)")
dia("u1", cx(1), ya, "queued,\ndue, idle?")
box("u1r", cx(1), yr, "nothing to claim:\njob dropped", "gray")
box("u2", cx(2), ya, "claim: running,\nlease 5 min,\nrevision stamped")
box("u3", cx(3), ya, "stop 30s + a call's\ntimeout before the\nlease ends")
dia("u4", cx(4), ya, "owner\nexists?")
box("u4r", cx(4), yr, "owner gone:\nobsolete (→ 9)", "gray")
box("u5", cx(5), ya, "source text + every\nlanguage taking words")
box("u6", cx(6), ya, "needed: field ×\nlanguage whose target\nhash ≠ source hash")
box("u7", cx(7), ya, "skip pairs in review,\nor rejected under\nthis revision")
box("u8", cx(8), ya, "attach the reviewer's\nnote from a retry")
arrow("u0", "u1")
up("u1", "u1r", GRAY, "no")
arrow("u1", "u2", INK, "yes")
arrow("u2", "u3")
arrow("u3", "u4")
up("u4", "u4r", GRAY, "no")
arrow("u4", "u5", INK, "yes")
chain(["u5", "u6", "u7", "u8"])
yb = T + 600
dia("v0", cx(0), yb, "in\nmemory?")
box("v1", cx(1), yb, "memory proposal\n(origin memory),\nrun through checks")
box("v2", cx(2), yb, "persisted first, also\nclearing emptied\nsource fields (→ 8)")
box("v3", cx(0), yb + 200, "misses go to the\nTranslator")
ux, uy = bottom("u8")
vx, vy = left("v0")
poly([(ux, uy + 8), (ux, T + 420), (MARGIN_X, T + 420), (MARGIN_X, vy), (vx - 8, vy)])
arrow("v0", "v1", INK, "yes")
arrow("v1", "v2")
arrow("v0", "v3", INK, "no")
note("run_n", cx(3) - 140, yb - 40,
     "Memory key: source language, target language, context.field\n(for example attribute_option.colour.name) "
     "and the source hash.\nA pair a reviewer sent back skips memory and goes to the\nprovider with the reason.")
end_lane()

# =============================================================================
# 7 Translator and provider
# =============================================================================

T = lane("tr", "7 · Translator\nand provider", "no Postgres here;\na failure is an\noutcome, not a throw")
ya, yr = T + 280, T + 100
box("t0", cx(0), ya, "pairs the memory\ndid not have")
box("t1", cx(1), ya, "split: the same groups\nevery time, within\nthe provider's limits")
box("t2", cx(2), ya, "pool: ≤ 4 calls at\nonce; the next starts\nas one is taken")
box("t3", cx(3), ya, "each call: 60s\ntimeout, up to 3\ntries, jitter 0.5→8s")
box("t4", cx(4), ya, "provider.translate")
dia("t5", cx(5), ya, "answer\nok?")
box("t6", cx(6), ya, "checks: blank,\nprotected term, digits,\nlength, script,\nunchanged")
dia("t7", cx(7), ya, "any\nissues?")
box("t7r", cx(7), yr, "ask once more with\nthe issues as notes;\nkeep the better", "plain")
box("t8", cx(8), ya, "outcomes, call\nby call")
chain(["t0", "t1", "t2", "t3", "t4", "t5"])
arrow("t5", "t6", INK, "yes")
arrow("t6", "t7")
arrow("t7", "t8", INK, "no")
arrow("t7", "t7r", INK, "yes")
arrow("t7r", "t8")
yp = T + 590
box("pv_stub", cx(2), yp, "stub: dev + tests,\nanswers\n'<code>:<text>'")
box("pv_gtx", cx(3), yp, "google-gtx: dev only,\none text + language a\ncall, ≤ 1,800 chars,\nterms masked")
box("pv_gem", cx(4), yp, "gemini: JSON schema\nlanguage → field →\ntext, temperature 0;\n≤ 10 languages,\n20 texts, 24k chars")
tx_, ty_ = bottom("t4")
bus_y = T + 440
for p in ("pv_stub", "pv_gtx", "pv_gem"):
    px, py = top(p)
    poly([(tx_, ty_ + 8), (tx_, bus_y), (px, bus_y), (px, py - 8)])
note("pv_n", cx(0) - 140, bus_y - 60, "TRANSLATION_PROVIDER (env) picks one.\nHTTP goes through @nestjs/axios HttpService.",
     size=16)
yc = T + 900
dia("f0", cx(5), yc, "failure\nkind?")
box("f1", cx(6), yc, "rate limited (429):\nstop the pool; the\nrun requeues, the\nqueue pauses")
box("f2", cx(7), yc, "transient (timeout,\nnetwork, 5xx, bad\nJSON): retried in the\ncall, then requeue")
box("f3", cx(8), yc, "permanent (4xx,\ntruncated, other):\nthat pair fails")
box("f4", cx(9), yc, "blocked (safety):\nno text; review, and\nonly an edit\nsettles it")
arrow("t5", "f0", INK, "no")
fx, fy = bottom("f0")
fbus = yc + 130
for f in ("f1", "f2", "f3", "f4"):
    bx_, by_ = bottom(f)
    poly([(fx, fy + 8), (fx, fbus), (bx_, fbus), (bx_, by_ + 8)])
note("tr_n", cx(0) - 140, yc - 50,
     "429 reads Retry-After, or Google's RetryInfo.\n500, 502, 503, 504, a timeout, a network drop or\nnon-JSON are transient. "
     "Any other status, MAX_TOKENS\nor an unknown error is permanent.\nA truncated answer for several languages is\n"
     "halved by language and asked again.")
end_lane()

# =============================================================================
# 8 Each answer
# =============================================================================

T = lane("ans", "8 · Each answer", "one short transaction\nper settled call")
ya, yr = T + 310, T + 110
box("n0", cx(0), ya, "proposals from one\ncall (or the memory\nhits)")
box("n1", cx(1), ya, "lock sources + owner;\nre-read sources,\ntargets, the dial")
dia("n2", cx(2), ya, "source still\nhas this\ntext?")
box("n2r", cx(2), yr, "saved as stale", "gray")
dia("n3", cx(3), ya, "target\nalready has\nit?")
box("n3r", cx(3), yr, "saved as\nsuperseded", "gray")
dia("n4", cx(4), ya, "needs\nreview?")
table("n4r", cx(4), yr, "translation_\nresults: review")
dia("n5", cx(5), ya, "its row\nexists, or\nlands now?")
box("n5r", cx(5), yr, "review: waiting\nfor its row")
box("n6", cx(6), ya, "accepted: write the\nowner row (machine)", "ok")
table("n7", cx(7), ya, "translation_\nmemory learns\n(never over a\nreviewed entry)")
box("n8", cx(8), ya, "after commit: emit\ntranslation.applied\n(no listener yet)", strokeStyle="dashed")
chain(["n0", "n1", "n2"])
up("n2", "n2r", GRAY, "no")
arrow("n2", "n3", INK, "yes")
up("n3", "n3r", GRAY, "yes")
arrow("n3", "n4", INK, "no")
up("n4", "n4r", INK, "yes")
arrow("n4", "n5", INK, "no")
up("n5", "n5r", INK, "no")
arrow("n5r", "n4r")
arrow("n5", "n6", GREEN, "yes")
chain(["n6", "n7", "n8"])
note("ans_n", cx(0) - 140, ya + 120,
     "Needs review when: a check found an issue · its target was written by a person · the words came from the "
     "provider and the owner is vocabulary\n(definitions, options and categories all are, so always) · otherwise "
     "sampled by the language's dial in translation_policies, default 100%.\nSo today only a clean memory hit is "
     "written without a person. An emptied source field clears the target (accepted, origin source).")
end_lane()

# =============================================================================
# 9 The run ends
# =============================================================================

T = lane("end", "9 · The run ends", "ending(), then one\ntransaction")
ya, yr, bus = T + 360, T + 180, T + 70
box("x0", cx(0), ya, "every call settled,\nor stopped: gone,\nprogress, failures,\nspend")
dia("x1", cx(1), ya, "owner\ngone?")
box("x1r", cx(1), yr, "obsolete", "gray")
dia("x2", cx(2), ya, "rate\nlimited?")
box("x2r", cx(2), yr, "queued after\nRetry-After or 30s;\nthe queue pauses")
dia("x3", cx(3), ya, "stopped or\ntransient?")
box("x3r", cx(3), yr, "attempts + 1 unless\nprogress; 8 → failed;\nelse queued, backoff\ndoubling from 30s,\ncap 1h")
dia("x4", cx(4), ya, "any\nfailures?")
box("x4r", cx(4), yr, "progress →\ncompleted_with_\nexceptions, else\nfailed")
box("x5", cx(5), ya, "completed", "ok")
box("x6", cx(6), ya, "write the status in\none transaction,\nguarded by the lease")
dia("x7", cx(7), ya, "another op\nqueued for\nthis owner?")
box("x7r", cx(7), ya + 210, "it becomes due now (or\nat the backoff) and is\nadded; this run, if it\nwould requeue, is\nobsolete")
box("x8", cx(8), ya, "requeued →\nqueue.add (lane 5);\nelse done")
arrow("x0", "x1")
up("x1", "x1r", GRAY, "yes")
arrow("x1", "x2", INK, "no")
up("x2", "x2r", INK, "yes")
arrow("x2", "x3", INK, "no")
up("x3", "x3r", INK, "yes")
arrow("x3", "x4", INK, "no")
up("x4", "x4r", INK, "yes")
arrow("x4", "x5", GREEN, "no")
arrow("x5", "x6")
collect_up(["x1r", "x2r", "x3r", "x4r"], "x6", bus)
arrow("x6", "x7")
arrow("x7", "x7r", INK, "yes")
arrow("x7", "x8", INK, "no")
note("end_n", cx(0) - 140, ya + 120,
     "The end transaction holds translations.backfill (share), then the owner\nlock, so an edit or a backfill that "
     "queued a sibling is seen.\nA run the sweep reclaimed changes nothing. Calls, memory hits and\ntokens are added "
     "to the operation's usage.")
end_lane()

# =============================================================================
# 10 Review
# =============================================================================

T = lane("rev", "10 · A person reviews", "admin/translations/\nresults; no portal\nscreen yet")
ya, yr = T + 380, T + 180
box("r_0", cx(0), ya, "GET results?\nstate=review")
box("r_1", cx(1), ya, "POST results/:id/\napprove · edit ·\nreject · retry,\nwith version")
box("r_2", cx(2), ya, "lock sources, locale\nrows, owner; the\nresult for update")
dia("r_3", cx(3), ya, "version\nmatches?")
box("r_3r", cx(3), yr, "409 …RESULT_\nCHANGED", "red")
dia("r_4", cx(4), ya, "still in\nreview?")
box("r_4r", cx(4), yr, "409 …RESULT_\nDECIDED", "red")
dia("r_5", cx(5), ya, "source still\nhas this\ntext?")
box("r_5r", cx(5), yr, "409 …RESULT_\nSTALE", "red")
dia("r_6", cx(6), ya, "which\ndecision?")
stack = [
    ("r_ap", ya - 210, "approve: the proposed\nwords (none → 409\nRESULT_EMPTY)"),
    ("r_ed", ya - 70, "edit: the reviewer's\nwords, checked,\nissues kept"),
    ("r_rj", ya + 70, "reject: never proposed\nagain for this source\nand revision"),
    ("r_rt", ya + 210, "retry: superseded,\nthe reason saved"),
]
for id, y, text in stack:
    box(id, cx(7), y, text)
box("r_acc", cx(8), ya - 140, "write the row (edit\nmarks it human); no\nrow and an optional\nfield → 409 WAITING")
box("r_ok", cx(9), ya - 140, "accepted; memory\nreviewed; emit\ntranslation.applied", "ok")
box("r_kept", cx(8), ya + 70, "rejected: the\ncurrent words stay", "gray")
box("r_rq", cx(8), ya + 210, "request(tx, retry) →\nlane 4; the next run\nsends previous words\n+ reason, no memory")
chain(["r_0", "r_1", "r_2", "r_3"])
up("r_3", "r_3r", RED, "no")
arrow("r_3", "r_4", INK, "yes")
up("r_4", "r_4r", RED, "no")
arrow("r_4", "r_5", INK, "yes")
up("r_5", "r_5r", RED, "no")
arrow("r_5", "r_6", INK, "yes")
fan_right("r_6", [id for id, _, _ in stack])
arrow("r_ap", "r_acc")
arrow("r_ed", "r_acc")
arrow("r_acc", "r_ok", GREEN)
arrow("r_rj", "r_kept", GRAY)
arrow("r_rt", "r_rq")
note("rev_n", cx(0) - 140, ya + 150,
     "IAM on translations: read for the GETs · enable for approve\nand edit (they make words live) · disable for "
     "reject ·\nupdate for retry. Writes are held at the company scope.")
end_lane()

# =============================================================================
# 11 Watching and the dial
# =============================================================================

T = lane("ops", "11 · Watching\nand the dial", "admin/translations")
ya, yr = T + 270, T + 110
box("o0", cx(0), ya, "GET operations,\noperations/:id")
box("o1", cx(1), ya, "each run: status,\nattempts, errors per\npair, usage")
box("o3", cx(3), ya, "POST operations/\n:id/retry")
dia("o4", cx(4), ya, "failed or with\nexceptions?")
box("o4r", cx(4), yr, "404 not found", "red")
box("o5", cx(5), ya, "request(tx, retry) →\nlane 4; the failed one\nstays as the record")
arrow("o0", "o1")
arrow("o3", "o4")
up("o4", "o4r", RED, "no")
arrow("o4", "o5", INK, "yes")
yb, yr2 = T + 590, T + 430
box("o6", cx(0), yb, "GET status")
box("o7", cx(1), yb, "per owner type ×\nlanguage: current,\nstale, missing,\nreview, rejected")
box("o8", cx(2), yb, "per owner type:\noperations queued,\nrunning, failed")
box("o9", cx(3), yb, "PUT policies/\n:localeCode\n{samplePercent}")
dia("o10", cx(4), yb, "language\nexists?")
box("o10r", cx(4), yr2, "404 TRANSLATIONS_\nLOCALE_NOT_FOUND", "red")
box("o11", cx(5), yb, "upsert the dial: % of\nprovider words sent to\nreview (default 100%)")
chain(["o6", "o7", "o8"])
arrow("o9", "o10")
up("o10", "o10r", RED, "no")
arrow("o10", "o11", INK, "yes")
note("ops_n", cx(6) - 140, yb - 40,
     "GET policies lists every dial.\nThe dial only matters for an owner that\nis not vocabulary; "
     "there is none today.")
end_lane()

# =============================================================================
# 12 A language goes live
# =============================================================================

T = lane("loc", "12 · A language\ngoes live", "admin/locales, and\nthe gates that read\nthe words")
ya, yr = T + 330, T + 130
box("l0", cx(0), ya, "PUT /admin/locales/\n:code/status")
dia("l1", cx(1), ya, "allowed\nmove?")
box("l1r", cx(1), yr, "409 LOCALES_\nTRANSITION_NOT_\nALLOWED", "red")
dia("l2", cx(2), ya, "to\nwhich?")
lst = [("l_bf", ya - 150, "backfilling"), ("l_ac", ya, "active"), ("l_ot", ya + 150, "draft, review or\nretired: saved")]
for id, y, text in lst:
    box(id, cx(3), y, text, "gray" if id == "l_ot" else "plain")
box("l4", cx(4), ya - 150, "requestBackfill(tx) →\nlane 4: the engine\nwrites this language")
dia("l5", cx(4), ya + 30, "any gaps?")
box("l5r", cx(4), ya + 230, "409 LOCALES_\nBACKFILL_\nINCOMPLETE {gaps}", "red")
box("l6", cx(5), ya + 30, "active: storefronts\nserve it", "ok")
arrow("l0", "l1")
up("l1", "l1r", RED, "no")
arrow("l1", "l2", INK, "yes")
fan_right("l2", [id for id, _, _ in lst])
arrow("l_bf", "l4")
arrow("l_ac", "l5")
arrow("l5", "l5r", RED, "yes")
arrow("l5", "l6", GREEN, "no")
yb = T + 760
life = [("lc0", "draft"), ("lc1", "backfilling"), ("lc2", "review"), ("lc3", "active"), ("lc4", "retired")]
for i, (id, text) in enumerate(life):
    box(id, cx(i), yb, text, "ok" if id == "lc3" else "plain")
chain([id for id, _ in life])
for a, b, depth, off in [("lc1", "lc0", 60, 30), ("lc2", "lc1", 100, 15), ("lc4", "lc1", 140, 45)]:
    ax, ay = bottom(a)
    bx_, by_ = bottom(b)
    poly([(ax, ay + 6), (ax, ay + depth), (bx_ + off, ay + depth), (bx_ + off, by_ + 8)], GRAY)
note("lc_n", cx(5) - 140, yb - 40,
     "Back moves (grey): backfilling → draft, review → backfilling,\nretired → backfilling.\nTakes words (the engine "
     "translates into it): backfilling, review, active.\nGET /admin/locales/:code/readiness lists the gaps per owner type.")
yc = T + 1100
note("g_n", cx(0) - 140, yc - 110, "Where missing words refuse elsewhere:", size=18, color=INK)
box("g0", cx(0), yc, "approve a product\nversion")
box("g1", cx(1), yc, "lists VOCABULARY_\nUNTRANSLATED: a filed\ncategory, definition or\noption short of an\nactive language", "red")
box("g2", cx(3), yc, "attach a definition to\na shown category, or\nshow it in a market")
box("g3", cx(4), yc, "409 CATEGORIES_\nVOCABULARY_\nUNTRANSLATED", "red")
box("g4", cx(6), yc, "delete a translation\nin an active language")
box("g5", cx(7), yc, "409 *_TRANSLATION_\nLOCALE_ACTIVE", "red")
arrow("g0", "g1", RED)
arrow("g2", "g3", RED)
arrow("g4", "g5", RED)
end_lane()

# =============================================================================
# Lanes joined
# =============================================================================

connect("q7", "k0", "after commit")
connect("k5", "u0", "the job runs")
connect("v3", "t0")
connect("t8", "n0", "each call settled", edge=True)
connect("n8", "x0", "all calls settled")
connect("x8", "r_0", "results in review wait for a person")

# =============================================================================
# Header, legend, frame
# =============================================================================

header = [
    {"id": "doc_title", "type": "text", "x": 20, "y": 24, "width": 1500, "height": 50,
     "text": "Translations: the full flow", "fontSize": 44, "fontFamily": "helvetica", "strokeColor": INK},
    {"id": "doc_sub", "type": "text", "x": 22, "y": 92, "width": 2300, "height": 56,
     "text": "marketplace-api, as the code stands on 2026-10-08. Who starts work, how it is queued, what a run does, "
             "the provider, each answer, review, and a language going live.\nOwners: attribute definitions, attribute "
             "options and categories. Dashed pills point to another lane.",
     "fontSize": 20, "fontFamily": "helvetica", "strokeColor": "#495057"},
]
legend = [("rectangle", "plain", None, "step"), ("diamond", "plain", None, "decision"),
          ("ellipse", "table", None, "table"), ("rectangle", "red", None, "refused"),
          ("rectangle", "ok", None, "success"), ("rectangle", "gray", None, "dead end"),
          ("ellipse", "jump", "dashed", "to a lane")]
lx = BAND_W - 1420
for i, (kind, pal, style, label) in enumerate(legend):
    x = lx + i * 200
    bg, st = PAL[pal]
    el = {"id": f"leg_{i}", "type": kind, "x": x, "y": 40, "width": 48, "height": 34,
          "backgroundColor": bg, "strokeColor": st, "fillStyle": "solid", "roughness": 0}
    if style:
        el["strokeStyle"] = style
    header.append(el)
    header.append({"id": f"leg_t{i}", "type": "text", "x": x + 60, "y": 46, "width": 130, "height": 24,
                   "text": label, "fontSize": 20, "fontFamily": "helvetica", "strokeColor": INK})


def overlaps():
    items = [(s["id"], s["x"], s["y"], s["x"] + s["width"], s["y"] + s["height"]) for s in shapes]
    items += [(t["id"], t["x"], t["y"], t["x"] + t["width"], t["y"] + t["height"]) for t in texts
              if not t["id"].startswith(("title_", "sub_"))]
    for i, a in enumerate(items):
        for b in items[i + 1:]:
            if a[1] < b[3] - 4 and b[1] < a[3] - 4 and a[2] < b[4] - 4 and b[2] < a[4] - 4:
                print(f"overlap: {a[0]} / {b[0]}", file=sys.stderr)


overlaps()
scene = header + bands + shapes + texts + arrows
for el in scene:
    el["frameId"] = "frame_full"
scene.append({"id": "frame_full", "type": "frame", "name": "Translations: the full flow",
              "x": -40, "y": -20, "width": BAND_W + 80, "height": cur["next"] + 20})
print(f"{len(scene)} elements, height {cur['next']}", file=sys.stderr)
json.dump(scene, sys.stdout, ensure_ascii=False)
