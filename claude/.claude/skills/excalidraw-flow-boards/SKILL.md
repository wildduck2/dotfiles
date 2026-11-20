---
name: excalidraw-flow-boards
description: Flow boards on the Excalidraw web app (one scene per board, through its MCP), generated from Python board files - one request told top to bottom in swimlanes, with refusals, example-data stickers, and links between lanes and boards. Use when drawing a new flow board, changing or rebuilding an existing one (the IRYSS host, auth, IAM, attribute, category, product, product media and translation boards), or checking a board for colliding arrows.
---

# Flow boards

A board is one frame in its own scene on the Excalidraw web app (https://excalidraw-two-snowy.vercel.app,
folder "IRYSS flow boards"), generated from one Python file. The file declares lanes, nodes, stickers and
wires; the engine sizes and places them, routes every arrow orthogonally around what is already drawn, and
patches the scene through the app's MCP. A rebuild deletes the board's own ids and creates them again where
its frame stands, so anything else in the scene stays where it is. `CANVAS=local` drives the old canvas
container instead, where every board shared one scene.

## Setup

Once per person, before the first board.

1. **Get into the workspace.** The boards are in the `gentleduck` workspace, collection "IRYSS flow
   boards". Its owner invites you as a Member, or shares the collection with you as Can edit. Either lets
   a build create, patch and restore scenes there.
2. **Make a write key** at https://excalidraw-two-snowy.vercel.app/?settings=keys: New API key, Read and
   write, named after the agent. It is shown once.
3. **Register the MCP at user scope**:

   ```bash
   claude mcp add --scope user --transport http excalidraw https://excalidraw-two-snowy.vercel.app/api/v1/mcp \
     --header "Authorization: Bearer exk_..."
   ```

   `engine/mcp.py` reads the URL and the key from `~/.claude.json`'s top-level `mcpServers.excalidraw`,
   which is where user scope writes them. The default scope, local, files them under one project instead.
4. **Check it**: `python3 -I <skill>/engine/mcp.py list_workspaces` lists `gentleduck`. A new Claude Code
   session then has the `mcp__excalidraw__*` tools too.
5. **Renders need `rsvg-convert`**: `brew install librsvg`. The engine is Python 3 and its standard
   library only.

Every change shows in the scene's activity and history as "<owner> via <key name>". Revoking the key ends
the access and keeps that attribution.

## Where things are

Paths are relative to this skill's base directory, `.claude/skills/excalidraw-flow-boards` in the IRYSS
repo. `<skill>` in a command is that directory's absolute path, which Claude Code prints when it loads the
skill.

| Path | What it is |
|---|---|
| `engine/canvas.py` | `live()`, `apply()` and `prepare()` for the web app, or for the old canvas with `CANVAS=local` |
| `engine/mcp.py` | the web app's MCP, with the key from `~/.claude.json`; `mcp.py <tool> '<json>'` calls one tool |
| `engine/lib.py` | `Board` and its lanes: layout, shapes, stickers, the legend |
| `engine/route.py` | the orthogonal router behind every wire |
| `engine/audit.py` | arrow collisions inside one group, in a dry run or on a live scene |
| `engine/render.py` | PNGs of a board and of each lane, from a dry run or a live scene, with no browser |
| `engine/crop.py`, `shot.py`, `shotbox.py`, `snap.py` | the old canvas's renders, `CANVAS=local` only |
| `boards/iryss/build.py` | builds and applies IRYSS boards, each into its scene in `SCENES` |
| `boards/iryss/b_*.py` | the IRYSS boards; `b_cats.py` and `b_products.py` use every feature |
| `boards/iryss/translations/` | the scripts that drew the old hand-made translation board, kept as history |
| `reference.md` | the board-file API: every call, kind, slot, id and build warning |

Run every command from your scratchpad: `patch-<name>.json` and the renders land in the working directory.

## Building or changing a board

1. **Read the code the board describes.** Every route, guard order, refusal code and event payload on a
   board is a claim about the backend, so take each one from the source.
2. **Write the board file**, `boards/iryss/b_<name>.py`, whose `make()` returns a `Board` (`reference.md`).
   A new board needs a scene: `build.py <name> scene` creates one in the folder and prints the line to add
   to `SCENES` in `build.py`.
