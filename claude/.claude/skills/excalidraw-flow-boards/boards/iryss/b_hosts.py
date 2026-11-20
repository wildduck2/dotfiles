from lib import Board, GRAY, GREEN, RED, SUB


def make():
    b = Board("hst", "Host registry: which site is asking")
    b.head("Host registry: which site is asking",
           "The first check on every request, before auth. The Host header picks the market and the audience, and the\n"
           "path must be a door that audience is served. An unknown host is a 404, never a default market.")

    # =========================================================================
    # Map
    # =========================================================================

    g = b.lane("map", "0 · The map", "the request, then the\nadmin writes that\nchange its answer")
    g.n("m1", 0, "main", "box", "1 · which host\nis asking?", to="hst_band_resolve")
    g.n("m2", 1, "main", "box", "2 · does it serve\nthis path's door?", to="hst_band_doors")
    g.n("m_auth", 2, "main", "jump", "next: Auth,\nwho is calling", to="auth_band_pipe")
    g.chain("m1", "m2", "m_auth")
    for i, (lane, text) in enumerate([("create", "3 · a new host\nstarts reserved"), ("life", "4 · smoke test,\nthen active"),
                                      ("cache", "5 · one cached set\nper replica"), ("who", "6 · who may\nchange a host")]):
        g.n(f"m{i + 3}", i, "down", "box", text, "table", to=f"hst_band_{lane}")

    # =========================================================================
    # Resolve
    # =========================================================================

    g = b.lane("resolve", "1 · Resolve\nthe host", "hostResolverMiddleware,\nafter requestContext,\nbefore every guard")
    g.row("main", 0, [("req", "box", "a request arrives\nHost: iryss.fr"),
                      ("mw", "box", "helmet, trust proxy,\nrequest context"),
                      ("health", "dia", "path is\n/health?"),
                      ("local", "dia", "localhost\nfrom an inside\ncaller?"),
                      ("known", "dia", "in the active\nset?"),
                      ("door", "dia", "path's door\nserved here?"),
                      ("ctx", "box", "request context:\nhostId, marketplaceId,\napplication", "ok")])
    g.n("skip1", 2, "up", "box", "skip the\nregistry", "ok")
    g.e("health", "skip1", "yes")
    g.n("skip2", 3, "up", "box", "skip: a fresh\nregistry is empty", "ok")
    g.e("local", "skip2", "yes")
    g.n("hosts", 4, "up", "table", "hosts: active,\nmarket active")
    g.e("known", "hosts", "cache miss", SUB)
    g.n("door404", 5, "up", "box", "404 HOST_NOT_\nREGISTERED", "red")
    g.e("door", "door404", "no")
    g.n("down", 4, "down", "dia", "storefront\npath, market\ndown?")
    g.e("known", "down", "no", RED)
    g.n("e503", 3, "down", "box", "503 MARKETPLACE_\nUNAVAILABLE", "red")
    g.e("down", "e503", "yes")
    g.n("e404", 4, "down2", "box", "404 HOST_NOT_\nREGISTERED", "red")
    g.e("down", "e404", "no")
    g.s("s_hdr", 0, "what arrives", "GET /v1/storefront/products\nHost: iryss.fr", slot="down", of="req")
    g.s("s_row", 4, "the row the set holds", "{ hostname: \"iryss.fr\",\n  application: \"storefront\",\n"
        "  marketplaceId: \"0193..fr\",\n  status: \"active\" }", slot="up2", of="hosts")
    g.s("s_ctx", 6, "what the guards read", "{ hostId: \"0193..h2\",\n  marketplaceId: \"0193..fr\",\n"
        "  application: \"storefront\" }", slot="down", of="ctx")
    g.s("s_404", 4, "what a stranger sees", "404 { ok: false,\n  code: \"HOST_NOT_REGISTERED\" }", of="e404")
    g.note("why404", 6, "data",
           "One 404 for an unknown host and for a host serving another\n"
           "audience: a distinct code would sort our hostnames into admin\n"
           "and not-admin for anyone holding no credential.\n"
           "A throw in the resolver reaches the error filter: fails closed.")

    # =========================================================================
    # Doors
    # =========================================================================

    rows = ["r0", "r1", "r2", "r3", "r4", "data"]
    g = b.lane("doors", "2 · Doors", "the path names a door,\nthe host must serve it.\nroute-family.ts is the\none map", rows, gap=36)
    doors = [("/v1/admin/*", "admin host"), ("/v1/marketplace/*", "brand or retailer host"),
             ("/v1/storefront/*", "storefront host"), ("/v1/auth/*", "any host"),
             ("any other path", "admin host, as company")]
    for i, (path, host) in enumerate(doors):
        g.n(f"p{i}", 0, rows[i], "box", path, "table")
        g.n(f"h{i}", 1, rows[i], "box", host, "ok" if i < 4 else "plain")
        g.e(f"p{i}", f"h{i}", "served by")
    g.note("undeclared", 2, "r4", "An undeclared prefix falls to company: a surface added\n"
                                  "later has to name its audience rather than land open.")
    g.s("s_wrong", 0, "admin host, storefront path", "GET /v1/storefront/products\nHost: admin.iryss.com\n"
        "-> 404 HOST_NOT_REGISTERED")
    g.s("s_right", 1, "brand host, its own door", "GET /v1/marketplace/products\nHost: brands.fr.iryss.com\n"
        "-> Auth, then IAM at market 0193..fr")
    g.n("to_auth_gate", 3, "r3", "jump", "Auth: sign-up and\nsign-in by door", to="auth_band_signup")
    g.e("h3", "to_auth_gate")

    # =========================================================================
    # Create
    # =========================================================================

    g = b.lane("create", "3 · Create", "POST /admin/hosts:\nevery row starts\nreserved")
    g.row("main", 0, [("post", "box", "POST /admin/hosts"),
                      ("needs", "dia", "storefront\nnames a\nmarket?"),
                      ("allowed", "dia", "market named\nby a market\napp only?"),
                      ("redir", "dia", "redirect\ntarget sound?"),
                      ("ins", "table", "insert hosts"),
                      ("reserved", "box", "status reserved", "ok")])
    g.n("needs_r", 1, "up", "box", "400 HOSTS_\nMARKETPLACE_REQUIRED", "red")
    g.e("needs", "needs_r", "no")
    g.n("allowed_r", 2, "up", "box", "400 HOSTS_MARKET-\nPLACE_NOT_ALLOWED", "red")
    g.e("allowed", "allowed_r", "no")
    g.n("redir_r", 3, "up", "box", "400 REDIRECT_TARGET_\nREQUIRED or _SELF,\n404 _NOT_FOUND", "red")
    g.e("redir", "redir_r", "no")
    g.n("ins_r", 4, "up", "box", "409 HOSTS_\nHOSTNAME_TAKEN", "red")
    g.e("ins", "ins_r", "unique")
    g.s("s_body", 0, "POST /admin/hosts", "{ hostname: \"iryss.fr\",\n  application: \"storefront\",\n"
        "  visibility: \"public\",\n  environment: \"production\",\n  marketplaceId: \"0193..fr\",\n"
        "  dnsTarget: \"lb.iryss.net\",\n  creationReason: \"FR launch\",\n  reviewDueAt: \"2027-04-01\" }", of="post")
    g.s("s_ins", 4, "the row", "{ id: \"0193..h2\",\n  hostname: \"iryss.fr\",\n  status: \"reserved\",\n"
        "  smokeTestedAt: null }", of="ins")
    g.note("shape", 1, "data", "chk_hosts_hostname_shape keeps a hostname lowercase:\n"
                               "a mixed-case host is a second cache key for one site.")

    # =========================================================================
    # Lifecycle
    # =========================================================================

    g = b.lane("life", "4 · Lifecycle", "activate, disable,\nretire. Every write\nreads the status first,\nso a refusal names why")
    g.row("main", 0, [("st_res", "box", "from 3: reserved"),
                      ("st_act", "box", "active", "ok"),
                      ("st_dis", "box", "disabled"),
                      ("st_ret", "box", "retired", "gray")], chain=False)
    g.e("st_res", "st_act", "activate", GREEN)
    g.e("st_act", "st_dis", "disable", RED, off=-14)
    g.e("st_dis", "st_act", "activate again", GREEN, off=14)
    g.e("st_dis", "st_ret", "retire, with a note", SUB)
    g.n("lr_res", 0, "up", "box", "409 HOSTS_NOT_\nSMOKE_TESTED", "red")
    g.e("st_res", "lr_res", "activate, no\nsmoke test")
    g.n("lr_act", 1, "up", "box", "409 HOSTS_RETIRE_\nREQUIRES_DISABLED", "red")
    g.e("st_act", "lr_act", "retire")
    g.n("lr_act2", 1, "down", "box", "409 HOSTS_ALREADY_\nACTIVE", "red")
    g.e("st_act", "lr_act2", "activate")
    g.n("lr_dis", 2, "up", "box", "409 HOSTS_ALREADY_\nDISABLED", "red")
    g.e("st_dis", "lr_dis", "disable")
    g.n("lr_ret", 3, "up", "box", "409 HOSTS_RETIRED_\nIS_IMMUTABLE", "red")
    g.e("st_ret", "lr_ret", "any write")
    g.s("s_act", 4, "after a smoke test and activate", "{ id: \"0193..h2\",\n  status: \"active\",\n"
        "  smokeTestedAt: \"2026-10-08\" }\n-> the cache drops everywhere", slot="main")
    g.note("smoke", 2, "down", "chk_hosts_active_is_smoke_tested refuses an active row\n"
                               "without a smoke test, even from psql: DNS resolving\nis not a launch.")

    # =========================================================================
    # Cache
    # =========================================================================

    g = b.lane("cache", "5 · The cache", "one active set per\nreplica, dropped on\nevery replica once a\nwrite commits")
    g.row("main", 0, [("w", "box", "from 4: a host write,\nor a market's status\nchange"),
                      ("commit", "box", "transaction\ncommits"),
                      ("after", "box", "afterCommit:\ninvalidate()"),
                      ("gen", "box", "generation + 1"),
                      ("pub", "box", "publish on\nValkey"),
                      ("drop", "box", "every replica\ndrops its set"),
                      ("rebuild", "box", "next request\nrebuilds once", "ok")])
    g.s("s_gen", 3, "a rebuild racing a write", "gen 17: a rebuild starts\nwrite commits: gen -> 18\n"
        "the rebuild ends on 17:\n  not stored\nnext request: rebuild on 18", of="gen")
    g.note("cache_note", 4, "data",
           "The same field folds a cold-cache burst into one query.\n"
           "A suspended market drops its hosts: activeSet filters on the\n"
           "market's status, and marketplaces invalidates this cache when\n"
           "it changes one.")

    # =========================================================================
    # Who may
    # =========================================================================

    g = b.lane("who", "6 · Who may\nchange it", "seven admin routes,\neach :id asked at the\nmarket its row serves")
    g.row("main", 0, [("list", "box", "GET list:\nthe guard's reach"),
                      ("get", "box", "GET, activate, disable,\nretire one :id"),
                      ("at", "box", "at: the row's\nmarket scope"),
                      ("move", "box", "PATCH a new\nmarketplaceId"),
                      ("both", "box", "asked at the old\nand the new market"),
                      ("to_iam_at", "jump", "IAM: route\nextras", "iam_band_extras")], chain=False)
    g.e("get", "at")
    g.e("move", "both")
    g.e("both", "to_iam_at")
    g.s("s_at", 3, "PATCH /admin/hosts/0193..h2", "{ marketplaceId: \"0193..it\" }\nasks update at\n"
        "  company.marketplace.0193..fr\n  company.marketplace.0193..it\nboth must pass", of="move")

    # =========================================================================
    # Links
    # =========================================================================

    b.wire("resolve.door", "doors.p0", "the door map")
    b.wire("cache.rebuild", "resolve.hosts", "rebuilds the set from")
    b.wire("create.reserved", "life.st_res", "every new row")
    b.wire("life.s_act", "cache.w", "drops the set everywhere")
    b.wire("resolve.ctx", "auth:pipe.to_hosts", "on to Auth: who is calling")
    b.wire("doors.to_auth_gate", "auth:signup.post", "the door decides who signs up")
    return b
