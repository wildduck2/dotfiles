"""Where boards are drawn. CANVAS=web, the default, is the Excalidraw web app through its MCP, one scene per
board. CANVAS=local is the canvas container on 127.0.0.1:3100 the boards were first drawn on."""
import json
import os
import subprocess
import sys
import urllib.request

MODE = os.environ.get("CANVAS", "web")
URL = "http://127.0.0.1:3100"
CONTAINER = "excalidraw-canvas"
# With accounts on, the canvas API answers a signed-in browser, an API key, or the token the server
# writes here at boot; a request through Docker's port mapping does not count as local
AGENT_TOKEN = os.path.expanduser("~/Desktop/excalidraw/data/agent-token")
WEB = "https://excalidraw-two-snowy.vercel.app"
# A board key's scene, filled by the board set's builder. "" is the scene of an id with no board key, the
# translation board's
SCENES = {}
# get_scene answers at most this many elements for `all`
CAP = 500
DIGITS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"


def link(eid):
    if MODE == "local":
        return f"{URL}/?element={eid}"
    key = eid.split("_", 1)[0]
    return f"{WEB}/s/{SCENES.get(key) or SCENES['']}?element={eid}"


def live(scene=None):
    if MODE == "local":
        req = urllib.request.Request(f"{URL}/api/elements")
        if os.path.exists(AGENT_TOKEN):
            with open(AGENT_TOKEN) as f:
                req.add_header("Authorization", f"Bearer {f.read().strip()}")
        els = json.load(urllib.request.urlopen(req))
        return [e for e in els.get("elements", els) if not e.get("isDeleted")]
    return web_live(scene)


def web_live(scene):
    """Every live element. `all` stops at CAP, so a bigger scene is read frame by frame, then by text, then by
    the ids the rest refer to."""
    from mcp import call
    head = call("get_scene", {"sceneId": scene})
    total = head["outline"]["elements"]
    els = {e["id"]: e for e in call("get_scene", {"sceneId": scene, "all": True}).get("elements", [])}
    for f in head["outline"]["frames"]:
        if len(els) >= total:
            break
        els.update((e["id"], e) for e in call("get_scene", {"sceneId": scene, "frameId": f["id"]})["elements"])
    for ch in "etaoinsrhldcu0123456789":
        if len(els) >= total:
            break
        els.update((e["id"], e) for e in call("get_scene", {"sceneId": scene, "text": ch})["elements"])
    for _ in range(5):
        refs = set()
        for e in els.values():
            refs |= {b["id"] for b in e.get("boundElements") or []}
            refs |= {e[k] for k in ("containerId", "frameId") if e.get(k)}
            refs |= {e[k]["elementId"] for k in ("startBinding", "endBinding") if e.get(k)}
        missing = sorted(refs - set(els))
        if not missing:
            break
        for i in range(0, len(missing), 400):
            els.update((e["id"], e) for e in
                       call("get_scene", {"sceneId": scene, "elementIds": missing[i:i + 400]})["elements"])
    if len(els) < total:
        print(f"live: read {len(els)} of {total} elements", file=sys.stderr)
    return list(els.values())


def cli(*args, stdin=None):
    return subprocess.run(["docker", "exec", "-i", CONTAINER, "node", "dist/bin.js", *args], input=stdin,
                          capture_output=True, text=True)


def apply(part, scene=None, version=None):
    """One patch: {"create": [...], "update": [...], "delete": [...]}. Both canvases run the writes before the
    deletes, so a rebuild that reuses ids deletes in a call of its own first. `version` names the web scene as
    it stands before the change."""
    if MODE == "local":
        r = cli("apply", "-", stdin=json.dumps(part, ensure_ascii=False))
        out = json.loads(r.stdout) if r.stdout.strip().startswith("{") else {"raw": r.stdout[:400],
                                                                             "err": r.stderr[:400]}
        print({k: out.get(k) for k in ("success", "created", "updated", "deleted", "raw", "err", "error")
               if out.get(k) is not None}, file=sys.stderr)
        return out
    from mcp import call
    upsert = part.get("create", []) + part.get("update", [])
    out, step = None, 1500
    for i in range(0, max(len(upsert), 1), step):
        args = {"sceneId": scene, "upsert": upsert[i:i + step]}
        if i == 0 and part.get("delete"):
            args["delete"] = part["delete"]
        if i == 0 and version:
            args["versionName"] = version
        out = call("apply_changes", {k: v for k, v in args.items() if v})
        print(f"{scene}: version {out['version']}, wrote {len(out['written'])}", file=sys.stderr)
    return out


