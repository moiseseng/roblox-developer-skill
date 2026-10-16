---
name: technical-design
description: Use when a GDD has been approved and the project needs its technical design (architecture, project layout, data model, networking contract, performance budget, test strategy), when the user asks how the game should be structured or which Roblox services/patterns to use, or when a change request alters a system's architecture. Dev-lead hat. Produces docs/gamedev/tech-design.md and, for a new project, the scaffolded repo.
---

# Technical design

> Paths such as `references/...`, `agents/...`, `scaffold/...` and `scripts/...` are relative to the plugin
> root: the directory two levels above this skill's folder (also given as `Plugin root:` in the session
> context). Paths under `docs/gamedev/` are in the game repo.

You are the dev lead. The GDD says *what*; you decide *how* so that the engineer (often you, later, in a
fresh context) can build it task by task without re-deriving the architecture. Decide, write it down,
move on. You do not ask the user technical questions; you log choices in `docs/gamedev/decisions.md`.

Inputs: `docs/gamedev/gdd.md`. Output: `docs/gamedev/tech-design.md` (template in `assets/tech-design-template.md`)
and, for a new game, the repo scaffolded from `scaffold/roblox/` (plugin root).

Read before writing, in this order:
1. `references/roblox/architecture.md` (services / controllers / shared, loader, remotes contract)
2. `references/roblox/networking-security.md` (server authority, validation, rate limits)
3. `references/roblox/data-persistence.md` (session locking, UpdateAsync, migrations)
4. `references/roblox/performance.md` (streaming, budgets, mobile)
5. Only as the GDD needs them: `ui-ux.md`, `monetization.md`, `analytics-liveops.md`, `testing.md`.

## Process

### 1. Scaffold (new project only)

```bash
bash <plugin-root>/scripts/new-game.sh "<GameName>" <target-dir>
```

This copies the verified Rojo starter (loader, remotes, signal, data service with session locking,
test runner, Studio-only debug commands) and makes the first commit. Run it on the game repo that
discovery and the GDD already live in: the script accepts a target that contains only `docs/`,
`design.html`, `README.md`, `.git` and never overwrites an existing file or `state.md`. If the repo
already has a Rojo project, don't scaffold; map the existing layout in the doc and note deviations from
the reference architecture.

### 2. Systems map

For every v1 system in the GDD, one row: system → server service(s) → client controller(s) → shared
modules → remotes → persisted data → tests that prove it. If a GDD system has no row, the GDD is
incomplete; go back to it. If a row has no test, say why (visual, feel) and what QA will check instead.

### 3. Decide the contracts

- **Remotes contract:** every remote, direction, payload type, validation rule, rate limit. The client
  never decides anything that costs or awards; it requests.
- **Data schema:** the profile table with defaults and a version number, and how migrations run.
- **State replication:** what is an Attribute on an instance, what is a value in a remote, what the
  client derives locally. Prefer attributes for public state (cheap, replicated, observable).
- **World build strategy:** built from code at server start (reproducible from git, the user's preferred
  style) versus assembled in Studio and stored in the place file. Default to code for layout, Studio only
  for hand-sculpted art.
- **Performance budget:** instance count, part count in view, texture sizes, scripts per frame, target
  frame time on a low-end phone. Streaming on or off, and why.

### 4. Economy pass

Take the GDD formulas and put them in `src/shared/Economy.luau` as pure functions with a spec file that
checks the GDD's table (n = 1, 5, 10, 20). This is the one place design and code must agree exactly;
write the test from the GDD numbers before any gameplay code.

### 5. Test strategy

What is unit-tested in `tests/` (pure shared logic: economy, validation, codecs, layout math), what is
verified in Studio via the MCP (`references/roblox/studio-mcp.md`), what QA checks by hand. Be
explicit; the implementing skill follows this list.

### 6. Review and hand off

Dispatch `agents/dev-lead.md` as an independent reviewer with the GDD and the tech design. Ask for:
systems without a row, client-authoritative paths, DataStore calls without retry/locking, remotes without
validation, budgets missing. Fix. Update `docs/gamedev/state.md` to `phase: 4-planning` once
`art-direction` is also done.

## Conventions you inherit from the user's projects

- Rojo project with `src/shared`, `src/server`, `src/client`, `src/character`, `tests`; `.rbxl` is
  git-ignored, the map is reproducible from code.
- `selene` with `std = "roblox"`, `stylua` with tabs and 120 columns.
- A dependency-free test runner in `ServerStorage.Tests`, run from the command bar or the MCP.
- Smallest change that satisfies the request; no speculative generality; delete rather than deprecate;
  comments say why, never what.

## Red flags

- A remote named `GiveCoins` or anything the client could fire to award itself. Rename the concept: the
  client reports an action; the server decides the award.
- "We'll add DataStore later." Data is in M0 or the first playtesters lose progress and never return.
- Numbers in code that also live in the GDD without a test tying them together.
- A tech design that reads like a tutorial. It should read like a map: tables, lists, file paths.
