# Yaak Configuration

[Yaak](https://yaak.app) API client (HTTP, GraphQL, gRPC, WebSockets, SSE).

## Quick Start

```bash
cd ~/dotfiles
./yaak/setup.sh
```

Run `yaak-app` in zsh or launch it with `Mod+d`. `yaak` is the CLI.

## CLI

```bash
yaak workspace list
yaak request list <workspace-id>
yaak send <request-or-folder-id> -e <environment-id>
yaak import openapi.yaml
yaak request schema http       # JSON schema for --json payloads
```

Template variables use `${[ my_var ]}`, not `{{ ... }}`.

## What You Get

- **Launcher fix:** `yaak.desktop` and the `yaak-app` alias start it with `WEBKIT_DISABLE_DMABUF_RENDERER=1`. Without it the window renders blank on NVIDIA.
- **Settings:** Tokyo Night (Tokyo Night Day for light), JetBrainsMono Nerd Font in the editor, soft wrap, colored HTTP methods, no window buttons (i3 manages windows), telemetry off.
- **CLI:** `yaak` from [`@yaakapp/cli`](https://yaak.app/docs/getting-started/cli-usage), installed with `bun add -g` into `~/.bun/bin`. It uses the app's database, so changes show up in the app right away.
- **Agent skill:** `yaak agent install` adds a `use-yaak` skill for Claude Code, Cursor and generic agents (`~/.agents/skills`). Rerun it after updating the CLI.
- **Plugins:** every official plugin comes bundled with `yaak-bin`: auth (Bearer, Basic, API key, OAuth 1/2, JWT, AWS, Digest, NTLM), importers (Postman, Insomnia, OpenAPI, Bruno, curl), template functions (env, uuid, timestamp, hash, encode, JSON, regex, response chaining, 1Password) and JSONPath/XPath filters.

Yaak stores settings in `~/.local/share/app.yaak.desktop/db.sqlite`, not a config file, so `setup.sh` writes them with `sqlite3`. Close Yaak before running it.
