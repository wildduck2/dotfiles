"""The Excalidraw web app's MCP, over plain HTTP. The URL and the Authorization header come from ~/.claude.json's
mcpServers.excalidraw and are never printed."""
import json
import os
import urllib.error
import urllib.request

try:
    _cfg = json.load(open(os.path.expanduser("~/.claude.json")))["mcpServers"]["excalidraw"]
except (OSError, KeyError):
    raise SystemExit("No excalidraw MCP server at user scope in ~/.claude.json: SKILL.md's Setup registers one.")
_ids = [0]
_ready = [False]


def _post(body):
    req = urllib.request.Request(_cfg["url"], data=json.dumps(body, ensure_ascii=False).encode(), method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("Accept", "application/json, text/event-stream")
    req.add_header("MCP-Protocol-Version", "2025-06-18")
    for k, v in (_cfg.get("headers") or {}).items():
        req.add_header(k, v)
    try:
        with urllib.request.urlopen(req, timeout=300) as r:
            raw, ctype = r.read().decode(), r.headers.get("Content-Type", "")
    except urllib.error.HTTPError as e:
        return {"error": {"http": e.code, "body": e.read().decode()[:600]}}
    if not raw.strip():
        return None
    if "text/event-stream" in ctype:
        msgs = [json.loads(l[5:]) for l in raw.splitlines() if l.startswith("data:") and l[5:].strip()]
        return msgs[-1] if msgs else None
    return json.loads(raw)


def _rpc(method, params=None):
    _ids[0] += 1
    return _post({"jsonrpc": "2.0", "id": _ids[0], "method": method, **({"params": params} if params else {})})


def call(tool, args):
    if not _ready[0]:
        _rpc("initialize", {"protocolVersion": "2025-06-18", "capabilities": {},
                            "clientInfo": {"name": "flow-boards", "version": "1"}})
        _ready[0] = True
    out = _rpc("tools/call", {"name": tool, "arguments": args})
    if out is None or "error" in out:
        raise SystemExit(f"{tool}: {json.dumps(out)[:800]}")
    res = out["result"]
    text = "\n".join(c.get("text", "") for c in res.get("content", []) if c.get("type") == "text")
    if res.get("isError"):
        raise SystemExit(f"{tool}: {text[:800]}")
    if res.get("structuredContent") is not None:
        return res["structuredContent"]
    try:
        return json.loads(text)
    except ValueError:
        return text


if __name__ == "__main__":
    import sys
    print(json.dumps(call(sys.argv[1], json.loads(sys.argv[2]) if len(sys.argv) > 2 else {}), indent=1,
                     ensure_ascii=False)[:20000])
