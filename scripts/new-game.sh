#!/usr/bin/env bash
# Create a new game repo from the verified scaffold, or add the scaffold to a repo that already holds the design docs.
# Usage: new-game.sh <GameName> [target-dir] [--engine roblox] [--lang es|en] [--no-git]
set -euo pipefail

USAGE="usage: new-game.sh <GameName> [target-dir] [--engine roblox] [--lang es|en] [--no-git]
  GameName    PascalCase, e.g. SlimeRun
  target-dir  defaults to ./<GameName>; may already hold docs/, design.html, README.md, .git (nothing is overwritten)
  --lang      language of the generated docs/gamedev/state.md and decisions.md (default es)"
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENGINE="roblox"
LANG_DOCS="es"
DO_GIT=1
NAME=""
TARGET=""

while [ $# -gt 0 ]; do
  case "$1" in
    --engine) [ $# -ge 2 ] || { echo "--engine needs a value" >&2; exit 2; }; ENGINE="$2"; shift 2 ;;
    --lang) [ $# -ge 2 ] || { echo "--lang needs a value" >&2; exit 2; }; LANG_DOCS="$2"; shift 2 ;;
    --no-git) DO_GIT=0; shift ;;
    -h|--help) echo "$USAGE"; exit 0 ;;
    -*) echo "unknown option: $1" >&2; echo "$USAGE" >&2; exit 2 ;;
    *) if [ -z "$NAME" ]; then NAME="$1"; elif [ -z "$TARGET" ]; then TARGET="$1"; else echo "unexpected arg: $1" >&2; exit 2; fi; shift ;;
  esac
done

[ -n "$NAME" ] || { echo "$USAGE" >&2; exit 2; }
if ! [[ "$NAME" =~ ^[A-Z][A-Za-z0-9]*$ ]]; then
  echo "GameName must be PascalCase: a capital letter first, then letters and digits (e.g. SlimeRun)" >&2; exit 2
fi
case "$LANG_DOCS" in es|en) ;; *) echo "--lang must be es or en" >&2; exit 2 ;; esac
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
if [ "$LANG_DOCS" = "en" ]; then
  T_STATE="State"; T_PROGRESS="Progress"; T_CREATED="project created from the scaffold"
  T_DEC="Decisions"; T_DEC_INTRO="Decisions the team (gamedev-team) took autonomously. Format: date · decision · alternatives · why."
  T_H="| Date | Decision | Alternatives | Why |"; T_ROW="Project created from the gamedev-team scaffold ($ENGINE) | place built in Studio | reproducible from git"
else
  T_STATE="Estado"; T_PROGRESS="Progreso"; T_CREATED="proyecto creado desde el scaffold"
  T_DEC="Decisiones"; T_DEC_INTRO="Registro de decisiones tomadas de forma autónoma por el equipo (gamedev-team). Formato: fecha · decisión · alternativas · motivo."
  T_H="| Fecha | Decisión | Alternativas | Motivo |"; T_ROW="Proyecto creado desde el scaffold de gamedev-team ($ENGINE) | place en Studio | reproducible desde git"
fi
if [ ! -e "$TARGET/docs/gamedev/state.md" ]; then
cat > "$TARGET/docs/gamedev/state.md" <<STATE
# $T_STATE · $NAME
engine: $ENGINE
phase: 0-discovery
milestone: none
next_gate: GDD approval
open_decisions: 0
last_qa: none
updated: $TODAY

## $T_PROGRESS
- $TODAY $T_CREATED
STATE
fi
[ -e "$TARGET/docs/gamedev/decisions.md" ] || cat > "$TARGET/docs/gamedev/decisions.md" <<DEC
# $T_DEC · $NAME

$T_DEC_INTRO

$T_H
|---|---|---|---|
| $TODAY | $T_ROW |
DEC
touch "$TARGET/docs/gamedev/plans/.gitkeep" "$TARGET/docs/gamedev/qa/.gitkeep" "$TARGET/assets/rbxm/.gitkeep"

if [ "$DO_GIT" = 1 ]; then
  # Only reuse a repo whose top level IS the target; a parent repo must not swallow the game.
  TOPLEVEL="$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null || true)"
  if [ "$TOPLEVEL" != "$(cd "$TARGET" && pwd -P)" ]; then
    git -C "$TARGET" init -q
  fi
  git -C "$TARGET" add -A
  git -C "$TARGET" commit -q -m "chore: scaffold $NAME from gamedev-team ($ENGINE)" || true
fi

echo "Created $TARGET"
echo "Next: cd \"$TARGET\" && rojo serve   # then Studio → Rojo → Connect"
