#!/usr/bin/env bash
#
# Claude Code Setup (global CLAUDE.md, settings, skills, plugins)
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

# Company skills stay in their repo and are only linked on machines that have it
IRYSS_DIR="${IRYSS_DIR:-/run/media/wildduck/duck/wildduck/COMPANIES/iryss}"
# code-review is left out: a global skill with that name would shadow the built-in /code-review
IRYSS_LOCAL_SKILLS=(building-a-module tdd pr pr-comment setup-pre-commit excalidraw-flow-boards)

header "Claude Code"

pkg_install jq   # the em dash hook in settings.json needs it
mkdir -p "$HOME/.claude/skills"
stow_package claude

# -- Plugins ---------------------------------------------------------------
if command_exists claude; then
  claude plugin marketplace add anthropics/claude-plugins-official >/dev/null 2>&1 || true
  claude plugin install superpowers@claude-plugins-official >/dev/null 2>&1 \
    && ok "superpowers plugin installed" \
    || warn "Could not install superpowers -- run: claude plugin install superpowers@claude-plugins-official"
else
  warn "claude not found -- run ./setup.sh base first"
fi

# -- Local-only company skills ---------------------------------------------
if [[ -d "$IRYSS_DIR/.claude/skills" ]]; then
  for skill in "${IRYSS_LOCAL_SKILLS[@]}"; do
    ln -sfn "$IRYSS_DIR/.claude/skills/$skill" "$HOME/.claude/skills/$skill"
  done
  ok "Linked ${#IRYSS_LOCAL_SKILLS[@]} IRYSS skills from $IRYSS_DIR"
else
  info "IRYSS repo not found -- skipping its local skills"
fi

ok "Claude Code setup complete"
