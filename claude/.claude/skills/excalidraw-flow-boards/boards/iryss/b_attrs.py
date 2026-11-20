from lib import Board


def make():
    b = Board("att", "Attributes: a kind of fact and its values")
    b.head("Attributes: a kind of fact and its values",
           "The shared vocabulary a product states its facts from: a definition is a kind of fact (material), an option one value\n"
           "of it (cotton). One global list, so no market owns a colour. Written in English; the engine writes every other language.")

    # =========================================================================
    # Map
    # =========================================================================

    g = b.lane("map", "0 · The map", "the request, then what\nit writes and who\nreads it")
    g.n("m_host", 0, "main", "jump", "Host registry:\nhost known?", to="hst_band_resolve")
    g.n("m_auth", 1, "main", "jump", "Auth:\nsigned in?", to="auth_band_session")
    g.n("m_iam", 2, "main", "jump", "IAM:\nallows?", to="iam_band_req")
    for i, (key, lane, text) in enumerate([("m1", "req", "1 · the request"), ("m2", "def", "2 · a definition,\nin English"),
                                           ("m4", "opt", "4 · its options"), ("m5", "words", "5 · every other\nlanguage")]):
        g.n(key, i + 3, "main", "box", text, to=f"att_band_{lane}")
    g.chain("m_host", "m_auth", "m_iam", "m1", "m2", "m4", "m5")
    for i, (key, lane, text) in enumerate([("m3", "types", "3 · five kinds\nof fact"), ("m6", "reads", "6 · who reads it"),
                                           ("m7", "retire", "7 · retiring a term")]):
        g.n(key, i + 3, "down", "box", text, "table", to=f"att_band_{lane}")

    # =========================================================================
    # Request
    # =========================================================================

    g = b.lane("req", "1 · The request", "every admin write here:\nthe host, the session,\nIAM, then the body")
    g.row("main", 0, [("in", "box", "POST /admin/\nattributeDefinitions"),
                      ("mw", "box", "helmet, trust proxy,\nrequest context"),
                      ("host", "jump", "Host registry:\nadmin host?", "hst_band_resolve"),
                      ("auth", "jump", "Auth:\nsigned in?", "auth_band_session"),
                      ("iam", "jump", "IAM: create\nattributeDefinitions\nat company?", "iam_band_req"),
                      ("body", "dia", "body\nvalid?"),
                      ("ctrl", "box", "the controller\nruns", "ok")])
    g.n("body_r", 5, "up", "box", "400: validateEquals\nrefuses any extra key", "red")
    g.e("body", "body_r", "no")
    g.s("s_in", 0, "the request", "POST /admin/attributeDefinitions\nHost: admin.iryss.com\n"
        "Cookie: __Host-duck-sid=<opaque>", of="in")
    g.s("s_iam", 4, "what IAM is asked", "{ action: \"create\",\n  resource: \"attributeDefinitions\",\n"
        "  scope: \"company\" }", of="iam")
    g.s("s_body", 5, "the body", "{ code: \"material\",\n  dataType: \"option\",\n  isFilterable: true,\n"
        "  name: \"Material\",\n  description: \"What it\n    is made of\" }", of="body")

    # =========================================================================
    # Definition
    # =========================================================================

    g = b.lane("def", "2 · A definition,\nin English", "create(): one transaction,\nso the label and the\nengine's operation travel\nwith the row")
    g.row("main", 0, [("in", "box", "from 1:\ncreate(body)"),
                      ("ins", "table", "insert\nattribute_definitions"),
                      ("src", "table", "insert the en label:\nisSource, human,\na hash per field"),
                      ("req", "box", "request(tx,\nsource_changed)"),
                      ("back", "box", "read it back: its\nname is the en label"),
                      ("ok", "box", "200, in English\nonly", "ok")])
    g.n("ins_r", 1, "up", "box", "422 _UNIT_MISMATCH or\n_VARIANT_DEFINING_\nREQUIRES_OPTION,\n409 _CODE_TAKEN", "red")
    g.e("ins", "ins_r", "refused")
    g.s("s_row", 1, "the definition row", "{ id: \"0193..mat\",\n  code: \"material\",\n  dataType: \"option\",\n"
        "  unit: null,\n  isFilterable: true }", of="ins")
    g.s("s_src", 2, "its en label", "{ attributeDefinitionId:\n    \"0193..mat\",\n  localeCode: \"en\",\n"
        "  isSource: true,\n  source: \"human\",\n  name: \"Material\",\n  sourceHashes: {\n    name: \"9f2c..\" },\n"
        "  version: 1 }", of="src")
    g.s("s_op", 3, "the operation, queued", "{ ownerType:\n    \"attribute_definition\",\n  ownerId: \"0193..mat\",\n"
        "  reason: \"source_changed\",\n  status: \"queued\" }", of="req")
    g.s("s_out", 5, "the answer", "{ ok: true,\n  code: \"ATTRIBUTE_\n    DEFINITIONS_\n    CREATE_SUCCEEDED\",\n"
        "  data: { code: \"material\",\n    name: \"Material\" } }", of="ok")
    g.becomes("s_row", "s_src")
    g.note("def_note", 0, "foot", "The row holds no name: name and description leave the body for the en label, one live "
                                  "source per term. code and dataType never change once written; a new kind of fact is a "
                                  "new definition.")

    # =========================================================================
    # Types
    # =========================================================================

    rows = ["r0", "r1", "r2", "r3", "r4", "data"]
    g = b.lane("types", "3 · Five kinds\nof fact", "data_type decides what a\nproduct's value holds", rows, gap=30)
    g.n("in", 0, "r0", "box", "from 2: the\nbody's dataType")
    kinds = [("text", "valueText", "care: \"wash at 30\""), ("number", "valueNumber", "thread_count: 180"),
             ("boolean", "valueBoolean", "is_organic: true"), ("option", "valueOptionId", "material: cotton"),
             ("measure", "valueNumber,\nthe unit beside it", "weight: 180 g")]
    for i, (kind, field, example) in enumerate(kinds):
        g.n(f"t{i}", 1, rows[i], "box", kind, "table")
        g.n(f"v{i}", 2, rows[i], "box", field)
        g.n(f"x{i}", 3, rows[i], "box", example)
        g.e("in", f"t{i}")
        g.e(f"t{i}", f"v{i}", "a value holds")
        g.e(f"v{i}", f"x{i}", "e.g.")
    g.n("opts", 4, "r3", "box", "the only kind\nwith options", "ok")
    g.e("x3", "opts")
    g.note("types_note", 4, "r0", "chk_attribute_definitions_unit: a unit exactly when the kind is measure.\n"
                                  "chk_attribute_definitions_variant_defining: a variant axis must be an option.\n"
                                  "Both are renames in the errors table, never a pre-check.")

    # =========================================================================
    # Options
    # =========================================================================

    g = b.lane("opt", "4 · Its options", "createOption(): only an\noption definition takes\nthem")
    g.row("main", 0, [("in", "box", "from 1: POST\n…/0193..mat/options"),
                      ("lock", "box", "lock the definition\nfor share"),
                      ("isopt", "dia", "data type\noption?"),
                      ("ins", "table", "insert\nattribute_options"),
                      ("src", "table", "insert the en label,\na hash"),
                      ("req", "box", "request(tx,\nsource_changed)"),
                      ("ev", "box", "afterCommit:\nattribute.option_added"),
                      ("ok", "box", "200", "ok")])
    g.n("isopt_r", 2, "up", "box", "422 ATTRIBUTE_DEFINITIONS_\nNOT_OPTION_TYPE", "red")
    g.e("isopt", "isopt_r", "no")
    g.n("ins_r", 3, "up", "box", "409 _OPTION_\nCODE_TAKEN", "red")
    g.e("ins", "ins_r", "unique")
    g.s("s_body", 0, "the body", "POST …/0193..mat/options\n{ code: \"cotton\",\n  name: \"Cotton\" }", of="in")
    g.s("s_opt", 3, "the option row", "{ id: \"0193..cot\",\n  attributeDefinitionId:\n    \"0193..mat\",\n"
        "  code: \"cotton\" }", of="ins")
    g.s("s_lbl", 4, "its en label", "{ attributeOptionId:\n    \"0193..cot\",\n  localeCode: \"en\",\n"
        "  isSource: true,\n  name: \"Cotton\",\n  sourceHashes: {\n    name: \"c07e..\" } }", of="src")
    g.s("s_op", 5, "the operation, queued", "{ ownerType:\n    \"attribute_option\",\n  ownerId: \"0193..cot\",\n"
        "  reason: \"source_changed\" }", of="req")
    g.s("s_ev", 6, "the event", "{ attributeDefinitionId:\n    \"0193..mat\",\n  attributeOptionId:\n    \"0193..cot\" }",
        of="ev")
    g.becomes("s_opt", "s_lbl")
    g.note("opt_note", 0, "foot", "No foreign key sees data_type, so the share lock and the check are the only backstop: "
                                  "without the lock a retire could land under the new option. Linen follows the same way.")

    # =========================================================================
    # Words
    # =========================================================================

    g = b.lane("words", "5 · Every other\nlanguage", "the engine writes them in\nthe background; a create\nwaits for none")
    g.row("main", 0, [("in", "box", "from 2 and 4: an\noperation queued"),
                      ("run", "jump", "Translations:\nthe run, step\nby step", "trn_band_run"),
                      ("each", "box", "one row per\nlanguage taking\nwords"),
                      ("flag", "dia", "words\nflagged?"),
                      ("ok", "box", "written:\nsource machine", "ok")])
    g.n("to_rev", 3, "up", "jump", "Translations:\nfailures", to="trn_band_save")
    g.e("flag", "to_rev", "yes: written\nnowhere")
    g.n("put", 0, "down", "box", "PUT …/translations/fr\n{ version: 1,\n  name: \"Matière\" }")
    g.n("to_man", 1, "down", "jump", "Translations: a\nperson's words", to="trn_band_in")
    g.e("put", "to_man")
    g.n("to_words", 2, "down", "jump", "Translations: every\nlanguage's words", to="trn_band_ops")
    g.e("to_man", "to_words")
    g.s("s_en", 0, "the source", "{ localeCode: \"en\",\n  name: \"Material\",\n  sourceHashes: {\n"
        "    name: \"9f2c..\" } }", slot="data")
    g.s("s_fr", 2, "written for fr", "{ localeCode: \"fr\",\n  name: \"Matière\",\n  source: \"machine\",\n"
        "  sourceHashes: {\n    name: \"9f2c..\" } }", slot="data")
    g.s("s_de", 4, "and for de", "{ localeCode: \"de\",\n  name: \"Material\",\n  source: \"machine\",\n"
        "  sourceHashes: {\n    name: \"9f2c..\" } }", slot="data")
    g.becomes("s_en", "s_fr", "s_de")
    g.note("words_note", 0, "foot", "Each row keeps the hash of the words it translates: rename the source and every other "
                                    "row goes stale by hash, and the next run rewrites exactly those fields. A gap reaches no "
                                    "shopper: approve refuses a product using a term short of an active language.")

    # =========================================================================
    # Reads
    # =========================================================================

    rows = ["r0", "r1", "r2", "r3", "data"]
    g = b.lane("reads", "6 · Who reads it", "a partner never reads the\nlist: only what a\ncategory demands", rows, gap=30)
    g.n("src", 0, "r0", "box", "from 5: a live\ndefinition, its options")
    g.n("admin", 1, "r0", "box", "admin list and get:\nq matches the code, the id\nor a label in any language")
    g.e("src", "admin")
    g.n("to_req", 1, "r1", "jump", "Categories: a\nrequirement names it", to="cat_band_attrs")
    g.e("src", "to_req")
    g.n("to_part", 1, "r2", "jump", "Categories: a partner\nreads it, in the\nmarket's language", to="cat_band_partner")
    g.e("src", "to_part")
    g.n("to_val", 1, "r3", "jump", "Products: a draft's\nvalue names it", to="prd_band_draft")
    g.e("src", "to_val")

    # =========================================================================
    # Retire
    # =========================================================================

    g = b.lane("retire", "7 · Retiring a term", "a soft delete fires no\nforeign key, so the\nservice refuses instead")
    g.row("main", 0, [("in", "box", "from 1: DELETE\n…/0193..mat"),
                      ("soft", "box", "soft delete first:\nwrite, then check"),
                      ("opts", "dia", "live\noptions?"),
                      ("cat", "dia", "a category\nrequires it?"),
                      ("used", "dia", "a product\nvalue names it?"),
                      ("casc", "box", "retire its\ntranslations"),
                      ("ok", "box", "200 { deletedAt }", "ok")])
    g.n("opts_r", 2, "up", "box", "409 _HAS_OPTIONS", "red")
    g.e("opts", "opts_r", "yes")
    g.n("cat_r", 3, "up", "box", "409 _REQUIRED_\nBY_CATEGORIES", "red")
    g.e("cat", "cat_r", "yes")
    g.n("used_r", 4, "up", "box", "409 ATTRIBUTE_\nDEFINITIONS_IN_USE", "red")
    g.e("used", "used_r", "yes")
    g.row("down", 0, [("o_in", "box", "DELETE …/options/\n0193..lin")], chain=False)
    g.n("o_used", 4, "down", "dia", "a product\nvalue names it?")
    g.n("o_casc", 5, "down", "box", "retire its\ntranslations")
    g.n("o_ok", 6, "down", "box", "200 + attribute.\noption_removed", "ok")
    g.chain("o_in", "o_used", "o_casc", "o_ok")
    g.n("o_used_r", 4, "down2", "box", "409 _OPTION_IN_USE", "red")
    g.e("o_used", "o_used_r", "yes")
    g.note("retire_note", 0, "foot", "Write first: the delete takes the row lock, so an option create or a product value "
                                     "naming the term queues behind it rather than landing between check and write, and "
                                     "a refusal takes the write back. A retired code is free to reuse.")

    # =========================================================================
    # Links
    # =========================================================================

    b.wire("req.ctrl", "def.in", "create")
    b.wire("req.ctrl", "opt.in", "createOption")
    b.wire("req.ctrl", "retire.in", "delete")
    b.wire("def.in", "types.in", "its dataType")
    b.wire("def.s_op", "words.in", "the engine's work")
    b.wire("opt.s_op", "words.in")
    b.wire("words.ok", "reads.src", "read by")
    return b
