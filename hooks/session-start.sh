#!/usr/bin/env bash
# SessionStart hook: inject the routing skill so the team workflow is known from the first message.
# Output format follows the Claude Code SessionStart hook contract (hookSpecificOutput.additionalContext).
set -u
ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
SKILL="$ROOT/skills/using-gamedev-team/SKILL.md"
[ -f "$SKILL" ] || exit 0

# Strip the YAML frontmatter; the body is what the model needs.
BODY="$(awk 'BEGIN{fm=0} /^---$/{fm++; next} fm>=2{print}' "$SKILL")"

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

CONTEXT="<gamedev-team>
The gamedev-team plugin is installed. Its routing skill follows. Read the relevant phase skill before acting on any game-development request.
Plugin root: $ROOT
Phase skills can be invoked with the Skill tool as gamedev-team:<name>, or read from <plugin root>/skills/<name>/SKILL.md.

$BODY
</gamedev-team>"

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$(json_escape "$CONTEXT")"
