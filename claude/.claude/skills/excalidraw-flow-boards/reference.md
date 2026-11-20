# Board-file reference

A board file is `b_<name>.py` beside `build.py`. Its `make()` returns a `Board`; `build.py` calls
`make().layout()`, then `build(x, y)`, which emits the elements, routes the wires and checks the result.
`b_cats.py` is the shortest file that uses every call below.

```python
from lib import Board

def make():
    b = Board("cat", "Categories: the tree a product is filed in")
    b.head("Categories: the tree a product is filed in", "One global tree ...")

    g = b.lane("req", "1 · The request", "every admin write here:\nthe host, the session,\nIAM, then the body")
    g.row("main", 0, [("post", "box", "POST /admin/\ncategories"),
                      ("host", "jump", "Host registry:\nadmin host?", "hst_band_resolve"),
                      ("body", "dia", "body\nvalid?"),
                      ("ctrl", "box", "the controller\nruns", "ok")])
    g.n("body_r", 2, "up", "box", "400: validateEquals\nrefuses any extra key", "red")
    g.e("body", "body_r", "no")
    g.s("s_req", 0, "the request", "POST /admin/categories\nHost: admin.iryss.com", of="post")
    g.note("req_note", 0, "foot", "Every category write asks IAM about categories at company ...")

    b.wire("req.ctrl", "create.in")
    return b
```

## Board

| Call | Does |
|---|---|
| `Board(key, name, x0=320, square=False)` | `key` prefixes every id and should be unique on the canvas; `name` is the frame's title. `x0` moves the first column, to leave room for a trunk; `square` draws rectangles with square corners, as the translation board does |
| `b.head(title, subtitle)` | the board's title and its one-paragraph summary |
| `b.lane(key, title, sub, slots=None, gap=84)` | a lane: a band with a title like `"3 · Every other\nlanguage"` and a three or four line subtitle |
| `b.wire("lane.node", "lane.node", label=None, sides=(None, None))` | a black arrow between lanes, routed after layout around everything drawn |
| `b.wire("lane.node", "key:lane.node", label)` | a blue dashed wire to another board, drawn only with `CANVAS=local`, where boards share a scene. On the web app a board reaches another through a jump |
| `b.trunk("lane.node", ["lane.node", ...], label=None, x=None)` | one black line from the node down the left margin at `x0 - 80`, branching into each target's left face: lane 1's call fanning out to the lanes it runs. The routed wires go around it |
| `b.legend` | the legend's items, `(kind, palette, label)`; set it to only what the board draws |

`sides` narrows the faces a wire may use, one tuple per end: `(("right",), ("top", "left"))`.

## Lane

| Call | Does |
|---|---|
| `g.n(id, col, slot, kind, text, pal="plain", to=None)` | one node; `to` is a jump's target id |
| `g.row(slot, start, items, chain=True)` | nodes left to right from column `start`. An item is `(id, kind, text[, pal])`, or `(id, "jump", text, target)`; `None` leaves a column empty. `chain` draws an arrow between neighbours |
| `g.e(a, b, label=None, color=None, dashed=False, off=0, under=False)` | an arrow inside the lane. Its colour follows the target: red into a refusal, green into a success, gray into a gray node, blue dashed into a jump, black otherwise. `off` shifts a straight arrow sideways, so a pair running both ways stays apart. `under` bends a same-row arrow down through the gap beneath the row, past the steps between |
| `g.chain(*ids)` | arrows between consecutive nodes |
| `g.s(id, col, tag, text, slot="data", of=None)` | a data sticker: an orange tag over a yellow box of monospace text. `of` ties it with a dotted line to the node that produces it, which has to be in the same column, above or below |
| `g.becomes(*ids)` | orange dashed arrows from each sticker to the next; all in one slot |
| `g.note(id, col, slot, text, size=16, color=SUB, span=True)` | free text, wrapped at 72 characters. A spanning note takes no width from its column, so `g.note(id, 0, "foot", ...)` runs under the whole lane |

