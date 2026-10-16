# gamedev-team

A full game-development team as Claude Code skills. Producer, game designer, dev lead, engineer, 3D
artist, QA and a player psychologist (reward loops, attention, ethics), each with its own skill or brief, taking a game from an idea to a published release: a discovery
interview, a Game Design Document that the owner approves, and then an autonomous run through technical
design, art direction, planning, implementation, QA and release, checking in only at milestone demos.
Roblox is the first-class engine; the layout is built to grow to others.

Inspired by [superpowers](https://github.com/obra/superpowers): small skills, explicit gates, process
before implementation.

> **En español:** este plugin convierte a Claude en un estudio completo. Primero descubre contigo qué
> juego quieres (una pregunta a la vez), luego escribe el documento de diseño (GDD) y lo aprueba contigo
> sección a sección. Con el GDD aprobado, toma las riendas: diseño técnico, biblia de arte, plan por
> hitos, implementación con tests, QA y publicación, y solo te consulta en las demos de cada hito o si
> algo cambia el GDD. Las skills están en inglés (para el modelo); la conversación y todos los documentos
> del juego se escriben en tu idioma.

## Install

As a plugin (recommended):

```bash
claude plugin marketplace add moiseseng/roblox-developer-skill
claude plugin install gamedev-team@gamedev-team
```

Or from a local clone, inside Claude Code: `/plugin marketplace add /path/to/gamedev-team` then
`/plugin install gamedev-team@gamedev-team`. Install the whole repo, not only `skills/`: the skills read
`references/`, `agents/`, `scaffold/` and `scripts/` relative to the plugin root.

Check the toolchain:

```bash
bash scripts/doctor.sh
```

## Use

Start a session anywhere and say what you want to make. The `using-gamedev-team` skill is injected at
session start and routes to the phase skill. Typical flow:

1. "Quiero hacer un juego de ..." → **discovery** interviews you, writes `docs/gamedev/discovery.md`.
2. **game-design-document** drafts the GDD section by section; you approve each; it renders `design.html`.
3. You say yes to the whole GDD → Claude runs **technical-design** + **art-direction**, then
   **production-planning** for M0, **implementing** task by task with tests, **qa-playtesting**, and
   shows you the M0 demo, which is a fun gate: you play five minutes and decide. Repeat per milestone (M1 vertical slice, M2 alpha, M3 beta, M4 release).
4. **release-liveops** publishes, reads week-one metrics and writes an iteration brief that feeds the
   next discovery round.

Start a new Roblox repo from the verified scaffold at any time:

```bash
bash scripts/new-game.sh MyGame ~/MyGame
```

## What's inside

```
skills/
  using-gamedev-team/      routing, roles, GDD gate, autonomy protocol
  discovery/               interview → brief           (+ question bank)
  game-design-document/    GDD, approval, change requests (+ template, design.html renderer)
  technical-design/        architecture, contracts, budgets (+ template)
  art-direction/           art bible, asset list, pipeline (+ template)
  production-planning/     milestones, task plans (+ template)
  implementing/            TDD on pure Luau, Rojo, Studio MCP verification, commits
  qa-playtesting/          acceptance, exploratory, exploit, perf passes (+ report templates)
  release-liveops/         publish, analytics, flags, iteration brief (+ checklist)
  extending-gamedev-team/  how to add skills, roles, engines
agents/                    reviewer/worker briefs: game-designer, producer, dev-lead, engineer, artist, qa,
                           player-psychologist
references/design/         player psychology: reward loops, attention, motivation, ethics (cross-engine)
references/roblox/         architecture, Luau style, networking, data, performance, UI, game feel, monetization,
                           analytics, testing, asset pipeline, market, Studio MCP, publishing
scaffold/roblox/           Rojo starter: loader, remotes, signal, session-locked DataService,
                           economy + specs, grey-box world, HUD, test runner (verified with rojo/selene/stylua)
scripts/                   new-game.sh, doctor.sh, typecheck.sh (strict Luau via luau-analyze)
hooks/                     SessionStart injection of the routing skill
evals/                     test prompts for the skill-creator loop
```

Project documents live in the game repo under `docs/gamedev/` (`state.md` tracks the phase, milestone
and next gate; `decisions.md` logs autonomous choices). The GDD is also rendered to `design.html` at
the repo root.

## Conventions carried over

Rojo layout with the place file as a build artifact, `selene` + `stylua` + `luau-analyze --mode=strict`,
a dependency-free test runner in `ServerStorage.Tests`, server authority everywhere, smallest-change
discipline, comments that say why.

For full strict type checking put the Roblox API definitions at `tools/globalTypes.d.luau` in the game
repo (the file `scripts/globalTypes.d.luau` from the luau-lsp project); `scripts/typecheck.sh` picks it up.
Without it the check still runs, filtered to errors in your own code.

## What "verified" means here

The scaffold builds with rojo and passes selene, stylua and luau-analyze. Its specs have **not** been
executed inside Roblox Studio by the authors; the first thing to do on a new game is open the place,
connect Rojo and run `require(game.ServerStorage.Tests.Runner).Run()`. QA blocks every milestone gate
until that has happened on the real build.

## Growing it

See `skills/extending-gamedev-team/SKILL.md`. Numbers in references marked **(verify)** should be
checked against current Roblox docs before quoting them to a user.

## License

MIT
