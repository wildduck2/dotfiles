from arch import H, W, Arch

PEOPLE, NET, CLOUD, WEB, APP, DATA, PART, OPS, SHIP = (
    "#343a40", "#7048e8", "#1a73e8", "#1971c2", "#e8590c", "#0c8599", "#c2255c", "#ae3ec9", "#495057")
GAP = 40
PAD = 28
TOP = 68
H2 = H + 16

GCP_X = 568
IN = GCP_X + 40
Y_USERS, Y_CF, Y_WEB_Z = 190, 430, 570
Y_WEB = Y_WEB_Z + TOP
ROW = 130
SIDE_X = 40 + PAD


def make():
    b = Arch("arch", "IRYSS: platform architecture")
    b.head("IRYSS: platform architecture",
           "Every part of IRYSS and what talks to what: who uses it, how a request gets in, the one backend every app calls,\n"
           "the one database it keeps, the partners it relies on, how it is measured and found, and how code ships. "
           "The websites and portals run on Vercel; the backend targets Google Cloud and is not provisioned yet.")

    # =========================================================================
    # Websites and portals
    # =========================================================================

    web_x = 920 + PAD
    b.card("storefront", web_x, Y_WEB, "shopping-cart", WEB, "Storefront", "iryss.com, es., it., fr.\nsign-in pages so far",
           "progress")
    b.card("b2b", web_x + W + GAP, Y_WEB, "package", WEB, "B2B marketplace", "irysswholesale.com", "planned")
    wz = b.zone("websites", "Websites · Vercel", "globe", WEB, ["storefront", "b2b"])

    portals = [("admin", "layout-dashboard", "Admin portal", "admin.iryss.com\nPuck page editor", "built"),
               ("brand_portal", "shirt", "Brand portal", "brands.iryss.com\nbrand pages in Puck", "planned"),
               ("retailer_portal", "store", "Retailer portal", "retailers.iryss.com", "planned")]
    px0 = wz[2] + 160 + PAD
    for i, (k, icon, title, sub, st) in enumerate(portals):
        b.card(k, px0 + i * (W + GAP), Y_WEB, icon, WEB, title, sub, st)
    pz = b.zone("portals", "Portals · Vercel", "app-window", WEB, [p[0] for p in portals])

    mid = (wz[2] + pz[0]) / 2
    b.card("cloudflare", mid - W / 2, Y_CF, "shield-check", NET, "Cloudflare", "DNS, TLS, firewall", "planned")
    users = [("shoppers", "shopping-bag", "Shoppers", "buy in their own market"),
             ("retailers", "store", "Retailers", "buy wholesale, resell"),
             ("brands", "shirt", "Brands", "sell their products"),
             ("team", "users", "IRYSS team", "approve and run markets"),
             ("crawlers", "search", "Search engines", "crawlers, Search Console")]
    ux = mid - (len(users) * W + (len(users) - 1) * 48) / 2
    for i, (k, icon, title, sub) in enumerate(users):
        b.card(k, ux + i * (W + 48), Y_USERS + TOP, icon, PEOPLE, title, sub, None)
    b.zone("users", "Who uses IRYSS", "users", PEOPLE, [u[0] for u in users])

    y_gcp = wz[3] + 60
    y_lb = y_gcp + TOP
    b.card("lb", mid - W / 2, y_lb, "network", NET, "Load balancer", "Cloud Armor, Cloudflare only", "planned")
    b.card("gtm", IN, y_lb, "radar", APP, "Server-side GTM", "t.iryss.com, t.irysswholesale.com", "planned")
    Y_BACK = y_lb + H + 130 + TOP

    # =========================================================================
    # Analytics and consent
    # =========================================================================

    for k, icon, title, sub, y in (
            ("posthog", "chart-line", "PostHog", "product analytics", Y_CF),
            ("cookiebot", "cookie", "Cookiebot", "consent before any tag", (Y_CF + y_lb) / 2),
            ("google", "target", "Google Analytics 4", "and Google Ads", y_lb)):
        b.card(k, SIDE_X, y, icon, PART, title, sub, "planned")
    b.zone("measure", "Analytics and consent", "chart-line", PART, ["posthog", "cookiebot", "google"], dashed=True)

    # =========================================================================
    # The backend and its data
    # =========================================================================

    stores = [("payload", "newspaper", APP, "Payload CMS", "pages, drafts, schedules\nPuck layouts, SEO, redirects",
               "planned"),
              ("postgres", "database", DATA, "PostgreSQL", "the one database\nCloud SQL, regional HA", "built"),
              ("valkey", "zap", DATA, "Valkey", "cache, sessions, queues\nMemorystore", "built"),
              ("opensearch", "database-zap", DATA, "OpenSearch", "search index on Aiven\nrebuilt from PostgreSQL",
               "planned"),
              ("storage", "archive", DATA, "Cloud Storage", "files: invoices, labels\nofficial documents", "planned")]
    bx0 = IN + PAD
    bw = 2272
    pitch = (bw - W) / (len(stores) - 1)
    b.card("api", bx0, Y_BACK, "server", APP, "Marketplace API",
           "api.iryss.com · one NestJS app: auth, IAM, markets, hosts, catalogue, translations, content", "built",
           to="hst_band_map", w=bw)
    y_st = Y_BACK + H + ROW
    for i, (k, icon, color, title, sub, st) in enumerate(stores):
        b.card(k, bx0 + i * pitch, y_st, icon, color, title, sub, st)
    b.card("workers", bx0, y_st + H2 + ROW, "cog", APP, "BullMQ workers",
           "BullMQ queues on Valkey: events, translations, partner calls, tracking, page revalidation", "built",
           to="trn_band_map", w=bw)
    bz = b.zone("backend", "One backend · api.iryss.com", "server", APP, ["api", "workers"] + [s[0] for s in stores])

    y_ops = bz[3] + 80 + TOP
    ox0 = bx0 + (bw - 3 * W - 2 * GAP) / 2
    for i, (k, icon, title, sub, st) in enumerate(
            [("observability", "chart-line", "Cloud observability", "logs, metrics, traces", "planned"),
             ("otel", "activity", "OpenTelemetry", "one collector", "built"),
             ("secrets", "key-round", "Secret Manager", "every credential", "planned")]):
        b.card(k, ox0 + i * (W + GAP), y_ops, icon, OPS, title, sub, st)
    oz = b.zone("ops", "Operations", "activity", OPS, ["observability", "otel", "secrets"])

    bottom = oz[3] + 40
    gx1 = bz[2] + 40
    b.zone("gcp", "Google Cloud · europe-west4", "cloud", CLOUD, [], dashed=True, fill="#f8fbff",
           box=(GCP_X, y_gcp, gx1, bottom))

    # =========================================================================
    # Partners
    # =========================================================================

    first, last = bz[1] + 50, bz[3] - 50
    right = [("stripe", "credit-card", "Stripe", "cards, brand payouts", "planned"),
             ("billie", "wallet", "Billie", "B2B pay later", "planned"),
             ("sendcloud", "truck", "Sendcloud", "labels, parcel tracking", "planned"),
             ("resend", "mail", "Resend", "email from 4 domains", "planned"),
             ("telnyx", "radio", "Telnyx", "SMS and voice", "planned"),
             ("gemini", "sparkles", "Gemini", "machine translation", "built")]
    left = [("shopify", "shopping-basket", "Shopify", "brands' own shops"),
            ("bunny", "image", "Bunny", "media at cdn.iryss.com"),
            ("odoo", "calculator", "Odoo", "finance.iryss.com ledgers"),
            ("merchant", "boxes", "Merchant Center", "Google Shopping feed"),
            ("meta", "plug", "Meta", "Conversions API, ads"),
            ("indexnow", "signpost", "IndexNow", "changed URLs to Bing")]
    step = (last - first) / (len(right) - 1)
    for i, (k, icon, title, sub, st) in enumerate(right):
        b.card(k, gx1 + 200 + PAD, first + i * step - H / 2, icon, PART, title, sub, st)
    b.zone("partners", "Partner services", "handshake", PART, [r[0] for r in right], dashed=True)
    for i, (k, icon, title, sub) in enumerate(left):
        b.card(k, SIDE_X, first + i * step - H / 2, icon, PART, title, sub, "planned")
    b.zone("outside", "Connected platforms", "handshake", PART, [r[0] for r in left], dashed=True)

    # =========================================================================
    # Delivery
    # =========================================================================

    y_dl = bottom + 80 + TOP
    dx0 = bx0 + (bw - 4 * W - 3 * 72) / 2
    for i, (k, icon, title, sub, st) in enumerate(
            [("github", "git-branch", "GitHub", "one monorepo", "built"),
             ("actions", "list-checks", "GitHub Actions", "checks, tests, scans", "built"),
             ("registry", "container", "Artifact Registry", "one image, promoted", "planned"),
             ("terraform", "file-code", "Terraform", "infrastructure as code", "planned")]):
        b.card(k, dx0 + i * (W + 72), y_dl, icon, SHIP, title, sub, st)
    b.zone("ship", "How code ships", "rocket", SHIP, ["github", "actions", "registry", "terraform"], dashed=True)

    # =========================================================================
    # Links
    # =========================================================================

    b.link("users", "cloudflare", "HTTPS", "planned", sides=(("bottom",), ("top",)))
    b.link("cloudflare", "websites", "sites", "planned", sides=(("left",), ("top",)))
    b.link("cloudflare", "portals", "portals", "planned", sides=(("right",), ("top",)))
    b.link("cloudflare", "lb", "api.iryss.com", "planned", sides=(("bottom",), ("top",)))
    b.link("lb", "api", status="planned", sides=(("bottom",), ("top",)))

    b.link("websites", "posthog", "page events", "planned", sides=(("top",), ("right",)))
    b.link("websites", "cookiebot", "consent", "planned", sides=(("left",), ("right",)))
    b.link("websites", "gtm", "Google tags", "planned", sides=(("bottom",), ("right",)))
    b.link("gtm", "google", "GA4, Ads", "planned", sides=(("left",), ("right",)))
    b.link("backend", "gtm", "confirmed orders", "planned", sides=(("top",), ("bottom",)))

    for k, st in (("storefront", "built"), ("b2b", "planned"), ("admin", "built"), ("brand_portal", "planned"),
                  ("retailer_portal", "planned")):
        b.link(k, "api", "typed SDK" if k == "admin" else None, st, sides=(("bottom",), ("top",)))

    b.link("api", "payload", "pages, publishing", "planned", sides=(("bottom",), ("top",)), both=True)
    b.link("payload", "workers", "publication events", "planned", sides=(("bottom",), ("top",)))
    b.link("payload", "postgres", "payload schema", "planned", sides=(("right",), ("left",)))
    for k, api_label, worker_label, st in (("postgres", "SQL", "SQL", "built"),
                                           ("valkey", "cache, sessions, jobs", "BullMQ jobs", "built"),
                                           ("opensearch", "search", "index", "planned"),
                                           ("storage", "files", "documents", "planned")):
        b.link("api", k, api_label, st, sides=(("bottom",), ("top",)))
        b.link("workers", k, worker_label, st, sides=(("top",), ("bottom",)))

    for k, label, st, both in (("stripe", "payments", "planned", True), ("billie", "B2B invoices", "planned", True),
                               ("sendcloud", "parcels", "planned", True), ("resend", "email", "planned", False),
                               ("telnyx", "SMS, calls", "planned", True), ("gemini", "translations", "built", False)):
        b.link("backend", k, label, st, sides=(("right",), ("left",)), both=both)
    for k, label, both in (("shopify", "products, orders", True), ("bunny", "images, video", False),
                           ("odoo", "accounting", False), ("merchant", "product feed", False),
                           ("meta", "confirmed orders", False), ("indexnow", "changed URLs", False)):
        b.link("backend", k, label, "planned", sides=(("left",), ("right",)), both=both)

    b.link("backend", "otel", "OTLP", "built", sides=(("bottom",), ("top",)))
    b.link("otel", "observability", status="planned", sides=(("left",), ("right",)))
    b.link("secrets", "backend", "credentials", "planned", sides=(("top",), ("bottom",)))

    b.link("github", "actions", status="built", sides=(("right",), ("left",)))
    b.link("actions", "registry", "image", "planned", sides=(("right",), ("left",)))
    b.link("registry", "gcp", "deploys", "planned", sides=(("top",), ("bottom",)))
    b.link("terraform", "gcp", "provisions", "planned", sides=(("top",), ("bottom",)))
    return b
