#!/usr/bin/env bash
# Check the toolchain gamedev-team expects for Roblox work.
set -u
ok=0; missing=0
check() { # name, required(1/0), hint
  if command -v "$1" >/dev/null 2>&1; then
    printf '  ✓ %-10s %s\n' "$1" "$("$1" --version 2>/dev/null | head -1)"; ok=$((ok+1))
  else
    if [ "$2" = 1 ]; then printf '  ✗ %-10s missing — %s\n' "$1" "$3"; missing=$((missing+1)); else printf '  · %-10s optional — %s\n' "$1" "$3"; fi
  fi
}
echo "gamedev-team doctor"
check rojo 1 "brew install rojo  (or rokit add rojo-rbx/rojo)"
check selene 1 "brew install selene"
check stylua 1 "brew install stylua"
check git 1 "xcode-select --install"
check python3 1 "needed for render_design_html.py"
check gh 0 "brew install gh  (push repos, PRs)"
check wally 0 "only if a dependency is needed"
check lune 0 "headless Luau runner (CI tests)"
check luau-lsp 0 "type checking outside Studio"
echo
echo "Roblox Studio MCP: if available in this session, call list_roblox_studios; the Rojo plugin must be connected for live sync."
[ "$missing" = 0 ] && echo "All required tools present." || { echo "$missing required tool(s) missing."; exit 1; }
