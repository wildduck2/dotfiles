from lib import Board


def make():
    b = Board("trn", "Translations: the engine", x0=360, square=True)
    b.head("Translations: the engine",
           "Built, plan 25 stage 1: modules/translations and infrastructure/translations. A source saved in English queues its owner "
           "once the write commits; one worker\ntranslates it into every language taking words, memory first, Gemini after, and "
           "the words go live at once as machine words. Owners: attribute definitions, options, categories.")
    b.legend = [("rectangle", "plain", "step"), ("diamond", "plain", "decision"), ("ellipse", "table", "table"),
                ("rectangle", "red", "refused"), ("rectangle", "ok", "success"), ("rectangle", "gray", "dead end"),
                ("ellipse", "jump", "other board")]

    g = b.lane("map", "0 · The map", "each box is a lane below")
    main = [("m1", "req", "1 · every call:\nhost, auth,\nIAM, body"), ("m2", "in", "2 · a source saved,\nor a person's\nwords"),
            ("m3", "job", "3 · a job added;\nBullMQ runs one\nat a time"), ("m4", "run", "4 · a run: what is\ndue, memory first"),
            ("m5", "tr", "5 · the Translator:\none call per owner\nand language"),
            ("m6", "save", "6 · each owner and\nlanguage saved\nalone")]
    for i, (key, lane, text) in enumerate(main):
        g.n(key, i, "main", "box", text, to=f"trn_band_{lane}")
    g.chain(*[k for k, _, _ in main])
    g.n("m7", 2, "up", "box", "7 · an operator\nwatches and\nretries", to="trn_band_ops")
    g.n("m8", 2, "down", "box", "8 · a language\ngoes live", to="trn_band_loc")
    g.e("m1", "m7")
    g.e("m1", "m8")
    g.e("m7", "m3")
    g.e("m8", "m3")

    g = b.lane("req", "1 · Every call", "marketplace-api\n(NestJS)")
    g.row("main", 0, [("in", "box", "an admin call:\nadmin/translations,\nadmin/locales or\nan owner's words"),
                      ("mw", "box", "helmet, trust proxy,\nrequest id + log"),
                      ("host", "jump", "Host registry:\nadmin host?", "hst_band_resolve"),
                      ("auth", "jump", "Auth:\nsigned in?", "auth_band_session"),
                      ("iam", "jump", "IAM:\nallows?", "iam_band_req"),
                      ("body", "dia", "body\nvalid?"),
                      ("ctrl", "box", "controller\n(nestia route)"),
                      ("svc", "box", "service method\n@Throws"),
                      ("ok", "box", "200/201 {ok, code, data}\n<CODE>_SUCCEEDED", "ok")], chain=False)
    g.chain("in", "mw", "host", "auth", "iam", "body")
    g.e("body", "ctrl", "yes")
    g.chain("ctrl", "svc", "ok")
    g.n("r_body", 5, "up", "box", "400\nvalidateEquals:\na missing or\nextra key", "red")
    g.e("body", "r_body", "no")
    g.n("r_err", 7, "up", "box", "error filter →\n{ok: false, code}", "red")
    g.e("svc", "r_err", "throws", dashed=True)
    g.note("req_note", 0, "foot", "Every route on this board runs this first. Words are written under the owner's resource, "
                                  "attributeDefinitions or categories; the two retries ask update on translations at company, "
                                  "the reads read on translations, and a language's status enable on locales at company.")

    g = b.lane("in", "2 · A source saved,\nor a person's\nwords", "TranslationsService,\ninside the owner's\ntransaction")
    g.row("up", 0, [("to_cat", "jump", "Categories: a\ncategory or its\nwords saved", "cat_band_words"),
                    ("to_att", "jump", "Attributes: a\ndefinition or an\noption saved", "att_band_words")], chain=False)
    g.n("s_in", 0, "main", "box", "from 1: a create, or\na PUT on the en row\nthat moved a field")
    g.n("s_sc", 1, "main", "box", "sourceChanged(tx)")
    g.n("q", 8, "main", "box", "afterCommit:\nqueue.owner(type, id)")
    g.e("to_cat", "s_in")
    g.e("to_att", "s_sc")
    g.e("s_in", "s_sc")
    g.e("s_sc", "q")
    g.row("down", 0, [("p_in", "box", "from 1: a person's\nwords: a POST, or a\nPUT on a row that\nis not the source"),
                      ("p_rd", "box", "recordManual(tx):\nread the owner's\nsource"),
                      ("p_ver", "dia", "still the\nsource they\nread?"),
                      ("p_chg", "box", "only the fields\nthey changed"),
                      ("p_mem", "table", "translation_memory:\nupserted; a person\nbeats the engine"),
                      ("p_fail", "table", "translation_\nfailures on those\nfields deleted"),
                      ("p_hash", "box", "hashes answered; the\nowner writes the row:\nsource human,\nversion + 1"),
                      ("p_due", "dia", "a field\nstill\ndue?")], chain=False)
    g.chain("p_in", "p_rd", "p_ver")
    g.e("p_ver", "p_chg", "yes")
    g.chain("p_chg", "p_mem", "p_fail", "p_hash", "p_due")
    g.e("p_due", "q", "yes")
    g.n("p_ver_r", 2, "down2", "box", "null: the owner\nanswers 409 *_\nTRANSLATION_\nCHANGED", "red")
    g.e("p_ver", "p_ver_r", "no")
    g.n("p_ev", 6, "down2", "box", "afterCommit, if a\nfield changed:\ntranslation.applied,\nthe person as actor")
    g.e("p_hash", "p_ev")
    g.n("p_none", 7, "down2", "box", "nothing\nqueued", "gray")
    g.e("p_due", "p_none", "no")
    g.note("in_note", 0, "foot", "The owner checks the language, both versions and its locks before either call, and a refusal "
                                 "rolls back every write. A field left as it was keeps its hash; one emptied drops it, and the job "
                                 "fills it. A PATCH, a move or a deleted label queues nothing: the sweep's walk finds a gap.")

    rows = ["up", "main", "down", "down2", "foot"]
    g = b.lane("job", "3 · The job", "added after commit;\nBullMQ runs one\nat a time", rows)
    g.row("main", 0, [("q_in", "box", "from 2, 6 and 7:\nqueue.owner(type,\nid, retry_at?)"),
                      ("q_at", "dia", "a\nretry_at?"),
                      ("q_own", "box", "no job id, no\npriority: it runs\nbefore the rest"),
                      ("q_k", "box", "queue\n\"translations\"\nin Valkey"),
                      ("q_next", "box", "the next job due:\nowner jobs, then\nlanguages (1), then\nthe sweep (2)"),
                      ("q_w", "dia", "runs a\nworker?"),
                      ("q_one", "box", "one job at a time\nacross every worker;\na run keeps 4 calls\nin flight"),
                      ("q_run", "box", "runner.run(job,\nshutdown signal)")], chain=False)
    g.e("q_in", "q_at")
    g.e("q_at", "q_own", "no")
    g.chain("q_own", "q_k", "q_next", "q_w")
    g.e("q_w", "q_one", "yes")
    g.e("q_one", "q_run")
    g.n("q_del", 1, "up", "box", "job id type.id.<the\nsecond after>,\ndelayed until then")
    g.e("q_at", "q_del", "yes")
    g.e("q_del", "q_k")
    g.n("q_w_r", 5, "up", "box", "TRANSLATION_\nWORKER=false:\nonly adds jobs", "gray")
    g.e("q_w", "q_w_r", "no")
    g.row("down", 2, [("l_in", "box", "from 4, 7 and 8:\nqueue.language(code)"),
                      ("l_job", "box", "job id language.<code>\n(a walk adds .<type>\n.<after>), priority 1")])
    g.e("l_job", "q_k")
    g.row("down2", 2, [("w_in", "box", "on boot, the job\nscheduler \"translations-\nsweep\": every 5 min"),
                       None,
                       ("w_job", "box", "a sweep job,\npriority 2")])
    g.e("w_job", "q_next")
    g.n("q_res", 7, "down", "dia", "the run's\nresult?")
    g.e("q_run", "q_res")
    g.n("q_rate", 6, "down", "box", "queue.rateLimit(ms) +\nRateLimitError: every\nworker waits; the job\ngoes back", "gray")
    g.e("q_res", "q_rate", "rate limited")
    g.n("q_stop", 7, "down2", "box", "moveToDelayed(now) +\nDelayedError: it runs\nagain after the restart", "gray")
    g.e("q_res", "q_stop", "stopped")
    g.n("q_done", 8, "down", "box", "done: the job\nis removed", "ok")
    g.e("q_res", "q_done", "done")
    g.note("job_note", 0, "foot", "Nothing in Postgres queues work: a job names where to look and the run reads what is due, so a "
                                  "lost or doubled job costs nothing. Every job is tried once and removed when it ends; a field's "
                                  "retry_at retries, never BullMQ. A job id is held while its job runs, so an owner job has none: a "
                                  "save mid-run would add nothing to a run that may already have read the owner. A run that throws "
                                  "is logged and removed, and the sweep finds its work.")

    g = b.lane("run", "4 · A run", "TranslationRunner:\nwhat is due,\nmemory first")
    g.row("main", 0, [("r_in", "box", "from 3: run(job,\nsignal)"),
                      ("r_kind", "dia", "job\nkind?"),
                      ("r_own", "box", "owner: that owner\nin every language\ntaking words"),
                      ("r_read", "box", "read the owners'\nsource and rows,\nand their failures"),
                      ("r_due", "box", "due, per owner and\nlanguage: text no row\ntranslates and no\nfailure holds"),
                      ("r_mem", "table", "translation_memory:\none read for every\ndue field"),
                      ("r_hit", "dia", "in\nmemory?"),
                      ("r_miss", "box", "misses: one\nTranslator call per\nowner and language,\n4 at once")],
          chain=False)
    g.e("r_in", "r_kind")
    g.e("r_kind", "r_own", "owner")
    g.chain("r_own", "r_read", "r_due", "r_mem", "r_hit")
    g.e("r_hit", "r_miss", "no")
    g.n("r_final", 6, "up", "box", "a hit is final:\nsaved without\nthe checks (6)")
    g.e("r_hit", "r_final", "yes")
    g.row("up", 1, [("r_sweep", "box", "sweep: every\nlanguage's walk\nqueued (3)"),
                    ("r_drop", "box", "failures that hold\nnothing deleted,\n100 at a time", "ok")])
    g.e("r_kind", "r_sweep", "sweep")
    g.n("r_lang", 1, "down", "dia", "still\ntakes\nwords?")
    g.e("r_kind", "r_lang", "language")
    g.n("r_walk", 2, "down", "box", "walk: 20 owners short\nof words, kind by kind\nin id order; once done,\nthe next 20 (3)")
    g.e("r_lang", "r_walk", "yes")
    g.e("r_walk", "r_read")
    g.n("r_ldone", 1, "down2", "box", "not taking\nwords: done", "gray")
    g.e("r_lang", "r_ldone", "no")
    g.note("run_note", 0, "foot", "Memory key: source language, target language, context.field (attribute_option.colour.name, say) "
                                  "and the source hash. An emptied source field clears the target's, and a missing row is "
                                  "inserted only with every field it cannot exist without. After a 429 no new call starts and the "
                                  "running ones still save; after a shutdown nothing more is saved, and what it stopped is still due.")

    g = b.lane("tr", "5 · The Translator", "no Postgres here;\na failure is an\noutcome, not a throw")
    g.row("main", 0, [("t_in", "box", "from 4: one owner's\ndue fields into\none language"),
                      ("t_try", "box", "each try: 30s\ntimeout; 2 tries\n0.5s apart, when\ntransient or\nmalformed"),
                      ("t_prov", "box", "provider.translate"),
                      ("t_ok", "dia", "answer\nok?"),
                      ("t_chk", "box", "checks per field:\nblank, protected term,\ndigits, length ratio,\nscript, unchanged"),
                      ("t_iss", "dia", "any\nissues?"),
                      ("t_out", "box", "per field: words,\nor words + issues")], chain=False)
    g.chain("t_in", "t_try", "t_prov", "t_ok")
    g.e("t_ok", "t_chk", "yes")
    g.e("t_chk", "t_iss")
    g.e("t_iss", "t_out", "no")
    g.n("t_again", 5, "up", "box", "asked once more,\nthe issues named;\nthe answer with\nfewer kept")
    g.e("t_iss", "t_again", "yes")
    g.e("t_again", "t_out")
    g.n("t_fk", 3, "down", "dia", "failure\nkind?")
    g.e("t_ok", "t_fk", "no")
    g.n("t_rate", 2, "down", "box", "rate limited (429):\nno new call; the\nqueue pauses (3);\nnothing recorded", "gray")
    g.e("t_fk", "t_rate", "429")
    g.n("t_trans", 4, "down", "box", "transient: timeout,\nnetwork, 408, 5xx\nbut 501: waits for\nits retry_at (6)")
    g.e("t_fk", "t_trans", "transient")
    g.n("t_perm", 3, "down2", "box", "permanent or blocked:\nanother status, a\nsafety block, truncated,\nmalformed: held (6)")
    g.e("t_fk", "t_perm", "other")
    g.note("tr_note", 0, "foot", "TRANSLATIONS_PROVIDER picks one at boot and production refuses any but gemini: a JSON schema of "
                                 "exactly the fields, temperature 0, thinking off on gemini-2.5-flash. google-gtx is development "
                                 "only, pieces of at most 1,800 characters, terms masked; stub answers '<code>:<text>'. A 429 reads "
                                 "Retry-After or Google's RetryInfo, else waits 60s. A second ask that fails transiently or on a 429 "
                                 "comes back beside the first words, so those fields retry or pause rather than being held.")

    rows = ["up", "main", "down", "down2", "foot"]
    g = b.lane("save", "6 · Saved", "one transaction\nper owner and\nlanguage", rows)
    g.row("main", 0, [("s_in", "box", "from 4 and 5: per\nfield, words from\nmemory, words that\npassed, flagged\nor failed"),
                      ("s_mem", "table", "translation_memory\nlearns new words,\nnever over an entry"),
                      ("s_w", "box", "write the row at\nthe version read;\nemptied fields null;\nsource machine when\nit writes the name"),
                      ("s_ver", "dia", "still the\nversion\nread?"),
                      ("s_del", "table", "failures on the\nwritten fields\ndeleted"),
                      ("s_ok", "box", "live now, as\nmachine words", "ok"),
                      ("s_ev", "box", "afterCommit:\ntranslation.applied\n(no listener yet)")], chain=False)
    g.chain("s_in", "s_mem", "s_w", "s_ver")
    g.e("s_ver", "s_del", "yes")
    g.chain("s_del", "s_ok", "s_ev")
    g.n("s_lost", 3, "up", "box", "row changed or owner\ngone: the owner job\nruns again (3);\nlearned words stay", "gray")
    g.e("s_ver", "s_lost", "no")
    g.row("down", 0, [("f_in", "box", "a failure per field:\ncode, attempts (+1 on\nthe same text), issues\n+ words if flagged"),
                      ("f_t", "table", "translation_\nfailures"),
                      ("f_tr", "dia", "transient?"),
                      ("f_retry", "box", "retry_at: 30s doubling\nto 1h; afterCommit, a\ndelayed owner job at\nthe earliest (3)")],
          chain=False)
    g.e("s_in", "f_in")
    g.chain("f_in", "f_t", "f_tr")
    g.e("f_tr", "f_retry", "yes")
    g.n("f_held", 2, "down2", "box", "no retry_at: held, not\ndue, until a person's\nwords (2), a retry (7)\nor a new source", "gray")
    g.e("f_tr", "f_held", "no")
    g.note("save_note", 0, "foot", "No review: words that pass the checks go live at once, and memory hits skip them. Memory holds "
                                   "only words a person typed or the checks passed, and the engine never replaces an entry, so a "
                                   "person's stay. GET status counts a field with a retry_at as waiting and one without as held. "
                                   "The sweep drops a failure whose text no longer needs translating.")

    rows = ["up", "main", "down", "down2", "down3", "down4", "down5", "foot"]
    g = b.lane("ops", "7 · Watching and\nretrying", "admin/translations", rows)
    g.row("main", 0, [("o_lang", "box", "from 1: POST languages/\n:localeCode/retry"),
                      ("o_lt", "dia", "it takes\nwords?"),
                      ("o_ldel", "box", "its failures\ndeleted; afterCommit,\nits walk (3)"),
                      ("o_lok", "box", "200: its counts,\nwithout them", "ok")], chain=False)
    g.e("o_lang", "o_lt")
    g.e("o_lt", "o_ldel", "yes")
    g.e("o_ldel", "o_lok")
    g.n("o_lt_r", 1, "up", "box", "404 TRANSLATIONS_\nLANGUAGE_NOT_FOUND", "red")
    g.e("o_lt", "o_lt_r", "no")
    g.row("down", 0, [("o_own", "box", "from 1: POST owners/\n:ownerType/:ownerId\n/retry"),
                      ("o_oe", "dia", "owner\nlive?"),
                      ("o_odel", "box", "its failures in every\nlanguage deleted;\nafterCommit, an\nowner job (3)"),
                      ("o_ook", "box", "200: its counts\nper language", "ok")], chain=False)
    g.e("o_own", "o_oe")
    g.e("o_oe", "o_odel", "yes")
    g.e("o_odel", "o_ook")
    g.n("o_oe_r", 1, "down2", "box", "404 TRANSLATIONS_\nOWNER_NOT_FOUND", "red")
    g.e("o_oe", "o_oe_r", "no")
    g.row("down3", 0, [("o_fl", "box", "from 1: GET failures"),
                       ("o_fl2", "box", "paged, with the owner's\nname; by owner, kind,\nlanguage or code")])
    g.row("down4", 0, [("o_st", "box", "from 1: GET status"),
                       ("o_st2", "box", "per language taking\nwords: waiting,\nheld, done")])
    g.row("down5", 0, [("o_ow", "box", "from 1: GET owners/\n:ownerType/:ownerId"),
                       ("o_ow2", "box", "per language: that\nowner's waiting, held,\ndone; 404 if gone")])
    g.note("ops_note", 0, "foot", "A retry deletes first and reads after, in one transaction: a refused retry rolls back, so no "
                                  "failure is deleted, and every field it frees starts again from its first attempt.")

    rows = ["up", "main", "down", "down2", "down3", "down4", "down5", "foot"]
    g = b.lane("loc", "8 · A language\ngoes live", "admin/locales, and\nthe gates that read\nthe words", rows)
    g.row("main", 0, [("l_in", "box", "from 1: PUT /admin/\nlocales/:code/status"),
                      ("l_lock", "box", "the locale's row\nFOR UPDATE"),
                      ("l_ok", "dia", "allowed\nmove?"),
                      ("l_to", "dia", "to\nwhich?"),
                      ("l_gaps", "dia", "any\ngaps?"),
                      ("l_act", "box", "active: storefronts\nserve it", "ok")], chain=False)
    g.chain("l_in", "l_lock", "l_ok")
    g.e("l_ok", "l_to", "yes")
    g.e("l_to", "l_gaps", "active")
    g.e("l_gaps", "l_act", "no")
    g.n("l_ok_r", 2, "up", "box", "409 LOCALES_\nTRANSITION_NOT_\nALLOWED", "red")
    g.e("l_ok", "l_ok_r", "no")
    g.n("l_oth", 3, "up", "box", "draft, review or\nretired: saved", "gray")
    g.e("l_to", "l_oth", "other")
    g.n("l_gaps_r", 4, "up", "box", "409 LOCALES_\nBACKFILL_\nINCOMPLETE {gaps}", "red")
    g.e("l_gaps", "l_gaps_r", "yes")
    g.n("l_bf", 3, "down", "box", "backfilling:\nlanguageStarted(tx),\nits walk after\ncommit (3)")
    g.e("l_to", "l_bf", "backfilling")
    g.row("down2", 0, [("lc0", "box", "draft"), ("lc1", "box", "backfilling"), ("lc2", "box", "review"),
                       ("lc3", "box", "active", "ok"), ("lc4", "box", "retired")])
    g.note("gates", 0, "down3", "Where a missing word refuses elsewhere:", size=18)
    g.row("down4", 0, [("g0", "jump", "Products: approve\na version", "prd_band_approve"),
                       ("g1", "box", "422 PRODUCT_VERSIONS_\nCONTENT_INVALID:\nVOCABULARY_\nUNTRANSLATED", "red"),
                       ("g2", "jump", "Categories: shown\nin a market", "cat_band_markets"),
                       ("g3", "box", "409 CATEGORIES_\nTRANSLATION_MISSING\nor _VOCABULARY_\nUNTRANSLATED", "red"),
                       ("g4", "jump", "Categories: a label\ndeleted", "cat_band_words"),
                       ("g5", "box", "409 *_TRANSLATION_\nLOCALE_ACTIVE", "red")], chain=False)
    g.e("g0", "g1")
    g.e("g2", "g3")
    g.e("g4", "g5")
    g.note("loc_note", 0, "foot", "Back moves: backfilling to draft, review to backfilling, retired to backfilling. Backfilling, "
                                  "review and active take words. GET :code/readiness counts the gaps: categories, attribute "
                                  "definitions, attribute options and products with no words in it. Requiring a definition "
                                  "beneath a shown category checks its words too.")

    b.trunk("req.svc", ["in.s_in", "in.p_in", "ops.o_lang", "ops.o_own", "ops.o_fl", "ops.o_st", "ops.o_ow", "loc.l_in"])
    b.wire("in.q", "job.q_in", sides=(("right",), ("top",)))
    b.wire("job.q_run", "run.r_in", sides=(("right",), ("top",)))
    b.wire("run.r_miss", "tr.t_in", sides=(("right",), ("top",)))
    b.wire("tr.t_out", "save.s_in", sides=(("right",), ("top",)))
    return b
