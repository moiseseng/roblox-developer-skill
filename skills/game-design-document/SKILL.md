---
name: game-design-document
description: Use when a discovery brief exists and the game needs its Game Design Document (GDD), when the user asks to write, review, approve or update the design document, when they want to change or add a mechanic, system, economy rule, content or scope on a project that already has an approved GDD (change request), or when a design.html needs regenerating. The GDD is the contract every other phase is checked against.
---

# Game Design Document

> Paths such as `references/...`, `agents/...`, `scaffold/...` and `scripts/...` are relative to the plugin
> root: the directory two levels above this skill's folder (also given as `Plugin root:` in the session
> context). Paths under `docs/gamedev/` are in the game repo.

You are the game designer. The GDD you write is the most important artifact of the project: it is what
the user approves, and after approval it is the contract the dev lead, the artist, the engineer and QA
build against without asking the user again. A vague GDD produces a hundred questions later; a precise
one lets the team run autonomously. Spend the effort here.

Inputs: `docs/gamedev/discovery.md`. Output: `docs/gamedev/gdd.md` plus `design.html` at the repo root.
Template: `assets/gdd-template.md` (this skill's folder). Market and genre knowledge for Roblox:
`references/roblox/market-and-design.md`, monetization rules: `references/roblox/monetization.md`.

## Process

### 1. Draft section by section, approve section by section

Don't write 3,000 words and ask "¿está bien?". People can't review that. Instead:

1. Write the **Vision and pillars** section (one page). Show it. Ask for the yes.
2. Write **Core loop + mechanics**. Show, ask.
3. Write **Progression and economy** with real numbers (see below). Show, ask.
4. Write the rest (content, UX and the first 60 seconds, art, audio, social, monetization, live-ops, metrics,
   **player psychology (§13)**, tech constraints, scope, risks, open questions) in one or two batches. Show, ask.

Each playback: the section text, then 2 to 4 bullets of "decisiones que tomé y por qué", then one
question if something needs them. Use their language.

### 2. Numbers, not adjectives

"Progression feels rewarding" is not a design. Write the first session as a table: minute, what the
player does, what they earn, what they can afford, what unlocks. Write cost curves as formulas with the
base and the growth factor (`cost(n) = base * growth^n`) and show the levels that matter for this game
(n = 1, 5, 10, 20 for a long simulator; n = 1, 2, 3, 5 for a three-slot game). Session targets in minutes,
retention targets in percentages. If you don't know a number yet, write a range and mark it `[PROP]` so
the economy pass in `technical-design` and the first playtest can tune it.

Don't connect the numbers in your head. If the game has a cost curve (simulator, tycoon, collection, any
upgrade shop), run the bundled greedy-player simulator and paste its table. If it is a skill game (obby,
horror, fighting) write a difficulty table instead: time to first fail, retry time, checkpoint spacing,
target fail rate per step (`references/design/player-psychology.md`, "Tuning difficulty and flow").

```bash
python3 <skill-dir>/scripts/economy_sim.py --spec docs/gamedev/economy.json
```

`economy.json` holds the GDD's formulas (see `economy_sim.py --example`). The output shows minute by
minute when a greedy player affords each upgrade and whether time-to-next stays bounded; if minute 10
has nothing to buy or minute 1 has everything, fix the formula before writing prose about it.

### 3. Status badges

Every design statement carries one of three states, and `design.html` renders them as badges:

- `[OK]` the user said it (brief or chat), or explicitly accepted that specific statement.
- `[PROP]` proposed by you, reasonable default, revisable without asking.
- `[OPEN]` needs the user. Collect these in the final section; there should be few.

A "sí, sigue" on a section means "reasonable, continue", not "every proposal is now decided": `[PROP]`
items stay `[PROP]` unless the user names them. That is what lets you tune them later without asking.
One badge per statement; `[OK|PROP]` is not a badge and won't render.

### 4. Scope cut: v1 and later

The GDD describes the whole game, but it must draw a hard line: **v1 (ships)** versus **later**. v1 is
what M2 alpha must contain. Be stingy. A Roblox game that ships with one polished loop beats one with five
half-loops. Say what "done" means for each v1 system in one testable sentence; QA will use those.

### 5. Approval and lock

"All sections have a yes" is necessary, not sufficient. Lock only when all of these hold; otherwise say
which one fails and go back to that section:

- zero `[OPEN]` inside anything in v1 scope (an `[OPEN]` may survive only in "later" items);
- the monetization stance and the audience/platform line are `[OK]`, not `[PROP]`;
- every v1 mechanic has a "hecho significa" sentence QA can check;
- the first-session table (§3) and the economy table (§5, with the simulator output pasted) exist and connect;
- input is written per platform (PC, móvil, mando) for every v1 mechanic;
- §8 names the FTUE steps and the source language; §13 has no forbidden dark pattern.

When they hold, write the version line `Versión 1.0 · aprobado YYYY-MM-DD` at the top,
generate `design.html` (below), update `docs/gamedev/state.md` (`phase: 2-tech-design`,
`next_gate: M0 demo`), then commit everything in one commit (`docs(gdd): v1.0 aprobado`).
Tell the user: from here you take the wheel; the next time you need them is the M0 demo, unless something
changes the GDD.

## Rendering design.html

The user's projects keep a readable `design.html` at the repo root. Generate it from the markdown with:

```bash
python3 <skill-dir>/scripts/render_design_html.py docs/gamedev/gdd.md design.html --title "<Game> · Diseño" --lang es
```

It produces a single-file page with a sidebar table of contents from the `##` headings, status badges from
`[OK]`/`[PROP]`/`[OPEN]`, tables, code blocks and a light/dark toggle. Regenerate it on every GDD change;
never edit design.html by hand.

## Change requests (after approval)

When the user asks for a change on a project with an approved GDD:

1. Name what it touches: which sections, economy effects, UI, QA scope, art. Two to six bullets.
2. Propose the GDD edit and a version bump (1.0 → 1.1 for additions, 2.0 if a pillar changes).
3. Get the yes, edit the GDD, regenerate `design.html`, append to the `## Historial de cambios` section.
4. Then route to `production-planning` so the change becomes tasks. Never implement a mechanic that the GDD doesn't describe.

Small tuning (a number inside a `[PROP]` range) does not need the ceremony: change it, log it in
`docs/gamedev/decisions.md`, keep going.

## Review before showing the final GDD

Dispatch the `agents/game-designer.md` reviewer with the brief and the GDD and ask for: contradictions
between sections, systems that exist in one section but not in the loop, missing "done" sentences, economy
numbers that don't connect (earn rate versus cost curve), anything that violates Roblox policy
(`references/roblox/monetization.md`, content rules). Also dispatch `agents/player-psychologist.md` with the
brief, the GDD and `references/design/player-psychology.md`: it runs the reward-loop audit over §3 and §13
and checks the dark-patterns list. A `revisar` on ethics or policy blocks the show, like a policy violation
does. Fix, then show.

## Red flags

- Four pages, zero numbers. Go back to section 2.
- A system appears in Mechanics but never in a session timeline. Either it's in the loop or it's "later".
- You wrote "el jugador puede..." ten times. Can does not mean will. Write what they do at minute 3.
- The user said "lo que tú veas" on monetization. That is `[OPEN]`, not a license to pick.
- No v1 line, or v1 has everything. Cut until it hurts, then say what the first "later" item is.
