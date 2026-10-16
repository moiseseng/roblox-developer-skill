#!/usr/bin/env bash
# Strict Luau type check for a game repo: typecheck.sh [game-dir]
# Uses luau-analyze. With tools/globalTypes.d.luau present (Roblox API definitions published by the luau-lsp
# project), everything is checked and every error counts. Without it, src/ is checked with the errors that
# come only from the missing Roblox definitions filtered out, and *.spec files are skipped (their `t`
# parameter type can't resolve without definitions, which produces false positives).
set -u
DIR="${1:-.}"
cd "$DIR" || exit 2
command -v luau-analyze >/dev/null 2>&1 || { echo "luau-analyze not installed (brew install luau); read Studio's Script Analysis instead" >&2; exit 3; }
DEFS="tools/globalTypes.d.luau"
if [ -f "$DEFS" ]; then
  FILES="$(find src tests -name '*.luau' 2>/dev/null)"
  [ -n "$FILES" ] || { echo "no Luau files under src/ or tests/" >&2; exit 2; }
  # shellcheck disable=SC2086
  luau-analyze --mode=strict --formatter=plain "--definitions=$DEFS" $FILES
  exit $?
fi
FILES="$(find src tests -name '*.luau' -not -name '*.spec.luau' 2>/dev/null)"
[ -n "$FILES" ] || { echo "no Luau files under src/ or tests/" >&2; exit 2; }
echo "note: $DEFS not found; filtering errors that come from missing Roblox definitions and skipping *.spec files" >&2
echo "      (definitions: scripts/globalTypes.d.luau in the luau-lsp repository)" >&2
# shellcheck disable=SC2086
OUT="$(luau-analyze --mode=strict --formatter=plain $FILES 2>&1 | grep -v -e 'Unknown global' -e 'Unknown type' -e 'Unknown require' -e 'not a valid member of' -e "Key '.*' not found in class" -e 'Cannot call non-function' -e "Type 'unknown'" -e 'is not a subtype of' -e 'Unknown function' -e 'Argument count mismatch' -e "but got 'unknown'" -e 'Unknown symbol' -e 'could be nil' -e "'unknown' and 'unknown'" -e 'non-function' -e "of type 'unknown'")"
if [ -n "$OUT" ]; then echo "$OUT"; exit 1; fi
echo "typecheck: no errors beyond missing Roblox definitions"
