from lib import Board


def make():
    b = Board("upl", "Product media: the upload flow", x0=360, square=True)
    b.head("Product media: the upload flow",
           "As built: modules/fileObjects and the products gallery. A photograph is planned, PUT to temp/ or sent in 8 MiB "
           "parts, and complete copies it out of temp/ and commits it;\na product update places it in the gallery, and a "
           "file nobody shows leaves Bunny. JPEG, PNG and WebP only. Product 0193..tee, its files 0199..f0N.")
    b.legend = [("rectangle", "plain", "step"), ("diamond", "plain", "decision"), ("ellipse", "table", "table"),
                ("rectangle", "red", "refused"), ("rectangle", "ok", "success"), ("rectangle", "gray", "dead end")]

    g = b.lane("map", "0 · The map", "each box is a lane below")
    main = [("m1", "req", "1 · every call:\nhost, auth,\nIAM, body"), ("m2", "plan", "2 · the plan:\na pending file"),
            ("m3", "bytes", "3 · the bytes,\nto temp/"), ("m4", "complete", "4 · complete:\ncopied, committed"),
            ("m5", "place", "5 · placed by a\nproduct update"), ("m6", "read", "6 · the read: the\ngallery in order")]
    for i, (key, lane, text) in enumerate(main):
        g.n(key, i, "main", "box", text, to=f"upl_band_{lane}")
    g.chain(*[k for k, _, _ in main])
    cleanup = [("m7", "gc", "7 · every quarter,\nfile-objects-gc"), ("m8", "fdel", "8 · a file\ndeleted"),
               ("m9", "purge", "9 · the purge:\nBunny's bytes gone")]
    for i, (key, lane, text) in enumerate(cleanup):
        g.n(key, i + 1, "down", "box", text, to=f"upl_band_{lane}")
    g.chain(*[k for k, _, _ in cleanup])
    g.n("m10", 4, "down", "box", "10 · every 30 s,\nfile-objects-sweep", to="upl_band_sweep")
    g.n("m11", 5, "down", "box", "11 · every hour,\nfile-objects-cleanup", to="upl_band_cleanup")
    g.e("m10", "m9")

    g = b.lane("req", "1 · Every call", "marketplace-api\n(NestJS)")
    g.row("main", 0, [("mw", "box", "helmet, trust proxy,\nrequest id + log"), ("host", "dia", "host\nknown?"),
                      ("auth", "dia", "signed\nin?"), ("iam", "dia", "IAM\nallows?"), ("body", "dia", "body\nvalid?"),
                      ("ctrl", "box", "controller\n(nestia route)"), ("svc", "box", "service method\n@Throws"),
                      ("ok", "box", "200/201 {ok, code, data}\n<CODE>_SUCCEEDED", "ok")], chain=False)
    g.e("mw", "host")
    g.e("host", "auth", "yes")
    g.e("auth", "iam", "yes")
    g.e("iam", "body", "yes")
    g.e("body", "ctrl", "yes")
    g.chain("ctrl", "svc", "ok")
    g.row("up", 1, [("r_host", "box", "404\nHOST_NOT_\nREGISTERED", "red"),
                    ("r_auth", "box", "401\nAUTH_\nUNAUTHENTICATED", "red"),
                    ("r_iam", "box", "403\nIAM_FORBIDDEN", "red"),
                    ("r_body", "box", "400\nvalidateEquals:\na missing or\nextra key", "red"), None,
                    ("r_err", "box", "error filter →\n{ok: false, code}", "red"),
                    ("r_read", "box", "the caller reads\nthe code", "red")], chain=False)
    for d in ("host", "auth", "iam", "body"):
        g.e(d, f"r_{d}", "no")
    for a, c in (("r_host", "r_auth"), ("r_auth", "r_iam"), ("r_iam", "r_body"), ("r_body", "r_err"), ("r_err", "r_read")):
        g.e(a, c, dashed=True)
    g.e("svc", "r_err", "throws", dashed=True)
    g.note("req_note", 0, "foot", "Every route on this board runs this first. The plan and the product update ask update on "
                                  "products at the company scope; a step on a file asks fileObjects at its owner's scope, the "
                                  "company for a product's; the admin GET reads at the admitted staff scopes, the marketplace "
                                  "GET at the market its host names. The body holds the type to JPEG, PNG or WebP and the size "
                                  "to 16 MiB, and a gallery to 20 files, each once.")

    g = b.lane("plan", "2 · The plan:\na pending file", "planUpload(): the width\nand height are the\nbrowser's")
    g.row("main", 0, [("in", "box", "POST /admin/products/\n0193..tee/media/\nplan-upload"),
                      ("prod", "dia", "product\nthere?"),
                      ("px", "dia", "short side\n720 px, at\nmost 64 MP?"),
                      ("open", "box", "over 8 MiB: a\nmultipart session\non temp/, first"),
                      ("lock", "table", "the owner's files\nof that checksum\nFOR UPDATE"),
                      ("dup", "dia", "the same\nbytes\ncommitted?"),
                      ("pend", "dia", "pending, same\ntype and\nsize?"),
                      ("ins", "table", "insert file_objects:\npending, key media/\n0199..f01.jpg"),
                      ("ok", "box", "201: a PUT signed\n15 min, or a\nmultipart plan", "ok")], chain=False)
    g.e("in", "prod")
    g.e("prod", "px", "yes")
    g.e("px", "open", "yes")
    g.e("open", "lock")
    g.e("lock", "dup")
    g.e("dup", "pend", "no")
    g.e("pend", "ins", "no")
    g.e("ins", "ok")
    g.row("up", 1, [("prod_r", "box", "404 PRODUCT_MEDIA_\nPRODUCT_NOT_FOUND", "red"),
                    ("px_r", "box", "422 FILE_OBJECTS_\nINVALID_IMAGE,\nits reason", "red"), None, None,
                    ("dup_r", "box", "409 FILE_OBJECTS_\nDUPLICATE {fileId}:\nready to place", "red")], chain=False)
    g.e("prod", "prod_r", "no")
    g.e("px", "px_r", "no")
    g.e("dup", "dup_r", "yes")
    g.n("ab", 3, "down", "box", "refused, or another\nfile's plan: the\nsession aborted", "gray")
    g.e("open", "ab", "not this file")
    g.n("again", 6, "down", "box", "that file's plan\nagain, its window\nrenewed", "gray")
    g.e("pend", "again", "yes")
    g.note("plan_note", 0, "foot", "Nothing on the server decodes an image. The key is media/<fileId>.<ext> from the declared "
                                   "type, never rewritten, and the temp/ key is derived from it. A PUT is signed for its "
                                   "checksum, type and length; a multipart file is pending 24 hours. admin/fileObjects/"
                                   "plan-upload is the same plan for a file the company owns.")

    g = b.lane("bytes", "3 · The bytes,\nto temp/", "straight to Bunny;\nnothing serves temp/")
    g.n("put", 0, "main", "box", "a PUT: the browser\nsends temp/media/\n0199..f01.jpg")
    g.n("sig", 1, "main", "dia", "signed\nheaders and\nbytes match?")
    g.n("ok", 3, "main", "box", "stored whole\nunder temp/", "ok")
    g.e("put", "sig")
    g.e("sig", "ok", "yes")
    g.n("sig_r", 1, "up", "box", "400 BadDigest, or\n403 a header\nchanged", "red")
    g.e("sig", "sig_r", "no")
    g.n("get", 2, "up", "box", "anyone: GET\n<cdn>/temp/…")
    g.n("edge", 3, "up", "box", "403: an Edge Rule\nblocks temp/", "gray")
    g.e("get", "edge")
    g.row("down", 0, [("part", "box", "multipart: POST\n/admin/fileObjects/\n0199..f02/sign-part"),
                      ("pend", "dia", "pending, in\nits window,\na planned part?"),
                      ("psend", "box", "part 3 signed for\nits length, 15 min;\nthe browser PUTs it"),
                      ("mpc", "box", "POST …/complete-\nmultipart: the parts\nBunny lists")], chain=False)
    g.e("part", "pend")
    g.e("pend", "psend", "yes")
    g.e("psend", "mpc", "every part")
    g.e("mpc", "ok")
    g.n("pend_r", 1, "down2", "box", "409 _UPLOAD_NOT_\nPENDING, _NOT_\nMULTIPART; 400\n_PART_INVALID", "red")
    g.e("pend", "pend_r", "no")
    g.n("mpc_r", 3, "down2", "box", "409 _UPLOAD_\nMISMATCH: a part\nmissing or short", "red")
    g.e("mpc", "mpc_r", "no")
    g.note("bytes_note", 0, "foot", "A signature past its 15 minutes is a dead PUT: plan again, and the same file is answered "
                                    "with a fresh one. complete-multipart assembles the parts Bunny holds, never a list the "
                                    "browser sends; an object already assembled answers again. abort-multipart ends the "
                                    "session at once and deletes the file, 8.")

    g = b.lane("complete", "4 · complete:\ncopied, committed", "outside any caller's\ntransaction; no Bunny\ncall inside its own")
    g.row("main", 0, [("in", "box", "POST /admin/\nfileObjects/0199..f01/\ncomplete"),
                      ("st", "dia", "the file's\nstatus?"),
                      ("mp", "dia", "sent in\nparts?"),
                      ("copy", "dia", "CopyObject\ntemp/ to\nmedia/?"),
                      ("lock", "box", "the file's row\nFOR UPDATE"),
                      ("still", "dia", "still\npending?"),
                      ("upd", "table", "committed:\nuploaded_at,\ncommitted_at"),
                      ("del", "box", "DeleteObject\non temp/"),
                      ("ok", "box", "200 {fileId, key}", "ok")], chain=False)
    g.e("in", "st")
    g.e("st", "mp", "pending")
    g.e("mp", "copy", "no: a PUT")
    g.e("copy", "lock", "copied")
    g.e("lock", "still")
    g.e("still", "upd", "yes")
    g.e("upd", "del")
    g.e("del", "ok")
    g.row("up", 1, [("st_r", "box", "409 _UPLOAD_\nNOT_PENDING:\ndeleted", "red"), None,
                    ("copy_r", "box", "409 _UPLOAD_\nMISMATCH: not\nthere, still pending", "red"), None,
                    ("still_r", "box", "deleted meanwhile:\npurge queued again,\n409 _NOT_PENDING", "red"),
                    ("upd_r", "box", "409 FILE_OBJECTS_\nDUPLICATE: the same\nbytes committed", "red")], chain=False)
    g.e("st", "st_r", "deleted")
    g.e("copy", "copy_r", "missing")
    g.e("still", "still_r", "no")
    g.e("upd", "upd_r", "unique")
    g.n("st_y", 1, "down", "box", "committed: 200\nagain, from the row", "gray")
    g.e("st", "st_y", "committed")
    g.n("dig", 2, "down", "dia", "read back:\nSHA-256 and\nsize planned?")
    g.e("mp", "dig", "yes")
    g.e("dig", "copy", "yes")
    g.n("dig_r", 2, "down2", "box", "the file deleted,\n409 _UPLOAD_\nMISMATCH", "red")
    g.e("dig", "dig_r", "no")
    g.n("del_f", 7, "down", "box", "fails: temp/ left to\nthe cleanup, 11; a\nretry answers 200", "gray")
    g.e("del", "del_f", "fails")
    g.note("complete_note", 0, "foot", "A PUT needs no read, since Bunny refused bytes that broke what was signed; a part is "
                                       "signed for its length alone. The duplicate is two uploads of the same bytes racing "
                                       "past the plan into uq_file_objects_owner_checksum; that file stays pending until the "
                                       "sweep expires it. The panel places a file as soon as complete answers, 5.")

    g = b.lane("place", "5 · Placed by a\nproduct update", "the product's fields\nand its gallery in\none transaction")
    g.row("main", 0, [("in", "box", "PATCH /admin/products/\n0193..tee {media:\n{mediaVersion: 5,\nfiles: [f03, f01]}}"),
                      ("lock", "box", "the product's row\nFOR UPDATE"),
                      ("rep", "dia", "one file\nnamed\ntwice?"),
                      ("ver", "dia", "version\nstill 5?"),
                      ("same", "dia", "the same\nlist?"),
                      ("un", "table", "each entry left\nout: unlinked; a file\nno link shows, deleted"),
                      ("link", "dia", "each new file:\nthis product's,\ncommitted, ready?"),
                      ("ord", "table", "positions 1 to n,\nmedia_version 6"),
                      ("ok", "box", "200: the product;\nafterCommit,\nmedia_changed", "ok")], chain=False)
    g.e("in", "lock")
    g.e("lock", "rep")
    g.e("rep", "ver", "no")
    g.e("ver", "same", "yes")
    g.e("same", "un", "no")
    g.e("un", "link")
    g.e("link", "ord", "yes")
    g.e("ord", "ok")
    g.row("up", 2, [("rep_r", "box", "400 PRODUCT_MEDIA_\nFILE_REPEATED", "red"),
                    ("ver_r", "box", "409 PRODUCT_MEDIA_\nSTALE_VERSION", "red"), None, None,
                    ("link_r", "box", "404 PRODUCT_MEDIA_\nNOT_FOUND, or 409\n_NOT_PLACEABLE", "red")], chain=False)
    g.e("rep", "rep_r", "yes")
    g.e("ver", "ver_r", "no")
    g.e("link", "link_r", "no")
    g.n("same_y", 4, "down", "box", "the gallery: nothing\nwritten, nothing\nannounced", "gray")
    g.e("same", "same_y", "yes")
    g.note("place_note", 0, "foot", "One file in two cases passes the body's UniqueItems and is caught here, before the gallery "
                                    "is read. Position 1 is the primary, and the event says primaryChanged. A deleted file's "
                                    "purge is due 30 days on, 9. The 1500 px floor is the panel's for now: placing does not "
                                    "check it yet.")

    g = b.lane("read", "6 · The read", "the gallery in order,\neach entry's plain\nCDN url")
    g.row("main", 0, [("adm", "box", "GET /admin/products/\n0193..tee/media"),
                      ("q", "table", "entries by\nposition, each\nwith its file"),
                      ("un", "table", "up to 50 files\nno entry shows,\nnewest first"),
                      ("pol", "box", "and the policy:\n20, 1500 px,\n16 MiB, the types"),
                      ("ok", "box", "200 {mediaVersion,\nfiles, unplaced,\npolicy}", "ok")])
    g.row("down", 0, [("mk", "box", "GET marketplace/\nproducts/0193..tee/\nmedia, Host: brands.\nfr.iryss.com"),
                      ("mkt", "dia", "a market\nfrom the\nhost?"),
                      ("live", "dia", "active, a live\ntitle in its\ndefault locale?"),
                      ("mq", "table", "entries by\nposition, each\nwith its file"),
                      ("mok", "box", "200 [entries],\naltText the title", "ok")], chain=False)
    g.e("mk", "mkt")
    g.e("mkt", "live", "yes")
    g.e("live", "mq", "yes")
    g.e("mq", "mok")
    g.n("mkt_r", 1, "down2", "box", "500 PRODUCT_MEDIA_\nNO_MARKET_RESOLVED", "red")
    g.e("mkt", "mkt_r", "no")
    g.n("live_r", 2, "down2", "box", "404 PRODUCT_MEDIA_\nPRODUCT_NOT_FOUND", "red")
    g.e("live", "live_r", "no")
    g.note("read_note", 0, "foot", "An entry's url is the plain CDN link: the client picks the size by adding ?class=, so "
                                   "the API builds no renditions. Its role is read off the position, never stored.")

    g = b.lane("gc", "7 · file-objects-gc", "every quarter: a file\nnobody placed, 90\ndays after its commit")
    g.row("main", 0, [("cron", "box", "@Cron(EVERY_QUARTER)\nunder runOnce, in\ncommon/maintenance"),
                      ("q", "table", "committed, in no\nentry, committed\n90+ days ago"),
                      ("each", "box", "100 at a time:\neach through the\nfile's delete, 8")])
    g.note("gc_note", 3, "main", "FileObjectRunner.gc(). A file placed meanwhile\nanswers FILE_OBJECTS_IN_USE in 8 and is kept.")

    g = b.lane("fdel", "8 · A file\ndeleted", "DELETE /admin/\nfileObjects/:fileId,\nor file-objects-gc")
    g.row("main", 0, [("in", "box", "DELETE /admin/\nfileObjects/\n0199..f09"),
                      ("lock", "box", "the file's row\nFOR UPDATE"),
                      ("st", "dia", "already\ndeleted?"),
                      ("fk", "dia", "a link\nshows it?"),
                      ("del", "table", "status deleted,\ndeleted_at"),
                      ("due", "box", "afterCommit:\npurge.0199..f09,\ndelayed"),
                      ("ok", "box", "200 {fileId,\nstatus: deleted}", "ok")], chain=False)
    g.chain("in", "lock", "st")
    g.e("st", "fk", "no")
    g.e("fk", "del", "no")
    g.chain("del", "due", "ok")
    g.n("fk_r", 3, "up", "box", "409 FILE_OBJECTS_\nIN_USE", "red")
    g.e("fk", "fk_r", "yes")
    g.n("st_y", 2, "down", "box", "200 again,\nnothing queued", "gray")
    g.e("st", "st_y", "yes")
    g.note("fdel_note", 0, "foot", "A pending upload deleted is the portal's cancel. fk_file_object_references_file refuses "
                                   "the write while a link shows the file, so a gallery entry is removed by a product update, "
                                   "5. A committed file's purge waits 30 days, a pending one's until its upload window closes.")

    g = b.lane("purge", "9 · The purge", "purge.<fileId>: the\none place Bunny's\nbytes are deleted")
    g.row("main", 0, [("in", "box", "purge.0199..f09\non file-objects,\npriority 2"),
                      ("st", "dia", "deleted, not\nyet purged?"),
                      ("mp", "box", "a multipart\nsession it holds:\naborted"),
                      ("obj", "box", "DeleteObject on\nmedia/ and its\ntemp/ key"),
                      ("cdn", "box", "the CDN purges\n<url>*: every\n?class= copy"),
                      ("done", "table", "purged_at\nset"),
                      ("ok", "box", "the bytes\nare gone", "ok")], chain=False)
    g.e("in", "st")
    g.e("st", "mp", "yes")
    g.chain("mp", "obj", "cdn", "done", "ok")
    g.n("st_n", 1, "down", "box", "nothing: a link\nmay still show it", "gray")
    g.e("st", "st_n", "no")
    g.note("purge_note", 0, "foot", "A key already gone counts as deleted. A throttle pauses the whole queue and spends no "
                                    "attempt; otherwise 8 attempts, the waits doubling from 30 s. Out of attempts the job is "
                                    "removed with purged_at still empty, and the sweep queues it again, 10.")

    g = b.lane("sweep", "10 · file-objects-sweep", "every 30 s on the\nfile-objects queue")
    g.row("main", 0, [("sw", "box", "file-objects-\nsweep,\nevery 30 s"),
                      ("exp", "table", "pending past its\nwindow: deleted,\nits purge queued"),
                      ("pur", "box", "each due purge not\ndone, 100 oldest\nfirst: queued again")])
    g.note("sweep_note", 0, "foot", "Adding a job already waiting or running adds nothing, so a lost purge costs one sweep.")

    g = b.lane("cleanup", "11 · file-objects-\ncleanup", "hourly, in production,\nstaging included")
    g.row("main", 0, [("cl", "box", "file-objects-\ncleanup,\nevery hour"),
                      ("ls", "box", "every key\nunder temp/"),
                      ("pk", "table", "which are a\npending file's?"),
                      ("rm", "box", "each other key:\nDeleteObject")])
    g.note("cleanup_note", 0, "foot", "Whatever its age: an object is listed only once its upload has finished, and a file's "
                                      "row exists before its upload is signed. Elsewhere the scheduler is removed.")

    b.trunk("req.svc", ["plan.in", "bytes.part", "complete.in", "place.in", "read.adm", "read.mk", "fdel.in"],
            "the service runs one of the routes below")
    b.wire("plan.ok", "bytes.put", "the plan", sides=(("bottom",), ("top",)))
    b.wire("bytes.ok", "complete.in", sides=(("right",), ("top",)))
    b.wire("gc.each", "fdel.in", sides=(("bottom",), ("top",)))
    b.wire("fdel.due", "purge.in", sides=(("bottom",), ("top",)))
    b.wire("sweep.pur", "purge.in", sides=(("top",), ("bottom",)))
    return b
