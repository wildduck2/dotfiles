# Claude Code Configuration

Global setup for [Claude Code](https://claude.com/claude-code): instructions, settings, skills and plugins.

## Quick Start

```bash
cd ~/dotfiles
./claude/setup.sh
```

## What You Get

| File | Purpose |
|------|---------|
| `~/.claude/CLAUDE.md` | Global instructions for every project |
| `~/.claude/settings.json` | Permissions, the em dash hook, enabled plugins, UI settings |
| `~/.claude/skills/*` | Global skills (one symlink per skill, so local-only skills can sit next to them) |

### Skills

- **General-purpose skills** from the IRYSS repo: planning (`grilling`, `to-spec`, `to-tickets`, `domain-modeling`, `prototype`, `research`), building (`implement`, `diagnosing-bugs`, `improve-codebase-architecture`), the toolchain references (`vite`, `vitest`, `tsdown`, `turborepo`, `typescript-advanced-types`, the Vercel React ones), frontend design (`frontend-design`, `design-taste-frontend`, `web-design-guidelines`, image generation) and writing (`writing-*`).
- **`use-yaak`** for the Yaak API client.
- **IRYSS-specific skills** (`building-a-module`, `tdd`, `pr`, `pr-comment`, `setup-pre-commit`, `excalidraw-flow-boards`) are not in this repo. `setup.sh` symlinks them from the IRYSS checkout when it exists (`IRYSS_DIR`), so they work globally on that machine and stay in sync with the repo. `code-review` stays project-only so it does not shadow the built-in `/code-review`.

### Plugins

`setup.sh` adds the official marketplace and installs `superpowers`. The `anthropic-skills`, `design`, `productivity` and `pdf-viewer` skills come with the claude.ai account and appear after `claude` logs in.

## Notes

- Claude Code writes to `settings.json` when you pick "always allow", so new rules land in this repo; review them before committing.
- Machine-specific permissions go in `~/.claude/settings.local.json`, which is not tracked.
