from lib import Board


def make():
    b = Board("cat", "Categories: the tree a product is filed in")
    b.head("Categories: the tree a product is filed in",
           "One global tree (Women > Clothing > Tops > T-shirts). A path names every ancestor, the label is written in English and the\n"
           "engine writes every other language, each market decides alone whether to show it, and a requirement binds everything beneath.")

    # =========================================================================
    # Map
    # =========================================================================

    g = b.lane("map", "0 · The map", "the request, then what\nit writes and who\nreads it")
    g.n("m_host", 0, "main", "jump", "Host registry:\nhost known?", to="hst_band_resolve")
    g.n("m_auth", 1, "main", "jump", "Auth:\nsigned in?", to="auth_band_session")
    g.n("m_iam", 2, "main", "jump", "IAM:\nallows?", to="iam_band_req")
    main = [("m1", "req", "1 · the request"), ("m2", "create", "2 · a category,\nin English"),
            ("m3", "words", "3 · every other\nlanguage"), ("m4", "markets", "4 · shown in\na market"),
            ("m6", "partner", "6 · a partner\nreads it")]
    for i, (key, lane, text) in enumerate(main):
        g.n(key, i + 3, "main", "box", text, to=f"cat_band_{lane}")
    g.chain("m_host", "m_auth", "m_iam", *[k for k, _, _ in main])
    side = [("m5", "attrs", "5 · what it\nrequires"), ("m7", "move", "7 · moving\na branch"),
            ("m8", "delete", "8 · retiring it")]
    for i, (key, lane, text) in enumerate(side):
        g.n(key, i + 3, "down", "box", text, "table", to=f"cat_band_{lane}")

    # =========================================================================
    # Request
    # =========================================================================

    g = b.lane("req", "1 · The request", "every admin write here:\nthe host, the session,\nIAM, then the body")
    g.row("main", 0, [("in", "box", "POST /admin/\ncategories"),
                      ("mw", "box", "helmet, trust proxy,\nrequest context"),
                      ("host", "jump", "Host registry:\nadmin host?", "hst_band_resolve"),
                      ("auth", "jump", "Auth:\nsigned in?", "auth_band_session"),
                      ("iam", "jump", "IAM: create\ncategories\nat company?", "iam_band_req"),
                      ("body", "dia", "body\nvalid?"),
                      ("ctrl", "box", "the controller\nruns", "ok")])
    g.n("body_r", 5, "up", "box", "400: validateEquals\nrefuses any extra key", "red")
    g.e("body", "body_r", "no")
    g.s("s_in", 0, "the request", "POST /admin/categories\nHost: admin.iryss.com\nCookie: __Host-duck-sid=<opaque>", of="in")
    g.s("s_iam", 4, "what IAM is asked", "{ action: \"create\",\n  resource: \"categories\",\n  scope: \"company\" }",
        of="iam")
    g.s("s_body", 5, "the body", "{ parentId: \"0193..top\",\n  handle: \"t-shirts\",\n  name: \"T-shirts\",\n"
        "  description: \"Short-\n    sleeved tops\" }", of="body")
    g.note("req_note", 0, "foot", "Every category write asks IAM about categories at company, except showing it in a market: "
                                  "that asks update on marketplaces at company.marketplace.<id>, the market the body or the "
                                  "path names, so an operator confined to France can show a category in France and nowhere else.")

    # =========================================================================
    # Create
    # =========================================================================

    g = b.lane("create", "2 · A category,\nin English", "create(): one transaction,\nso the label and the\nengine's operation travel\nwith the row")
    g.row("main", 0, [("in", "box", "from 1:\ncreate(body)"),
                      ("par", "box", "with a parent: the\ntree lock for share,\nthe parent FOR SHARE"),
                      ("ins", "table", "insert categories:\na v7 id, the path\nunder the parent"),
                      ("src", "table", "insert the en label:\nisSource, human,\na hash per field"),
                      ("req", "box", "request(tx,\nsource_changed)"),
                      ("ev", "box", "afterCommit:\ncategory.created"),
                      ("ok", "box", "200, in English\nonly", "ok")])
    g.n("par_r", 1, "up", "box", "404 CATEGORIES_\nNOT_FOUND: no parent,\nor a retired one", "red")
    g.e("par", "par_r", "missing")
    g.n("ins_r", 2, "up", "box", "409 CATEGORIES_\nHANDLE_TAKEN,\n422 _TOO_DEEP", "red")
    g.e("ins", "ins_r", "refused")
    g.s("s_par", 1, "the parent, read", "{ id: \"0193..top\",\n  path: \"/0193..wom\n    /0193..clo\n    /0193..top\" }", of="par")
    g.s("s_row", 2, "the category row", "{ id: \"0193..tsh\",\n  parentId: \"0193..top\",\n  handle: \"t-shirts\",\n"
        "  path: \"/0193..wom\n    /0193..clo/0193..top\n    /0193..tsh\" }", of="ins")
    g.s("s_src", 3, "its en label", "{ categoryId: \"0193..tsh\",\n  localeCode: \"en\",\n  isSource: true,\n"
        "  source: \"human\",\n  name: \"T-shirts\",\n  sourceHashes: {\n    name: \"4be1..\" },\n  version: 1 }", of="src")
    g.s("s_op", 4, "the operation, queued", "{ ownerType: \"category\",\n  ownerId: \"0193..tsh\",\n"
        "  reason: \"source_changed\",\n  status: \"queued\" }", of="req")
    g.s("s_ev", 5, "the event", "{ categoryId: \"0193..tsh\",\n  parentId: \"0193..top\",\n  path: \"/0193..wom/…\n"
        "    /0193..tsh\" }", of="ev")
    g.becomes("s_par", "s_row", "s_src")
    g.note("create_note", 0, "foot", "The row holds no name: the en label carries it, one live source per category. A handle is "
                                     "unique among live siblings, the roots counting as siblings of each other, so a retired "
                                     "handle is free again. chk_categories_path_depth stops a path at ten levels.")

    # =========================================================================
    # Words
    # =========================================================================

    rows = ["up", "main", "down", "down2", "down3", "down4", "data", "foot"]
    g = b.lane("words", "3 · Every other\nlanguage", "the engine writes them;\na person may correct one,\nversion-checked", rows)
    g.row("main", 0, [("in", "box", "from 2: an\noperation queued"),
                      ("run", "jump", "Translations:\nthe run, step\nby step", "trn_band_run"),
                      ("each", "box", "one label per\nlanguage taking\nwords"),
                      ("flag", "dia", "words\nflagged?"),
                      ("wrote", "box", "written:\nsource machine", "ok")])
    g.n("to_rev", 3, "up", "jump", "Translations:\nfailures", to="trn_band_save")
    g.e("flag", "to_rev", "yes")
    g.row("down", 0, [("put", "box", "from 1: PUT …/0193..tsh/\ntranslations/fr\n{ version: 1,\n  name: \"Tee-shirts\" }"),
                      ("lock", "box", "lock the category;\nthe locale, taking\nwords, FOR SHARE"),
                      ("isen", "dia", "the en\nsource?"),
                      ("rec", "box", "recordManual: the\nowner's lock, the\nen hashes now"),
                      ("ver", "dia", "version\nmatches?"),
                      ("tgt", "table", "write the fr label:\nsource human,\nversion + 1"),
                      ("tok", "box", "200, version 2", "ok")])
    g.n("lock_r", 1, "down2", "box", "404 CATEGORIES_\nLOCALE_NOT_FOUND", "red")
    g.e("lock", "lock_r", "no locale")
    g.n("src", 2, "down2", "table", "the en label FOR\nUPDATE, the same\nversion check")
    g.e("isen", "src", "yes")
    g.n("again", 3, "down2", "box", "written, version + 1;\na field moved:\nrequest(source_changed)")
    g.e("src", "again")
    g.n("ver_r", 4, "down2", "box", "409 CATEGORIES_\nTRANSLATION_CHANGED", "red")
    g.e("ver", "ver_r", "no")
    g.row("down3", 0, [("del", "box", "from 1: DELETE …/\n0193..tsh/translations/fr"),
                       ("dsrc", "dia", "the en\nsource?"),
                       ("dact", "dia", "fr active\nwhile shown?"),
                       ("dok", "box", "200: the fr\nlabel deleted", "ok")])
    g.n("dsrc_r", 1, "down4", "box", "409 CATEGORIES_\nTRANSLATION_IS_SOURCE", "red")
    g.e("dsrc", "dsrc_r", "yes")
    g.n("dact_r", 2, "down4", "box", "409 _TRANSLATION_\nLOCALE_ACTIVE\n{ localeCode: \"fr\" }", "red")
    g.e("dact", "dact_r", "yes")
    g.s("s_en", 0, "the en source", "{ localeCode: \"en\",\n  name: \"T-shirts\",\n  sourceHashes: {\n    name: \"4be1..\" },\n"
        "  version: 1 }")
    g.s("s_fr", 2, "fr, by the engine", "{ localeCode: \"fr\",\n  name: \"T-shirts\",\n  source: \"machine\",\n"
        "  sourceHashes: {\n    name: \"4be1..\" },\n  version: 1 }")
    g.s("s_hum", 5, "fr, after the PUT", "{ localeCode: \"fr\",\n  name: \"Tee-shirts\",\n  source: \"human\",\n"
        "  sourceHashes: {\n    name: \"4be1..\" },\n  version: 2 }", of="tgt")
    g.becomes("s_en", "s_fr", "s_hum")
    g.note("words_note", 0, "foot", "Each label keeps the hash of the en words it translates: rename the source and every other "
                                    "label goes stale by hash, and the next run rewrites exactly those. A person's label carries "
                                    "the current hashes, so the engine has nothing to redo until the source moves.")

    # =========================================================================
    # Markets
    # =========================================================================

    g = b.lane("markets", "4 · Shown in\na market", "each market decides;\nno row means hidden, so\na new category is hidden\neverywhere")
    g.row("main", 0, [("in", "box", "from 1 and 3: POST\n…/0193..tsh/markets"),
                      ("iam", "jump", "IAM: update\nmarketplaces at\nthe body's market?", "iam_band_req"),
                      ("live", "dia", "market\nlive?"),
                      ("vis", "dia", "isVisible?"),
                      ("lbl", "dia", "labels\ncomplete?"),
                      ("voc", "dia", "vocabulary\ntranslated?"),
                      ("ins", "table", "insert category_\nmarketplace_\nvisibility"),
                      ("ev", "box", "afterCommit:\ncategory.\nvisibility_changed"),
                      ("ok", "box", "200", "ok")])
    g.e("vis", "ins", "hidden", under=True)
    g.n("live_r", 2, "up", "box", "404 CATEGORIES_\nMARKETPLACE_\nNOT_FOUND", "red")
    g.e("live", "live_r", "no")
    g.n("lbl_r", 4, "up", "box", "409 CATEGORIES_\nTRANSLATION_MISSING\n{ missingLocales }", "red")
    g.e("lbl", "lbl_r", "no")
    g.n("voc_r", 5, "up", "box", "409 CATEGORIES_\nVOCABULARY_\nUNTRANSLATED", "red")
    g.e("voc", "voc_r", "no")
    g.n("ins_r", 6, "up", "box", "409 CATEGORIES_\nMARKET_TAKEN", "red")
    g.e("ins", "ins_r", "taken")
    g.s("s_body", 0, "the body", "{ marketplaceId: \"0193..fr\",\n  isVisible: true }", of="in")
    g.s("s_iam", 1, "what IAM is asked", "{ action: \"update\",\n  resource: \"marketplaces\",\n  scope: \"company.\n"
        "    marketplace.0193..fr\" }", of="iam")
    g.s("s_ev", 7, "the event", "{ categoryId: \"0193..tsh\",\n  marketplaceId: \"0193..fr\",\n"
        "  isVisible: true,\n  path: \"/0193..wom/…\n    /0193..tsh\" }", of="ev")
    g.becomes("s_body", "s_iam")
    g.note("markets_note", 0, "foot", "PATCH …/markets/0193..fr { isVisible: true } runs the same gates; hiding, and DELETE, need "
                                      "none and announce isVisible: false. Both writes take the tree lock for share, so a move "
                                      "cannot change the path between the check and the write.")

    # =========================================================================
    # Requirements
    # =========================================================================

    g = b.lane("attrs", "5 · What it\nrequires", "a requirement names a\ndefinition, and every\ncategory beneath\ninherits it")
    g.row("main", 0, [("in", "box", "from 1: PUT …/0193..clo/\nattributes/0193..mat\n{ isRequired: true }"),
                      ("lock", "box", "tree lock for update;\nthe definition\nFOR SHARE"),
                      ("shown", "dia", "shown at or\nunder it?"),
                      ("voc", "dia", "vocabulary\ntranslated?"),
                      ("ups", "table", "upsert category_\nattributes"),
                      ("ev", "box", "afterCommit:\ncategory.\nattributes_changed"),
                      ("ok", "box", "200", "ok")])
    g.e("shown", "ups", "no", under=True)
    g.n("lock_r", 1, "up", "box", "404 CATEGORIES_\nATTRIBUTE_DEFINITION_\nNOT_FOUND", "red")
    g.e("lock", "lock_r", "missing")
    g.n("voc_r", 3, "up", "box", "409 CATEGORIES_\nVOCABULARY_\nUNTRANSLATED", "red")
    g.e("voc", "voc_r", "no")
    g.n("ups_r", 4, "up", "box", "409 CATEGORIES_\nATTRIBUTE_TAKEN:\na race", "red")
    g.e("ups", "ups_r", "taken")
    g.row("down", 1, [("t_clo", "box", "Clothing:\nrequires material", "table"),
                      ("t_top", "box", "Tops:\ninherits it", "table"),
                      ("t_tsh", "box", "T-shirts:\ninherits it", "table"),
                      ("to_prd", "jump", "Products: a filing\nunder T-shirts\nowes material", "prd_band_file")])
    g.e("in", "t_clo")
    g.s("s_ev", 5, "the event", "{ categoryId: \"0193..clo\",\n  attributeDefinitionId:\n    \"0193..mat\",\n"
        "  path: \"/0193..wom\n    /0193..clo\" }", of="ev")
    g.note("attrs_note", 0, "foot", "DELETE …/attributes/0193..mat drops the requirement and announces the same event. The check "
                                    "reaches down the tree: requiring material on Clothing while T-shirts is shown in France "
                                    "needs material translated in every active language first.")

    # =========================================================================
    # Partner
    # =========================================================================

    g = b.lane("partner", "6 · A partner\nreads it", "the market's own language,\nonly what it shows,\nread only")
    g.row("main", 0, [("in", "box", "from 4: GET /marketplace/\ncategories?parentId=\n0193..top"),
                      ("host", "jump", "Host registry:\nbrands.fr.iryss.com\nis France", "hst_band_resolve"),
                      ("auth", "jump", "Auth:\nsigned in?", "auth_band_session"),
                      ("iam", "jump", "IAM: read\ncategories at\nFrance?", "iam_band_req"),
                      ("mkt", "dia", "a market\nresolved?"),
                      ("read", "table", "its children shown\nthroughout France,\nin French"),
                      ("ok", "box", "200", "ok")])
    g.n("mkt_r", 4, "up", "box", "500 CATEGORIES_\nNO_MARKET_RESOLVED:\na defect", "red")
    g.e("mkt", "mkt_r", "no")
    g.row("down", 0, [("a_in", "box", "from 5: GET /marketplace/\ncategories/0193..tsh/\nattributes"),
                      ("a_shown", "dia", "shown\nthere?"),
                      ("a_defs", "table", "every definition on\nthe path, once, in\nposition order"),
                      ("a_lbl", "dia", "a label\nin French?"),
                      ("a_opts", "box", "options with no\nFrench words\nleft off"),
                      ("a_ok", "box", "200", "ok")])
    g.n("a_shown_r", 1, "down2", "box", "404 CATEGORIES_\nNOT_FOUND: hidden\nor missing", "red")
    g.e("a_shown", "a_shown_r", "no")
    g.n("a_lbl_r", 3, "down2", "box", "500 CATEGORIES_\nMARKETPLACE_\nATTRIBUTES_\nUNTRANSLATED", "red")
    g.e("a_lbl", "a_lbl_r", "no")
    g.s("s_attrs", 5, "what France reads", "[ { code: \"material\",\n    dataType: \"option\",\n    name: \"Matière\",\n"
        "    isRequired: true,\n    options: [\n      { code: \"cotton\",\n        name: \"Coton\" },\n"
        "      { code: \"linen\",\n        name: \"Lin\" } ] } ]", of="a_ok")
    g.s("s_list", 6, "what France reads", "[ { id: \"0193..tsh\",\n    parentId: \"0193..top\",\n    handle: \"t-shirts\",\n"
        "    name: \"Tee-shirts\" } ]", of="ok")
    g.note("partner_note", 0, "foot", "shownThroughout: a category reaches a partner only while it and every ancestor are shown in "
                                      "that market, so hiding Clothing hides the branch. No parentId reads the whole visible tree, "
                                      "null the roots. A name with no French label falls back to the en source.")

    # =========================================================================
    # Move
    # =========================================================================

    g = b.lane("move", "7 · Moving a branch", "one UPDATE rewrites\nthe whole subtree")
    g.row("main", 0, [("in", "box", "from 1: POST …/\n0193..tsh/move\n{ moveTo: \"0193..bas\" }"),
                      ("self", "dia", "moveTo is\nitself?"),
                      ("lock", "box", "tree lock for update,\nbefore any path\nis read"),
                      ("paths", "box", "the target's path\nfor share, its own\nFOR UPDATE"),
                      ("under", "dia", "target under\nitself?"),
                      ("upd", "table", "one UPDATE: every\npath beneath,\nretired rows too"),
                      ("ev", "box", "afterCommit:\ncategory.moved,\nif the path changed"),
                      ("ok", "box", "200", "ok")])
    g.n("self_r", 1, "up", "box", "409 CATEGORIES_\nCYCLE", "red")
    g.e("self", "self_r", "yes")
    g.n("under_r", 4, "up", "box", "409 CATEGORIES_\nCYCLE", "red")
    g.e("under", "under_r", "yes")
    g.n("upd_r", 5, "up", "box", "422 CATEGORIES_\nTOO_DEEP: past\nten levels", "red")
    g.e("upd", "upd_r", "refused")
    g.s("s_read", 3, "what it reads", "its own path\n  /0193..wom/0193..clo\n  /0193..top/0193..tsh\nthe target's\n"
        "  /0193..wom/0193..clo\n  /0193..bas", of="paths")
    g.s("s_after", 5, "after: T-shirts and its child", "T-shirts\n  /0193..wom/0193..clo\n  /0193..bas/0193..tsh\n"
        "Crew neck\n  …/0193..bas/0193..tsh\n  /0193..crw", of="upd")
    g.s("s_ev", 6, "the event", "{ categoryId: \"0193..tsh\",\n  previousPath: \"…/0193..top\n    /0193..tsh\",\n"
        "  path: \"…/0193..bas\n    /0193..tsh\" }", of="ev")
    g.becomes("s_read", "s_after")
    g.note("move_note", 0, "foot", "PATCH changes handle, position and metadata only: a new parent is this move, a new name the "
                                   "en label's PUT. Retired rows move with the branch, so chk_categories_path_under_parent holds "
                                   "for every row, live or not.")

    # =========================================================================
    # Retire
    # =========================================================================

    g = b.lane("delete", "8 · Retiring it", "a soft delete fires no\nforeign key, so the\nservice refuses instead")
    g.row("main", 0, [("in", "box", "from 1: DELETE\n…/0193..tsh"),
                      ("soft", "box", "soft delete first:\nwrite, then check"),
                      ("kids", "dia", "live\nchildren?"),
                      ("used", "dia", "a product\nfiled here?"),
                      ("casc", "box", "retire its\nrequirements, labels\nand market rows"),
                      ("ok", "box", "200 { deletedAt }", "ok")])
    g.n("kids_r", 2, "up", "box", "409 CATEGORIES_\nHAS_CHILDREN", "red")
    g.e("kids", "kids_r", "yes")
    g.n("used_r", 3, "up", "box", "409 CATEGORIES_\nIN_USE", "red")
    g.e("used", "used_r", "yes")
    g.note("delete_note", 0, "foot", "Write first: the delete takes the row lock, so a child or a filing cannot land between the "
                                     "check and the write, and a refusal takes the write back. The market rows go unscoped, every "
                                     "market at once, since a retired category is shown nowhere.")

    # =========================================================================
    # Links
    # =========================================================================

    b.wire("req.ctrl", "create.in")
    b.wire("create.s_op", "words.in", "the engine's work")
    b.wire("req.ctrl", "words.put")
    b.wire("req.ctrl", "words.del")
    b.wire("req.ctrl", "markets.in")
    b.wire("words.s_hum", "markets.in", "every label")
    b.wire("req.ctrl", "attrs.in")
    b.wire("markets.ok", "partner.in", "shown")
    b.wire("attrs.ok", "partner.a_in", "required")
    b.wire("req.ctrl", "move.in")
    b.wire("req.ctrl", "delete.in")
    return b