## Kinds and palettes

| kind | Drawn as | Means |
|---|---|---|
| `box` | rounded rectangle | a step |
| `dia` | diamond | a decision |
| `table` | ellipse | a table read or write |
| `jump` | blue dashed ellipse, linked | a lane on another board |

| pal | Colours | Means |
|---|---|---|
| `plain` | white, black | the default |
| `table` | light gray, black | a table node |
| `red` | pink, red | a refusal: status and code |
| `ok` | pale green, green | a success |
| `gray` | white, gray | an answer that changes nothing |
| `jump` | pale blue, blue | set by kind `jump` |

A node's size comes from its text; break lines with `\n` at about twenty characters.

## Slots

A lane's rows, top to bottom, default `["up2", "up", "main", "down", "down2", "down3", "data", "foot"]`.
A lane can pass its own list, for instance with `"down4"` added; a node in a slot the list lacks raises
a `KeyError` at layout. An empty slot collapses, and every box in a slot takes the slot's tallest height.

| Slot | Holds |
|---|---|
| `main` | the happy path, left to right, ending in the green success |
| `up` | the refusal above each decision, its edge labelled `no`, `refused`, `stale` |
| `up2` | a sticker on a refusal, such as its error detail |
| `down`, `down2`, ... | sibling routes (the DELETE beside a PUT), their refusals, and jumps |
| `data` | the stickers |
| `foot` | the lane's note |

## Ids

| Id | Is |
|---|---|
| `<key>_<lane>_<node>` | a node; a jump's `to` and a wire end name these |
| `<key>_band_<lane>` | the lane's band; a jump usually targets one, such as `prd_band_file` |
| `<key>_frame`, `g_<key>` | the frame, and the group holding every element |
| `<key>_ar<N>`, `_ln<N>`, `_wr<N>` | arrows, lines and wires, numbered afresh each build: never refer to one |
| `xb_<N>`, group `g_xboard` | the wires between boards |

A jump's link opens `https://excalidraw-two-snowy.vercel.app/s/<scene>?element=<to>`, the scene taken from
`<to>`'s board key in `build.py`'s `SCENES`; with `CANVAS=local` it opens `http://127.0.0.1:3100/?element=<to>`.

## Layout and routing

`lib.py`: the first column starts at `X0 = 320`; columns are `COL_GAP = 110` apart, widened to fit a label
on a same-row arrow; slots `SLOT_GAP = 84`; lanes pad `LANE_PAD = 56` and sit `LANE_GAP = 40` apart;
arrows stop `EDGE = 8` short of a face.

An arrow inside a lane is straight or bends once, taking the other bend when the first runs through a
node. Wires go through `route.py`'s `Router(step=16, margin=18, near=44)`, a search on an orthogonal grid.
Boxes block; drawn lines only cost, cheap to cross away from their ends and dear to run beside. Wires
sharing a source or a target merge into one trunk. `r.label(pts, text, size=15, own=True, prefer=None)`
finds a clear spot beside a drawn wire; `prefer` is `"start"` or `"end"`. `b.wire` uses the defaults;
`build.py` routes the wires between boards with `step=24, margin=22`.

## Build warnings

Printed on stderr during `build.py`; a finished board prints none.

| Warning | Means |
|---|---|
| `route crosses <node>: <key>.<a> -> <b>` | an arrow inside a lane found no clean path; move a node, or use `under` or `off` |
| `no route: a -> b` | a wire found no path; pass `sides`, or wire from another node such as the lane's sticker |
| `overlap: a / b` | two boxes or texts overlap |
| `arrow X crosses Y` | an arrow runs through a box |
| `duplicate id: X` | two nodes share an id |
| `tie not in one column: ...` | a sticker's `of` node is in another column |
| `becomes needs one slot: ...` | `becomes` joins stickers in different slots |
| `no such element: X` | a board-to-board wire names an id no board has |
