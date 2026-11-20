from lib import Board


def make():
    b = Board("prd", "Products: an identity, a draft, a live version")
    b.head("Products: an identity, a draft, a live version",
           "A product is the brand's identity (Acme Basic Tee, sequence 42); its words and values live in two stages, draft and live.\n"
           "A draft is edited under one counter, submitted, then approved, and approval swaps the stages and moves the urls.")

    # =========================================================================
    # Map
    # =========================================================================

    g = b.lane("map", "0 · The map", "the request, then what\nit writes and who\nreads it")
    g.n("m_host", 0, "main", "jump", "Host registry:\nhost known?", to="hst_band_resolve")
    g.n("m_auth", 1, "main", "jump", "Auth:\nsigned in?", to="auth_band_session")
    g.n("m_iam", 2, "main", "jump", "IAM:\nallows?", to="iam_band_req")
    main = [("m1", "req", "1 · the request"), ("m2", "create", "2 · a product,\nits first draft"),
            ("m6", "review", "6 · submit\nfor review"), ("m7", "approve", "7 · approve: the\ndraft goes live"),
            ("m11", "partner", "11 · a partner\nreads it")]
    for i, (key, lane, text) in enumerate(main):
        g.n(key, i + 3, "main", "box", text, to=f"prd_band_{lane}")
    g.chain("m_host", "m_auth", "m_iam", *[k for k, _, _ in main])
    side = [("m3", "file", "3 · filed in\na category"), ("m4", "draft", "4 · a draft\nvalue"),
            ("m5", "words", "5 · draft words"), ("m8", "slugs", "8 · the url"), ("m9", "next", "9 · the next\nversion"),
            ("m10", "status", "10 · live in the\ncatalogue"), ("m12", "delete", "12 · deleting it")]
    for i, (key, lane, text) in enumerate(side):
        g.n(key, i + 3, "down", "box", text, "table", to=f"prd_band_{lane}")

    # =========================================================================
    # Request
    # =========================================================================

    g = b.lane("req", "1 · The request", "every admin write here:\nthe host, the session,\nIAM, then the body")
    g.row("main", 0, [("in", "box", "POST /admin/\nproducts"),
                      ("mw", "box", "helmet, trust proxy,\nrequest context"),
                      ("host", "jump", "Host registry:\nadmin host?", "hst_band_resolve"),
                      ("auth", "jump", "Auth:\nsigned in?", "auth_band_session"),
                      ("iam", "jump", "IAM: create\nproducts\nat company?", "iam_band_req"),
                      ("body", "dia", "body\nvalid?"),
                      ("ctrl", "box", "the controller\nruns", "ok")])
    g.n("body_r", 5, "up", "box", "400: validateEquals\nrefuses any extra key", "red")
    g.e("body", "body_r", "no")
    g.s("s_in", 0, "the request", "POST /admin/products\nHost: admin.iryss.com\nCookie: __Host-duck-sid=<opaque>", of="in")
    g.s("s_iam", 4, "what IAM is asked", "{ action: \"create\",\n  resource: \"products\",\n  scope: \"company\" }", of="iam")
    g.s("s_body", 5, "the body", "{ brandId: \"0193..acm\",\n  brandReference: \"B00042\",\n  locales: [\n"
        "    { localeCode: \"en\",\n      isSource: true,\n      title: \"Acme Basic Tee\",\n      slug: \"acme-basic-tee\",\n"
        "      source: \"brand\" },\n    { localeCode: \"fr\",\n      title: \"Acme Basic Tee\",\n      translatedFrom: \"en\",\n"
        "      source: \"brand\" },\n    … de, it, es ],\n  attributes: [\n    { attributeDefinitionId:\n        \"0193..mat\",\n"
        "      valueOptionId:\n        \"0193..cot\",\n      source: \"brand\" } ] }", of="body")
    g.note("req_note", 0, "foot", "Every product route asks about products at company, each with its own action: create; update "
                                  "for every draft, filing and url write and for submit; enable to activate or approve; disable "
                                  "to archive or reject; delete. Approving is enable, not update, so a role may edit and submit "
                                  "without the right to publish.")

    # =========================================================================
    # Create
    # =========================================================================

    g = b.lane("create", "2 · A product,\nits first draft", "create(): one transaction,\nso the identity, its\nfirst version and the\ndraft land together")
    g.row("main", 0, [("in", "box", "from 1:\ncreate(body)"),
                      ("chk", "dia", "languages and\nvalues valid?"),
                      ("ctr", "table", "brands.product_\ncounter + 1,\nRETURNING"),
                      ("prod", "table", "insert products:\ndraft, sequence 42"),
                      ("ver", "table", "insert product_\nversions: a draft"),
                      ("cont", "table", "insert the draft\nvalues and words"),
                      ("iss", "dia", "content\ncomplete?"),
                      ("ev", "box", "afterCommit:\nproduct.created"),
                      ("ok", "box", "200 +\ndraftVersionId", "ok")])
    g.n("chk_r", 1, "up", "box", "404 _LOCALE_NOT_FOUND,\n_ATTRIBUTE_NOT_FOUND;\n422 _TYPE_MISMATCH,\n"
                                "_OPTION_MISMATCH,\n_VARIANT_DEFINING", "red")
    g.e("chk", "chk_r", "no")
    g.n("ctr_r", 2, "up", "box", "404 PRODUCTS_\nBRAND_NOT_FOUND,\n409 _SEQUENCE_\nEXHAUSTED", "red")
    g.e("ctr", "ctr_r", "refused")
    g.n("prod_r", 3, "up", "box", "409 PRODUCTS_\nBRAND_REFERENCE_\nTAKEN", "red")
    g.e("prod", "prod_r", "taken")
    g.n("cont_r", 5, "up", "box", "409 PRODUCT_LOCALES_\nDUPLICATE,\n_SOURCE_TAKEN;\n422 _SOURCE_\nTRANSLATED", "red")
    g.e("cont", "cont_r", "refused")
    g.n("iss_r", 6, "up", "box", "422 PRODUCTS_\nCONTENT_INVALID\n{ issues }", "red")
    g.e("iss", "iss_r", "no")
    g.s("s_ctr", 2, "the brand's counter", "UPDATE brands\nSET product_counter =\n  product_counter + 1\n"
        "WHERE id = '0193..acm'\nRETURNING product_counter\n41 → 42", of="ctr")
    g.s("s_prod", 3, "the product row", "{ id: \"0193..abt\",\n  brandId: \"0193..acm\",\n  sequence: 42,\n"
        "  brandReference:\n    \"B00042\",\n  status: \"draft\",\n  productVersion: 1 }", of="prod")
    g.s("s_ver", 4, "its first version", "{ id: \"0193..v1\",\n  productId: \"0193..abt\",\n  status: \"draft\",\n"
        "  productVersion: null }", of="ver")
    g.s("s_cont", 5, "the draft stage", "product_attribute_values\n  material = cotton,\n    source brand\n"
        "product_locales\n  en  isSource, brand\n  fr  from en, brand\n  de, it, es", of="cont")
    g.s("s_ev", 7, "the event", "{ productId: \"0193..abt\",\n  brandId: \"0193..acm\",\n  versionId: \"0193..v1\" }", of="ev")
    g.becomes("s_ctr", "s_prod", "s_ver", "s_cont")
    g.note("create_note", 0, "foot", "The sequence is the brand's counter, never max(sequence) + 1: the brand's row lock "
                                     "serialises two creates. The draft must already speak every active language and name "
                                     "its source. title answers null until the first approval, since it is read from the "
                                     "live words.")

    # =========================================================================
    # Filing
    # =========================================================================

    g = b.lane("file", "3 · Filed in\na category", "a filing binds: an\napproved product must\nalready hold what the\ncategory requires")
    g.row("main", 0, [("in", "box", "from 1: POST …/0193..abt/\ncategories\n{ categoryId: \"0193..tsh\",\n  isPrimary: true }"),
                      ("lock", "box", "lock the product\nfor share"),
                      ("cat", "dia", "category\nlive?"),
                      ("unmet", "dia", "requirements\nunmet?"),
                      ("prim", "box", "isPrimary: demote\nthe current primary"),
                      ("ins", "table", "insert product_\ncategories"),
                      ("ok", "box", "200", "ok")])
    g.n("cat_r", 2, "up", "box", "404 PRODUCTS_\nCATEGORY_NOT_FOUND", "red")
    g.e("cat", "cat_r", "no")
    g.n("unmet_r", 3, "up", "box", "409 PRODUCTS_\nCATEGORY_CHANGE_\nREFUSED", "red")
    g.e("unmet", "unmet_r", "yes")
    g.n("ins_r", 5, "up", "box", "409 _CATEGORY_\nALREADY_FILED,\n_PRIMARY_CATEGORY_\nTAKEN: a race", "red")
    g.e("ins", "ins_r", "taken")
    g.s("s_refused", 3, "the refusal's detail", "{ categoryId: \"0193..tsh\",\n  missing: [ {\n    attributeCode:\n"
        "      \"composition\",\n    requiredBy: \"0193..clo\",\n    stage: \"live\" } ] }", slot="up2", of="unmet_r")
    g.n("to_req", 3, "down", "jump", "Categories: what\nT-shirts requires", to="cat_band_attrs")
    g.e("unmet", "to_req")
    g.s("s_row", 5, "the filing", "{ productId: \"0193..abt\",\n  categoryId: \"0193..tsh\",\n  isPrimary: true }", of="ins")
    g.note("file_note", 0, "foot", "Only a product with an approved version is checked, against its live values; a draft owes "
                                   "its values at submit. An active product keeps a primary filing, so a PATCH or DELETE taking "
                                   "it away answers 409 PRODUCTS_PRIMARY_CATEGORY_REQUIRED. Filings hard-delete: every one binds.")

    # =========================================================================
    # Draft value
    # =========================================================================

    g = b.lane("draft", "4 · A draft value", "a fact from the shared\nvocabulary, written to\nthe draft stage only")
    g.row("main", 0, [("in", "box", "from 1: PUT …/versions/\n0193..v1/attributes/\nmaterial"),
                      ("def", "dia", "definition\nlive?"),
                      ("fit", "dia", "value fits\nits kind?"),
                      ("guard", "box", "bump the counter\nwhere it still\nmatches"),
                      ("open", "dia", "still a\ndraft?"),
                      ("opt", "dia", "its own\noption?"),
                      ("ups", "table", "upsert one row\nper option"),
                      ("ok", "box", "200", "ok")])
    g.n("def_r", 1, "up", "box", "404 PRODUCT_VERSIONS_\nATTRIBUTE_NOT_FOUND", "red")
    g.e("def", "def_r", "no")
    g.n("fit_r", 2, "up", "box", "422 _TYPE_MISMATCH,\n_VARIANT_DEFINING", "red")
    g.e("fit", "fit_r", "no")
    g.n("guard_r", 3, "up", "box", "409 PRODUCTS_\nSTALE_VERSION", "red")
    g.e("guard", "guard_r", "stale")
    g.n("open_r", 4, "up", "box", "409 PRODUCT_\nVERSIONS_NOT_DRAFT", "red")
    g.e("open", "open_r", "no")
    g.n("opt_r", 5, "up", "box", "422 _OPTION_\nMISMATCH", "red")
    g.e("opt", "opt_r", "no")
    g.n("ups_r", 6, "up", "box", "422 _CONFIDENCE_\nMISMATCH", "red")
    g.e("ups", "ups_r", "refused")
    g.n("to_types", 2, "down", "jump", "Attributes: five\nkinds of fact", to="att_band_types")
    g.e("fit", "to_types")
    g.n("to_opt", 5, "down", "jump", "Attributes:\nits options", to="att_band_opt")
    g.e("opt", "to_opt")
    g.s("s_body", 0, "the body", "{ productVersion: 1,\n  valueOptionId: \"0193..lin\",\n  source: \"operator\" }", of="in")
    g.s("s_sql", 3, "the guard", "UPDATE products\nSET product_version =\n  product_version + 1\n"
        "WHERE id = '0193..abt'\n  AND product_version = 1\nRETURNING → 2", of="guard")
    g.s("s_old", 5, "material, before", "[ { valueOptionId:\n      \"0193..cot\",\n    source: \"brand\" } ]")
    g.s("s_vals", 6, "after: linen joins it", "[ { valueOptionId:\n      \"0193..cot\",\n    source: \"brand\" },\n"
        "  { valueOptionId:\n      \"0193..lin\",\n    source: \"operator\" } ]", of="ups")
    g.becomes("s_old", "s_vals")
    g.note("draft_note", 0, "foot", "Every draft write runs this guard: the counter moves only where it still matches what the "
                                    "editor read, so two editors cannot both pass. An option kind holds one row per option, so "
                                    "cotton leaves by DELETE …/attributes/material?valueOptionId=0193..cot, and a DELETE "
                                    "without it answers 422 _OPTION_REQUIRED.")

    # =========================================================================
    # Draft words
    # =========================================================================

    g = b.lane("words", "5 · Draft words", "the brand or a person\nwrites each language;\nthe engine never does")
    g.row("main", 0, [("in", "box", "from 1: PUT …/versions/\n0193..v1/locales/fr"),
                      ("guard", "box", "the same counter\nguard: 2 → 3"),
                      ("open", "dia", "still a\ndraft?"),
                      ("lang", "dia", "fr and en\ntake words?"),
                      ("ups", "table", "upsert the fr\ndraft words"),
                      ("ok", "box", "200", "ok")])
    g.n("guard_r", 1, "up", "box", "409 PRODUCTS_\nSTALE_VERSION", "red")
    g.e("guard", "guard_r", "stale")
    g.n("open_r", 2, "up", "box", "409 PRODUCT_\nVERSIONS_NOT_DRAFT", "red")
    g.e("open", "open_r", "no")
    g.n("lang_r", 3, "up", "box", "404 PRODUCT_VERSIONS_\nLOCALE_NOT_FOUND", "red")
    g.e("lang", "lang_r", "no")
    g.n("ups_r", 4, "up", "box", "409 PRODUCT_LOCALES_\nSOURCE_TAKEN; 422\n_SOURCE_TRANSLATED,\n_TRANSLATED_FROM_\nITSELF", "red")
    g.e("ups", "ups_r", "refused")
    g.s("s_body", 0, "the body", "{ productVersion: 2,\n  title: \"T-shirt\n    basique Acme\",\n"
        "  slug: \"t-shirt-basique-\n    acme\",\n  source: \"operator\",\n  translatedFrom: \"en\" }", of="in")
    g.s("s_row", 4, "the fr draft row", "{ productId: \"0193..abt\",\n  stage: \"draft\",\n  localeCode: \"fr\",\n"
        "  isSource: false,\n  title: \"T-shirt\n    basique Acme\",\n  slug: \"t-shirt-basique-\n    acme\",\n"
        "  source: \"operator\",\n  translatedFrom: \"en\" }", of="ups")
    g.becomes("s_body", "s_row")
    g.note("words_note", 0, "foot", "Product words are the brand's or a person's: source names who wrote each language and "
                                    "translatedFrom the one it came from. One source per stage. The slug here is only a "
                                    "proposal; it becomes a url when the version is approved.")

    # =========================================================================
    # Review
    # =========================================================================

    g = b.lane("review", "6 · Submit\nfor review", "the draft is checked\nwhole, then waits for\nan approver or a\nrejection")
    g.row("main", 0, [("in", "box", "from 4 and 5: POST …/\nversions/0193..v1/submit\n{ productVersion: 3 }"),
                      ("guard", "box", "the counter:\n3 → 4"),
                      ("open", "dia", "still a\ndraft?"),
                      ("iss", "dia", "content\ncomplete?"),
                      ("set", "table", "status in_review,\nproductVersion 4"),
                      ("ev", "box", "afterCommit:\nproduct.version_\nsubmitted"),
                      ("ok", "box", "200", "ok")])
    g.n("guard_r", 1, "up", "box", "409 PRODUCTS_\nSTALE_VERSION", "red")
    g.e("guard", "guard_r", "stale")
    g.n("open_r", 2, "up", "box", "409 PRODUCT_\nVERSIONS_NOT_DRAFT", "red")
    g.e("open", "open_r", "no")
    g.n("iss_r", 3, "up", "box", "422 PRODUCT_VERSIONS_\nCONTENT_INVALID", "red")
    g.e("iss", "iss_r", "no")
    g.s("s_issues", 3, "what it lists", "{ issues: [\n  { code: \"REQUIRED_\n      ATTRIBUTE_MISSING\",\n"
        "    attributeCode:\n      \"composition\",\n    requiredBy: \"0193..clo\" },\n  { code: \"LOCALES_MISSING\",\n"
        "    missing: [\"it\"] } ] }", slot="up2", of="iss_r")
    g.row("down", 0, [("r_in", "box", "POST …/0193..v1/reject\n{ productVersion: 4,\n  reason }"),
                      ("r_lock", "dia", "in review at\nthis counter?"),
                      ("r_snap", "table", "the draft stage\nfreezes into the\nsnapshot, then clears"),
                      ("r_ok", "box", "200 + product.\nversion_rejected", "ok")])
    g.n("r_lock_r", 1, "down2", "box", "409 _WRONG_STATUS\nor STALE_VERSION", "red")
    g.e("r_lock", "r_lock_r", "no")
    g.s("s_rej", 2, "the rejected version", "{ status: \"rejected\",\n  rejectionReason:\n"
        "    \"Composition missing\",\n  rejectedBy: \"0193..u2\",\n  snapshot: { locales,\n    values } }", of="r_snap")
    g.s("s_ver", 4, "the version, submitted", "{ id: \"0193..v1\",\n  status: \"in_review\",\n  productVersion: 4 }", of="set")
    g.note("review_note", 0, "foot", "Submit records the bumped counter on the version, and approve and reject must send exactly "
                                     "that number, so the decision is about the submission the approver read. "
                                     "Reject needs an actor; it leaves the draft stage empty, kept only in the snapshot.")

    # =========================================================================
    # Approve
    # =========================================================================

    g = b.lane("approve", "7 · Approve: the\ndraft goes live", "one transaction swaps\nthe stages; the first\napproval is shown")
    g.row("main", 0, [("in", "box", "from 6: POST …/versions/\n0193..v1/approve\n{ productVersion: 4 }"),
                      ("lock", "dia", "in review at\nthis counter?"),
                      ("iss", "dia", "content and\nvocabulary?"),
                      ("sup", "table", "the approved one:\nsuperseded, the live\nwords its snapshot"),
                      ("swap", "table", "live stage cleared;\ndraft words and\nvalues become live"),
                      ("appr", "table", "this version:\napproved, by, at"),
                      ("slugs", "box", "setLiveSlugs: the\nlanguages whose\nslug moved"),
                      ("ev", "box", "afterCommit:\nproduct.version_\napproved"),
                      ("ok", "box", "200", "ok")])
    g.n("lock_r", 1, "up", "box", "409 _WRONG_STATUS\nor STALE_VERSION", "red")
    g.e("lock", "lock_r", "no")
    g.n("iss_r", 2, "up", "box", "422 PRODUCT_VERSIONS_\nCONTENT_INVALID", "red")
    g.e("iss", "iss_r", "no")
    g.s("s_voc", 2, "only approve asks this", "{ code: \"VOCABULARY_\n    UNTRANSLATED\",\n  terms: [ {\n"
        "    ownerType:\n      \"attribute_option\",\n    ownerId: \"0193..lin\",\n    missing: [\"it\"] } ] }",
        slot="up2", of="iss_r")
    g.n("to_loc", 2, "down", "jump", "Translations: a\nlanguage goes live", to="trn_band_loc")
    g.e("iss", "to_loc")
    g.s("s_sup", 3, "superseded", "the first approval:\nnothing to supersede.\nlater: { status:\n"
        "  \"superseded\",\n  snapshot: { locales,\n    values } }", of="sup")
    g.s("s_live", 4, "the live stage, now", "en  Acme Basic Tee\nfr  T-shirt basique\n    Acme\nde, it, es\n"
        "material: cotton,\n  linen", of="swap")
    g.s("s_appr", 5, "the version", "{ id: \"0193..v1\",\n  status: \"approved\",\n  productVersion: 4,\n"
        "  approvedBy: \"0193..u2\" }", of="appr")
    g.s("s_slug", 6, "product_slugs, live", "en  acme-basic-tee\nfr  t-shirt-basique-\n      acme\n"
        "one slug_changed each\n{ from: null, to: … }", of="slugs")
    g.s("s_ev", 7, "the event", "{ versionId: \"0193..v1\",\n  productVersion: 4,\n  localeCodes: [\"de\", \"en\",\n"
        "    \"es\", \"fr\", \"it\"] }", of="ev")
    g.note("approve_note", 0, "foot", "Content is checked again here, not only at submit: a language switched on or a "
                                      "requirement added since refuses, and so does a value whose words are untranslated. "
                                      "Urls move inside the transaction and the events go after commit. Approving needs an "
                                      "actor (500 _NO_ACTOR).")

    # =========================================================================
    # Url
    # =========================================================================

    g = b.lane("slugs", "8 · The url", "kept forever: a moved\nurl retires, never\nfrees")
    g.row("main", 0, [("in", "box", "from 1 and 7: PUT …/\n0193..abt/slugs/en\n{ slug: \"acme-classic-tee\" }"),
                      ("lock", "box", "lock the product\nFOR UPDATE"),
                      ("lang", "dia", "en takes\nwords?"),
                      ("ret", "table", "retire the live\nrow"),
                      ("live", "table", "restore its own\nretired row, or\ninsert a new one"),
                      ("ev", "box", "afterCommit:\nproduct.slug_changed"),
                      ("ok", "box", "200", "ok")])
    g.n("lang_r", 2, "up", "box", "404 PRODUCTS_\nLOCALE_NOT_FOUND", "red")
    g.e("lang", "lang_r", "no")
    g.n("live_r", 4, "up", "box", "409 PRODUCT_SLUGS_\nTAKEN: another\nproduct's, ever;\n_CONFLICT: a race", "red")
    g.e("live", "live_r", "refused")
    g.row("down", 0, [("d_in", "box", "DELETE …/0193..abt/\nslugs/en"),
                      ("d_ret", "table", "retire the live row"),
                      ("d_ok", "box", "200 + slug_changed\n{ to: null }", "ok")])
    g.s("s_before", 3, "en, before", "[ { slug:\n    \"acme-basic-tee\",\n  deletedAt: null } ]", of="ret")
    g.s("s_after", 4, "en, after", "[ { slug:\n    \"acme-basic-tee\",\n  deletedAt:\n    \"2026-10-08…\" },\n"
        "  { slug:\n    \"acme-classic-tee\",\n  deletedAt: null } ]", of="live")
    g.s("s_ev", 5, "the event", "{ productId: \"0193..abt\",\n  localeCode: \"en\",\n  from: \"acme-basic-tee\",\n"
        "  to: \"acme-classic-tee\" }", of="ev")
    g.becomes("s_before", "s_after")
    g.note("slugs_note", 0, "foot", "uq_product_slugs_locale_slug is not partial: a retired url stays this product's, so no "
                                    "other product is ever handed it and an old link can still 301. product.slug_changed is "
                                    "the whole input to the storefront's 301. Approval runs the same retire and insert.")

    # =========================================================================
    # Next version
    # =========================================================================

    g = b.lane("next", "9 · The next version", "live stays live while a\ncopy of it is edited")
    g.row("main", 0, [("in", "box", "from 7: POST …/0193..abt/\nversions\n{ productVersion: 5 }"),
                      ("guard", "box", "the counter:\n5 → 6"),
                      ("ins", "table", "insert a draft\nversion"),
                      ("copy", "table", "copy the live words\nand values into the\ndraft stage"),
                      ("ev", "box", "afterCommit:\nproduct.version_\ncreated"),
                      ("ok", "box", "200", "ok")])
    g.n("guard_r", 1, "up", "box", "409 PRODUCTS_\nSTALE_VERSION", "red")
    g.e("guard", "guard_r", "stale")
    g.n("ins_r", 2, "up", "box", "409 PRODUCT_\nVERSIONS_ALREADY_\nOPEN: one at a time", "red")
    g.e("ins", "ins_r", "taken")
    g.s("s_ver", 2, "the second version", "{ id: \"0193..v2\",\n  status: \"draft\",\n  productVersion: null }", of="ins")
    g.s("s_copy", 3, "the draft stage, again", "en, fr, de, it, es\nmaterial: cotton,\n  linen", of="copy")
    g.note("next_note", 0, "foot", "A language switched off since is not copied, and a translatedFrom naming one is cleared. "
                                   "The open-version index keeps one draft or review per product.")

    # =========================================================================
    # Status
    # =========================================================================

    g = b.lane("status", "10 · Live in the\ncatalogue", "status is the product's\nown switch, apart from\nits versions")
    g.row("main", 0, [("in", "box", "from 1: POST …/\n0193..abt/activate"),
                      ("lock", "box", "lock the product\nFOR UPDATE"),
                      ("already", "dia", "already\nactive?"),
                      ("prim", "dia", "a primary\nfiling?"),
                      ("set", "table", "status active"),
                      ("ev", "box", "afterCommit:\nproduct.activated"),
                      ("ok", "box", "200", "ok")])
    g.n("same", 2, "up", "box", "returned as is,\nno event", "gray")
    g.e("already", "same", "yes")
    g.n("prim_r", 3, "up", "box", "409 PRODUCTS_\nPRIMARY_CATEGORY_\nREQUIRED", "red")
    g.e("prim", "prim_r", "no")
    g.row("down", 0, [("a_in", "box", "POST …/0193..abt/\narchive"),
                      ("a_set", "table", "status archived:\nno gate"),
                      ("a_ok", "box", "200 + product.\narchived", "ok")])
    g.s("s_row", 4, "the product row", "{ id: \"0193..abt\",\n  sequence: 42,\n  status: \"active\" }", of="set")
    g.note("status_note", 0, "foot", "Activating asks only for a primary filing. A partner sees an active product only in a "
                                     "language it has live words in, so it still needs an approved version.")

    # =========================================================================
    # Partner
    # =========================================================================

    g = b.lane("partner", "11 · A partner\nreads it", "active, live words in\nthe market's language,\nread only")
    g.row("main", 0, [("in", "box", "from 7 and 10: GET\n/marketplace/products\nHost: brands.fr.iryss.com"),
                      ("host", "jump", "Host registry:\nbrands.fr.iryss.com\nis France", "hst_band_resolve"),
                      ("auth", "jump", "Auth:\nsigned in?", "auth_band_session"),
                      ("iam", "jump", "IAM: read\nproducts at\nFrance?", "iam_band_req"),
                      ("mkt", "dia", "a market\nresolved?"),
                      ("loc", "box", "the market's\ndefault locale:\nfr"),
                      ("read", "table", "active products with\nlive words in fr,\ntheir fr url"),
                      ("ok", "box", "200, a page", "ok")])
    g.n("mkt_r", 4, "up", "box", "500 PRODUCTS_\nNO_MARKET_RESOLVED:\na defect", "red")
    g.e("mkt", "mkt_r", "no")
    g.n("loc_r", 5, "up", "box", "500 PRODUCTS_\nNO_DEFAULT_LOCALE", "red")
    g.e("loc", "loc_r", "no row")
    g.row("down", 0, [("g_in", "box", "GET /marketplace/\nproducts/0193..abt"),
                      ("g_read", "dia", "active, with\nfr words?"),
                      ("g_ok", "box", "200, the same view", "ok")])
    g.n("g_r", 1, "down2", "box", "404 PRODUCTS_\nNOT_FOUND", "red")
    g.e("g_read", "g_r", "no")
    g.s("s_view", 7, "what France reads", "{ id: \"0193..abt\",\n  brandId: \"0193..acm\",\n  brand: { code: \"acme\",\n"
        "    name: \"Acme\" },\n  title: \"T-shirt\n    basique Acme\",\n  description: \"…\",\n"
        "  slug: \"t-shirt-basique-\n    acme\" }", of="ok")
    g.note("partner_note", 0, "foot", "The url is the slug row, not the words' proposal, so an admin correction lands there "
                                      "alone. A product with no live words in fr is left out of the page and of its count.")

    # =========================================================================
    # Delete
    # =========================================================================

    g = b.lane("delete", "12 · Deleting it", "the identity retires;\nits urls are never\nhanded on")
    g.row("main", 0, [("in", "box", "from 1: DELETE\n…/0193..abt"),
                      ("actor", "dia", "an actor?"),
                      ("lock", "box", "lock FOR UPDATE,\nbump the counter"),
                      ("soft", "table", "soft delete\nthe product"),
                      ("rej", "table", "reject the open\nversion: \"The product\nwas deleted.\""),
                      ("slugs", "table", "retire its urls,\ndelete its filings"),
                      ("ok", "box", "200 { deletedAt }", "ok")])
    g.n("actor_r", 1, "up", "box", "500 PRODUCTS_\nNO_ACTOR", "red")
    g.e("actor", "actor_r", "no")
    g.note("delete_note", 0, "foot", "The lock comes first, so every content write is done or refused: each one's guard skips "
                                     "a deleted product. Bumping the counter closes the open draft at a number no version "
                                     "holds yet.")

    # =========================================================================
    # Links
    # =========================================================================

    b.wire("req.ctrl", "create.in", "create")
    b.wire("req.ctrl", "file.in", "file it")
    b.wire("create.ok", "draft.in", "edit the draft")
    b.wire("draft.ok", "review.in", "submit")
    b.wire("words.ok", "review.in")
    b.wire("review.ok", "approve.in", "approve")
    b.wire("approve.s_slug", "slugs.ret", "setLiveSlugs")
    b.wire("approve.ok", "next.in", "edit again")
    b.wire("file.ok", "status.in", "a primary filing")
    b.wire("status.ok", "partner.in", "active")
    b.wire("approve.ok", "partner.in", "live words")
    b.wire("req.ctrl", "delete.in", "delete")
    return b