3. **Dry run**: `python3 -I <skill>/boards/iryss/build.py <name> dry`.
   Done when stderr carries no build warning and `engine/audit.py g_<key> patch-<name>.json` prints
   `issues 0`. `<key>` is the first argument to `Board` (`Arch` on the platform board), not the
   file's name: `hst` for `hosts`, `arch` for `platform`, `translations_full` for the translation board.
4. **Look at it** before it goes up: `engine/render.py patch-<name>.json <key> <name>`, and view the whole
   board and every lane piece. Done when no text is cut off, no label sits on a line or another label, and
   every lane reads as a step of the request.
5. **Apply**: the same build with `apply`. It names a version `before <name> <date>` first, which
   `restore_version` puts back. Done when `engine/audit.py g_<key> <sceneId>` prints `issues 0` and a
   render of the live scene matches the dry run's.

`build.py all` rebuilds every board, thousands of elements; keep it for a change to the engine itself.

**The live boards are newer than their files.** The Categories, Attributes and Products boards were corrected in place on the web app, by id, after their files were last built (the
categories words lane says `hashes never stored`, `b_cats.py` still says `a hash per field`). Rebuilding
one from its file undoes those corrections: diff its dry run against the live scene first, or patch the
live elements by id with `apply_changes`.

## House style

Every IRYSS board keeps to these.

- **A board is one request**, told top to bottom. Lane 0 is the map. Lane 1 is the request: the route,
  then `Host registry`, `Auth` and `IAM` as jumps, then the body check, then the controller. Each later
  lane opens with a `from N: <call>` node naming the lane it continues.
- **Every lane is linked** to the request, or to the lane whose outcome it continues. A lane on its own
  reads as scattered.
- **Lane links are plain black arrows** (`b.wire`). Another board is a jump: a blue dashed ellipse whose
  link opens that board's lane. Only the host, auth and IAM chain is drawn as wires between boards.
- **Shared things live on one board and are linked to**, never redrawn: the words a lane writes jump to
  the translation board.
- **Stickers show the data**: a yellow sticker under the step that produces it, tied by a dotted line,
  and orange dashed `becomes` arrows where one shape of the data turns into the next.
- **Red** is a refusal with its status and code, **green** a success, **gray** an answer that changes
  nothing, a **diamond** a decision, an **ellipse** a table read or write.
- **Nothing collides**: no arrow through a box, over another arrow, or under a label.
- **A finished board is one locked group**, `g_<key>`, inside its frame `<key>_frame`.
- Example data uses `ops@iryss.com` and `anna@iryss.com`, never a real person's address.

## Gotchas

- **`apply` runs its creates before its deletes**, so a patch that recreates an id deletes it in a call
  of its own first. `build.py` does; a hand-written patch has to as well.
- **Labels on a fan-out bunch on the shared trunk.** Leave the wires from one node to many lanes
  unlabelled; the `from N:` node at each end already names the route.
- **An `under` edge enters its target from below**, so that target cannot also take a sticker tie there.
- **A wire from a lane's data sticker often routes cleaner** than one from the lane's last step, because
  the sticker sits on the lane's bottom edge.
- **A shape's label is a `<id>-label` text** with `containerId` set. `prepare()` writes it inside the
  board's frame and group; on the older boards the browser wrote it outside both. `build.py` deletes those
  along with their shape.
- **A re-created id merges onto its tombstone.** `apply_changes` merges an upsert onto the stored element,
  deleted or not, so a field the new element leaves out keeps its old value: a stale `link`, a dashed
  stroke, the old `originalText`, which the editor re-wraps a label from. `prepare()` sends every field and
  a fresh z-index for that reason; a hand-written upsert of a new element must too.
- **`get_scene` answers at most 500 elements for `all`.** `live()` reads a bigger scene frame by frame, then
  by text, then by the ids the rest refer to, and says so if it still falls short.
- **A jump's link names the target's scene**, from its board key in `SCENES`. A jump to a board with no
  scene yet points at the translation board.
- **rsvg-convert's negative offsets are written `--top=-565`**, never `--top -565`.
