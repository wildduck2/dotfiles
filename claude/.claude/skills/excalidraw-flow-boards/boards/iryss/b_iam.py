from lib import Board, GRAY


def make():
    b = Board("iam", "IAM: may this caller do this, here")
    b.head("IAM: may this caller do this, here",
           "The third check, after the host and the session. A route names where its scope comes from, never the value;\n"
           "the guard asks the engine once per candidate scope, and the scopes that pass are the only rows the ORM will show.")

    # =========================================================================
    # Map
    # =========================================================================

    g = b.lane("map", "0 · The map", "the request, then what\nit reads and what\nchanges it")
    g.n("m_host", 0, "main", "jump", "Host registry:\nhost known?", to="hst_band_resolve")
    g.n("m_auth", 1, "main", "jump", "Auth:\nsigned in?", to="auth_band_session")
    for i, (key, lane, text) in enumerate([("m1", "req", "1 · IAM\nallows?"), ("m3", "cand", "3 · one decision per\ncandidate scope"),
                                           ("m4", "engine", "4 · the engine\nvotes"), ("m5", "extras", "5 · the route's\nown checks"),
                                           ("m6", "rows", "6 · only the rows\nit may see")]):
        g.n(key, i + 2, "main", "box", text, to=f"iam_band_{lane}")
    g.chain("m_host", "m_auth", "m1", "m3", "m4", "m5", "m6")
    for i, (lane, text) in enumerate([("route", "2 · a route names\nits scope source"), ("tree", "7 · the scope tree"),
                                      ("ranks", "8 · roles and ranks"), ("grants", "9 · granting a role"),
                                      ("spread", "10 · a change takes\neffect everywhere")]):
        g.n(f"m{[2, 7, 8, 9, 10][i]}", i + 2, "down", "box", text, "table", to=f"iam_band_{lane}")

    # =========================================================================
    # Request
    # =========================================================================

    g = b.lane("req", "1 · The request", "every guarded route:\nthe host, the session,\nIAM, then the body")
    g.row("main", 0, [("in", "box", "POST /admin/hosts/\n0193..h2/activate"),
                      ("mw", "box", "helmet, trust proxy,\nrequest context"),
                      ("host", "jump", "Host registry:\nhost known?", "hst_band_resolve"),
                      ("auth", "jump", "Auth:\nsigned in?", "auth_band_session"),
                      ("allow", "dia", "IAM\nallows?"),
                      ("body", "dia", "body\nvalid?"),
                      ("ctrl", "box", "the controller\nruns", "ok")])
    g.n("allow_r", 4, "up", "box", "403\nIAM_FORBIDDEN", "red")
    g.e("allow", "allow_r", "no")
    g.n("body_r", 5, "up", "box", "400 body rejected\nby typia", "red")
    g.e("body", "body_r", "no")
    g.s("s_in", 0, "the request", "POST /admin/hosts/0193..h2/activate\nHost: admin.iryss.com", of="in")
    g.s("s_ctx", 3, "what IAM is handed", "{ application: \"admin\",\n  marketplaceId: null,\n"
        "  identityId: \"0193..u1\" }", of="auth")

    # =========================================================================
    # Route
    # =========================================================================

    g = b.lane("route", "2 · The route names\nits scope source", "app.decorator.ts. Boot\nrefuses a route whose\nsource "
                                                             "does not fit\nits door")
    g.row("main", 0, [("dec1", "box", "@AuthorizeCompany(\n{ action, resource })"),
                      ("src1", "box", "SCOPE_SOURCE:\ncompany"),
                      ("chk", "dia", "source fits\nthe door?"),
                      ("boot", "box", "the module boots", "ok"),
                      ("to_doors", "jump", "Host registry:\nthe door map", "hst_band_doors")])
    g.n("dec2", 0, "down", "box", "@AuthorizeMarketplace(\n{ action, resource })")
    g.n("src2", 1, "down", "box", "SCOPE_SOURCE:\nhost")
    g.e("dec2", "src2")
    g.e("src2", "chk")
    g.n("chk_r", 2, "up", "box", "boot refuses: IAM_ROUTE_\nSCOPE_SOURCE_MISMATCH", "red")
    g.e("chk", "chk_r", "no")
    g.s("s_dec", 4, "a route, written down", "@AuthorizeCompany({\n  action: 'enable',\n  resource: 'hosts',\n"
        "  at: hostMarket,\n})", slot="down")
    g.note("route_note", 0, "foot", "/admin/* must declare company and /marketplace/* host. A bare duck-iam decorator is "
                                    "IAM_ROUTE_SCOPE_SOURCE_UNDECLARED. Both list every offender, so a batch is one fix.\n"
                                    "action then resource, first and single-quoted: permission-coverage finds routes "
                                    "by regex, and any other order drops a route from it silently.")

    # =========================================================================
    # Candidates
    # =========================================================================

    g = b.lane("cand", "3 · Candidates", "one decision per\ncandidate scope; the\nrequest needs one to pass")
    g.row("main", 0, [("guard", "box", "from 1:\nDuckIamAppGuard"),
                      ("src", "dia", "source?"),
                      ("served", "box", "scopesServedBy\n(door, market)"),
                      ("which", "box", "partner grants of the\ndoor's kind, confined\nhere or nowhere, org\n"
                                       "active in this market"),
                      ("any", "dia", "any\ncandidate?")], chain=False)
    g.e("guard", "src")
    g.e("src", "served", "host")
    g.e("served", "which")
    g.e("which", "any")
    g.n("held", 2, "up", "box", "every scope the actor\nholds, company among\nthem")
    g.e("src", "held", "company")
    g.e("held", "any")
    g.n("any_r", 4, "down", "box", "403\nIAM_FORBIDDEN", "red")
    g.e("any", "any_r", "no")
    g.n("unres", 2, "down", "box", "no market resolved:\n_unresolvedScope,\nnothing beneath it", "gray")
    g.e("served", "unres", "", GRAY)
    g.n("staff", 3, "down", "box", "a company or market\ngrant on a partner\ndoor: none", "gray")
    g.e("which", "staff", "", GRAY)
    g.s("s_held", 1, "what the actor holds", "[ \"company.marketplace.0193..fr\",\n  \"company.brand.0193..b7\" ]",
        slot="data")
    g.s("s_brand", 3, "on brands.fr.iryss.com", "candidates = [\n  \"company.brand.0193..b7\" ]\n"
        "only while Acme is active in fr")
    g.s("s_admin", 5, "on admin.iryss.com", "candidates = every scope held,\none decision each")
    g.note("cand_note", 0, "foot", "The host names a market, not an organisation: admitting the market or company scope "
                                   "on a partner door would reach every partner trading there. Staff act on a partner "
                                   "from the admin host.")

    # =========================================================================
    # Engine
    # =========================================================================

    g = b.lane("engine", "4 · The engine", "every source votes;\npolicyCombine 'and'\nneeds them all")
    g.row("main", 0, [("each", "box", "from 3: for\neach candidate c"),
                      ("set", "box", "setRequestScope(c),\ngrantScopes = [c]"),
                      ("cache", "dia", "decided in\nthe last 10 s?"),
                      ("rbac", "dia", "a role grants\nthe pair?"),
                      ("abac", "dia", "the policies\nallow?"),
                      ("pass", "box", "c passes", "ok"),
                      ("allp", "dia", "any c\npassed?"),
                      ("done", "box", "grantScopes = the\nscopes that passed", "ok")], chain=False)
    g.chain("each", "set", "cache")
    g.e("cache", "rbac", "no")
    g.e("rbac", "abac", "yes")
    g.e("abac", "pass", "yes")
    g.e("pass", "allp")
    g.e("allp", "done", "yes")
    g.n("cache_ok", 2, "up", "box", "the cached\nanswer", "ok")
    g.e("cache", "cache_ok", "yes")
    g.n("rbac_r", 3, "up", "box", "abstains: app:ungranted-\npair-block denies", "red")
    g.e("rbac", "rbac_r", "no")
    g.n("abac_r", 4, "up", "box", "deny-overrides; a\nmatched target with\nno allow denies", "red")
    g.e("abac", "abac_r", "no")
    g.n("allp_r", 6, "up", "box", "403\nIAM_FORBIDDEN", "red")
    g.e("allp", "allp_r", "no")
    g.s("s_ask", 1, "one question", "actor:  0193..u1\naction: enable hosts\n"
        "scope:  company.marketplace.0193..fr", of="set")
    g.s("s_votes", 4, "the votes", "rbac: company:admin grants\n      enable on hosts -> allow\n"
        "abac: readonly-write-block,\n      write-capable -> allow\nand  -> allow", of="abac")
    g.s("s_set", 7, "what the ORM reads later", "grantScopes = [\n  \"company.marketplace.0193..fr\" ]", of="done")
    g.becomes("s_ask", "s_votes", "s_set")
    g.note("engine_note", 0, "foot", "The rank rules are allow-shaped: allow when exists(attr) && actorRank >= targetRank. "
                                     "A missing attribute is a refusal, not a rule that quietly does not fire.")

    # =========================================================================
    # Route extras
    # =========================================================================

    g = b.lane("extras", "5 · Route extras", "read off the request\nbefore the handler,\nonce the permission\npassed")
    g.row("main", 0, [("perm", "box", "from 4: the\npermission passed"),
                      ("at", "box", "at: the action again\nat each scope the\nrequest names"),
                      ("acts", "box", "actsOn: a subject who\nmust not outrank\nthe actor"),
                      ("svc", "box", "the handler runs", "ok"),
                      ("ask", "box", "the service asks\nassertMayGrant for\nevery role it hands out")])
    g.n("at_r", 1, "up", "box", "403 IAM_FORBIDDEN:\nrefused at one, or\nan empty list", "red")
    g.e("at", "at_r", "no")
    g.n("acts_r", 2, "up", "box", "403 IAM_TARGET_\nOUTRANKS_ACTOR", "red")
    g.e("acts", "acts_r", "outranks")
    g.s("s_at", 1, "POST /admin/hosts/0193..h2/activate", "at: hostMarket\n-> enable asked at\n"
        "   company.marketplace.0193..fr", of="at")
    g.s("s_acts", 2, "PATCH /admin/users/0193..u9", "actsOn: params.id\nactor 80 >= target 60\n-> passes", of="acts")
    g.s("s_ask", 4, "POST /admin/users", "roleIds: [\"company:support\"]\nmanageRoles on users\n"
        "60 <= 80 -> passes", of="ask")
    g.note("extras_note", 0, "foot", "at and actsOn start together and rethrow in declared order, so the refusal "
                                     "a caller sees is the first one written, not whichever answered first. actsOn "
                                     "naming nobody refuses; a row naming nobody passes.")

    # =========================================================================
    # Rows
    # =========================================================================

    rows = ["r0", "r1", "r2", "r3", "data"]
    g = b.lane("rows", "6 · Which rows", "the tenant rule on the\nmodel, put on the table\nin every statement", rows, gap=40)
    g.n("gs", 0, "r0", "box", "from 5: grantScopes\non the request")
    table = [("a list of scopes", "a real actor's\npassing scopes", "containment:\nstarts_with(scope, 's.')", "ok"),
             ("null", "company: everything\nbeneath it", "no predicate, or\nnarrow to the host", "plain"),
             ("[]", "a real actor\nreaching nothing", "false: no rows,\nnever no filter", "red"),
             ("undefined", "no engine-gated\nroute ran", "the host alone;\nrefuse with no host", "plain")]
    for i, (v, means, pred, pal) in enumerate(table):
        g.n(f"v{i}", 1, rows[i], "box", v, "table")
        g.n(f"m{i}", 2, rows[i], "box", means)
        g.n(f"p{i}", 3, rows[i], "box", pred, pal)
        g.e("gs", f"v{i}")
        g.e(f"v{i}", f"m{i}")
        g.e(f"m{i}", f"p{i}")
    g.s("s_rows", 3, "a market-confined operator", "grantScopes = [\"company.marketplace.0193..fr\"]\n"
        "-> fr rows only;\n   0193..it rows are never read")
    g.note("rows_note", 4, "r1", "Downward only: company sits above every market,\nnot beneath one.\n"
                                 "Collapsing any two of the four states fails open.")

    # =========================================================================
    # Scope tree
    # =========================================================================

    g = b.lane("tree", "7 · The scope tree", "one tree; a grant is a\nrole at a scope, and a\nscope reaches what it\n"
                                          "is a dot-prefix of")
    g.n("company", 0, "main", "box", "company", "table")
    g.n("mkt", 1, "up", "box", "company.marketplace.<m>\nstaff, one market")
    g.n("brand", 1, "main", "box", "company.brand.<org>\na partner, everywhere\nit trades")
    g.n("ret", 1, "down", "box", "company.retailer.<org>")
    g.n("member", 2, "main", "box", "company.brand.<org>.\nmarketplace.<m>\na member, one market")
    g.e("company", "mkt", "contains")
    g.e("company", "brand")
    g.e("company", "ret")
    g.e("brand", "member", "contains")
    g.s("s_asg", 3, "an iam_assignments row", "{ subjectId: \"0193..u1\",\n  roleId: \"company:admin\",\n"
        "  scope: \"company.marketplace.0193..fr\",\n  attributes: {} }", slot="main")
    g.s("s_reach", 4, "containment", "brand:admin at company.brand.0193..b7\nreaches the member at\n"
        "  company.brand.0193..b7\n    .marketplace.0193..fr\nnever the other way round", slot="main")
    g.note("tree_note", 2, "down", "company is a dot-prefix of every market: a grant there reaches every\n"
                                   "market that exists or ever will. Which markets a partner trades in lives\n"
                                   "in organisation_marketplaces, not in the string.")

    # =========================================================================
    # Ranks
    # =========================================================================

    g = b.lane("ranks", "8 · Roles and ranks", "metadata.rank on each\niam_roles row; one\nglobal ladder", gap=50)
    company = [("company:readonly", "30"), ("company:compliance-\nreadonly", "50"), ("company:support", "60, grants"),
               ("company:admin", "80, grants"), ("company:superadmin", "100, sealed"),
               ("company:security-\naccess", "mixin, sealed")]
    for i, (role, rank) in enumerate(company):
        pal = "gray" if "sealed" in rank else "ok" if "grants" in rank else "plain"
        g.n(f"c{i}", i, "main", "box", f"{role}\n{rank}", pal)
    for i, (role, rank) in enumerate([("brand / retailer\nmember", "20"), ("readonly", "25"), ("admin", "40, grants"),
                                      ("owner", "70, grants,\none per org")]):
        pal = "ok" if "grants" in rank else "plain"
        g.n(f"p{i}", i, "down", "box", f"{role}\n{rank}", pal)
    g.chain(*[f"c{i}" for i in range(5)])
    g.chain(*[f"p{i}" for i in range(4)])
    g.note("ranks_note", 4, "down", "Green carries grantAuthority. Gray is assignable: false,\n"
                                    "never grantable through the API however high your rank.\n"
                                    "uq_iam_assignments_organisation_owner keeps one owner.")

    # =========================================================================
    # Granting
    # =========================================================================

    g = b.lane("grants", "9 · Granting", "POST /admin/users,\niamAssignments,\norganisationMembers;\nmanageRoles on users")
    g.row("main", 0, [("body", "box", "from 5: a role at\na scope in the body"),
                      ("scope", "dia", "role fits\nthe scope?"),
                      ("rank", "dia", "rank at or\nbelow yours?"),
                      ("auth", "dia", "you carry\ngrantAuthority?"),
                      ("assign", "dia", "role\nassignable?"),
                      ("family", "dia", "partner actor,\npartner role?"),
                      ("ins", "table", "insert\niam_assignments"),
                      ("ok", "box", "role.granted", "ok")])
    g.n("scope_r", 1, "up", "box", "400 IAM_ASSIGNMENTS_\nSCOPE_MISMATCH", "red")
    g.e("scope", "scope_r", "no")
    for d, why in [("rank", "above your rank"), ("auth", "you grant nothing"), ("assign", "sealed role"),
                   ("family", "wrong family")]:
        g.n(f"{d}_r", ["rank", "auth", "assign", "family"].index(d) + 2, "down" if d == "rank" else "up", "box",
            f"403 IAM_FORBIDDEN:\n{why}", "red")
        g.e(d, f"{d}_r", "no")
    g.n("ins_r", 6, "up", "box", "409 IAM_ASSIGNMENTS_\nOWNER_EXISTS", "red")
    g.e("ins", "ins_r", "second owner")
    g.s("s_grant", 0, "POST /admin/users", "{ email: \"anna@iryss.com\",\n  username: \"anna\",\n  roleIds: [\"company:support\"],\n"
        "  marketplaceId: \"0193..fr\" }", of="body")
    g.s("s_row", 6, "the grant", "{ subjectId: \"0193..u9\",\n  roleId: \"company:support\",\n"
        "  scope: \"company.marketplace.0193..fr\" }", of="ins")
    g.becomes("s_grant", "s_row")
    g.note("grant_note", 0, "foot", "A partner role is refused at a market scope, which would reach every partner\n"
                                    "trading there. A company role at a partner scope is allowed on purpose:\n"
                                    "that confines an operator to one partner.")

    # =========================================================================
    # Propagation
    # =========================================================================

    g = b.lane("spread", "10 · A change takes\neffect everywhere", "decisions cached 10 s\nper replica; the engine\nowns the fan-out")
    g.row("main", 0, [("w", "box", "from 9: a grant, revoke\nor policy change"),
                      ("inv", "box", "setInvalidator:\npublish on Valkey"),
                      ("drop", "box", "every replica drops\nits decision map"),
                      ("next", "box", "the next request\nasks afresh", "ok")])
    g.n("rev", 0, "down", "box", "revokeIamSubject")
    g.n("evt", 1, "down", "box", "authz.revoked")
    g.n("to_audit", 2, "down", "jump", "Auth: auth_events", to="auth_band_audit")
    g.chain("rev", "evt", "to_audit")

    # =========================================================================
    # Links
    # =========================================================================

    b.wire("req.allow", "cand.guard", "decided per candidate scope")
    b.wire("route.boot", "cand.guard", "then, on every request")
    b.wire("cand.any", "engine.each", "yes: one engine call each")
    b.wire("engine.done", "extras.perm", "then the route's own checks")
    b.wire("extras.svc", "rows.gs", "every query it runs")
    b.wire("extras.ask", "grants.body", "every role it hands out")
    b.wire("rows.p0", "tree.s_reach", "a dot-prefix, as in the tree")
    b.wire("ranks.p3", "grants.rank", "owner 70 grants 70 and below")
    b.wire("grants.ok", "spread.w", "takes effect everywhere")
    return b