# =============================================================================
# The web app's element form
# =============================================================================

BASE = {"angle": 0, "strokeColor": "#1e1e1e", "backgroundColor": "transparent", "fillStyle": "solid", "strokeWidth": 2,
        "strokeStyle": "solid", "roughness": 1, "opacity": 100, "groupIds": [], "frameId": None, "roundness": None,
        "boundElements": None, "link": None, "locked": False}
TEXT = {"fontSize": 20, "fontFamily": 5, "textAlign": "left", "verticalAlign": "top", "containerId": None,
        "autoResize": True, "lineHeight": 1.25}
LINEAR = {"lastCommittedPoint": None, "startBinding": None, "endBinding": None, "startArrowhead": None,
          "endArrowhead": "arrow", "elbowed": False}


def _int_len(head):
    return ord(head) - ord("a") + 2 if "a" <= head <= "z" else ord("Z") - ord(head) + 2


def _key_after(key):
    """fractional-indexing's generateKeyBetween(key, null), for a key with room left in its head."""
    if key is None:
        return "a0"
    head, digs = key[0], list(key[1:_int_len(key[0])])
    for i in range(len(digs) - 1, -1, -1):
        d = DIGITS.index(digs[i]) + 1
        if d < len(DIGITS):
            digs[i] = DIGITS[d]
            return head + "".join(digs)
        digs[i] = "0"
    if head == "Z":
        return "a0"
    h = chr(ord(head) + 1)
    return h + "".join(digs + ["0"] if h > "a" else digs[:-1])


def prepare(els, current):
    """The board's elements as the web app stores them: a shape's text becomes its `<id>-label`, every field is
    sent, so a rebuilt id merged onto its tombstone keeps nothing of the old element, and each element takes the
    next z-index above everything the scene held when it was read, a label right after its shape."""
    if MODE == "local":
        return els
    from lib import line_w
    out = []
    for el in els:
        el = dict(el)
        if el["type"] in ("rectangle", "diamond", "ellipse") and "text" in el:
            text = el.pop("text")
            size, family = el.pop("fontSize", 20), el.pop("fontFamily", 5)
            lines = text.split("\n")
            w, h = round(max(line_w(s) for s in lines) * size / 20, 2), len(lines) * size * 1.25
            out.append({**BASE, **el})
            out.append({**BASE, **TEXT, "id": f"{el['id']}-label", "type": "text", "text": text, "originalText": text,
                        "fontSize": size, "fontFamily": family, "textAlign": "center", "verticalAlign": "middle",
                        "containerId": el["id"], "strokeColor": el.get("strokeColor", BASE["strokeColor"]),
                        "x": el["x"] + (el["width"] - w) / 2, "y": el["y"] + (el["height"] - h) / 2, "width": w,
                        "height": h, "roughness": el.get("roughness", 1), "frameId": el.get("frameId"),
                        "groupIds": el.get("groupIds", []), "locked": el.get("locked", False)})
            continue
        if el["type"] == "text":
            el = {**BASE, **TEXT, **el}
            el["originalText"] = el["text"]
        elif el["type"] in ("arrow", "line"):
            el = {**BASE, **LINEAR, **el}
        else:
            el = {**BASE, **el}
        out.append(el)
    top = max((e["index"] for e in current if isinstance(e.get("index"), str)), default=None)
    for el in out:
        top = el["index"] = _key_after(top)
    return out


def new_scene(title, workspace, folder):
    from mcp import call
    return call("create_scene", {"workspaceId": workspace, "title": title, "folderId": folder})
