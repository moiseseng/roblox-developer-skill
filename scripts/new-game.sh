#!/usr/bin/env bash
# Create a new game repo from the verified scaffold.
# Usage: new-game.sh <GameName> [target-dir] [--engine roblox] [--no-git]
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENGINE="roblox"
DO_GIT=1
NAME=""
TARGET=""

while [ $# -gt 0 ]; do
  case "$1" in
    --engine) ENGINE="$2"; shift 2 ;;
    --no-git) DO_GIT=0; shift ;;
    -h|--help) sed -n '2,3p' "$0"; exit 0 ;;
    *) if [ -z "$NAME" ]; then NAME="$1"; elif [ -z "$TARGET" ]; then TARGET="$1"; else echo "unexpected arg: $1" >&2; exit 2; fi; shift ;;
  esac
done

[ -n "$NAME" ] || { echo "usage: new-game.sh <GameName> [target-dir] [--engine roblox] [--no-git]" >&2; exit 2; }
if ! [[ "$NAME" =~ ^[A-Za-z][A-Za-z0-9]*$ ]]; then
  echo "GameName must be alphanumeric PascalCase (e.g. SlimeRun)" >&2; exit 2
fi
SCAFFOLD="$PLUGIN_ROOT/scaffold/$ENGINE"
[ -d "$SCAFFOLD" ] || { echo "no scaffold for engine '$ENGINE' (expected $SCAFFOLD)" >&2; exit 2; }
TARGET="${TARGET:-$PWD/$NAME}"
# A target that already holds the design phase (docs/, design.html, README, .git) is fine; anything else
# that could collide with the scaffold is not.
if [ -e "$TARGET" ]; then
  for entry in "$TARGET"/* "$TARGET"/.[!.]*; do
    [ -e "$entry" ] || continue
    case "$(basename "$entry")" in
      docs|design.html|README.md|.git|.gitignore|.DS_Store|.claude) ;;
      *) echo "target has files the scaffold would collide with: $entry" >&2; exit 1 ;;
    esac
  done
fi

mkdir -p "$TARGET"
# Copy without overwriting anything that already exists (README, .gitignore, docs).
( cd "$SCAFFOLD" && find . -type f -not -path "./build/*" -print0 ) | while IFS= read -r -d '' rel; do
  dest="$TARGET/${rel#./}"
  if [ -e "$dest" ]; then continue; fi
  mkdir -p "$(dirname "$dest")"
  cp "$SCAFFOLD/$rel" "$dest"
  # Replace the placeholder name in text files we just created.
  case "$dest" in
    *.luau|*.json|*.md|*.toml) perl -pi -e "s/__GAME_NAME__/$NAME/g" "$dest" ;;
  esac
done

TODAY="$(date +%Y-%m-%d)"
mkdir -p "$TARGET/docs/gamedev/plans" "$TARGET/docs/gamedev/qa" "$TARGET/assets/rbxm"
if [ ! -e "$TARGET/docs/gamedev/state.md" ]; then
cat > "$TARGET/docs/gamedev/state.md" <<STATE
# Estado · $NAME
engine: $ENGINE
phase: 0-discovery
milestone: none
next_gate: GDD approval
open_decisions: 0
last_qa: none
updated: $TODAY

## Progreso
- $TODAY proyecto creado desde el scaffold
STATE
fi
[ -e "$TARGET/docs/gamedev/decisions.md" ] || cat > "$TARGET/docs/gamedev/decisions.md" <<DEC
# Decisiones · $NAME

Registro de decisiones tomadas de forma autónoma por el equipo (gamedev-team). Formato: fecha · decisión · alternativas · motivo.

| Fecha | Decisión | Alternativas | Motivo |
|---|---|---|---|
| $TODAY | Proyecto creado desde el scaffold de gamedev-team ($ENGINE) | place en Studio | reproducible desde git |
DEC
touch "$TARGET/docs/gamedev/plans/.gitkeep" "$TARGET/docs/gamedev/qa/.gitkeep" "$TARGET/assets/rbxm/.gitkeep"

if [ "$DO_GIT" = 1 ]; then
  if ! git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$TARGET" init -q
  fi
  git -C "$TARGET" add -A
  git -C "$TARGET" commit -q -m "chore: scaffold $NAME from gamedev-team ($ENGINE)" || true
fi

echo "Created $TARGET"
echo "Next: cd \"$TARGET\" && rojo serve   # then Studio → Rojo → Connect"
