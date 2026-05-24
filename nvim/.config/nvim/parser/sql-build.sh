#!/usr/bin/env bash
# Rebuild patched tree-sitter-sql parser and install into ~/.config/nvim/parser/sql.so
#
# This parser carries local grammar patches (see sql-grammar.patch):
#   - Named UNIQUE / FOREIGN KEY constraints: `CONSTRAINT name UNIQUE (...)`,
#     `CONSTRAINT name FOREIGN KEY (...) REFERENCES ...`
#   - PL/pgSQL `:=` assignment statements inside CREATE FUNCTION bodies
#
# Run after `:TSUpdate sql` if you want the patches re-applied; the
# ~/.config/nvim/parser/sql.so takes priority over lazy/site copies via
# runtimepath, so nvim-treesitter updates do not normally clobber it.
set -euo pipefail

REPO="https://github.com/derekstride/tree-sitter-sql.git"
DOTFILE_DIR="$(cd "$(dirname "$0")" && pwd)"
PATCH="$DOTFILE_DIR/sql-grammar.patch"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

for cmd in git tree-sitter gcc; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Missing required tool: $cmd" >&2; exit 1; }
done

echo "[sql-build] Cloning $REPO into $WORK"
git clone --depth 1 "$REPO" "$WORK/src" >/dev/null 2>&1

echo "[sql-build] Applying $PATCH"
( cd "$WORK/src" && git apply "$PATCH" )

echo "[sql-build] Generating parser source"
( cd "$WORK/src" && tree-sitter generate >/dev/null )

echo "[sql-build] Compiling sql.so"
( cd "$WORK/src" && gcc -O2 -fPIC -shared -I./src src/parser.c src/scanner.c -o sql.so )

install -m 0755 "$WORK/src/sql.so" "$DOTFILE_DIR/sql.so"
echo "[sql-build] Installed $DOTFILE_DIR/sql.so"

if [[ "${1:-}" == "--mirror" ]]; then
  for tgt in \
    "$HOME/.local/share/nvim/site/parser/sql.so" \
    "$HOME/.local/share/nvim/lazy/nvim-treesitter/parser/sql.so"; do
    if [[ -e "$tgt" ]]; then
      install -m 0755 "$WORK/src/sql.so" "$tgt"
      echo "[sql-build] Mirrored to $tgt"
    fi
  done
fi
