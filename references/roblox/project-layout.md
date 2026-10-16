# Project layout (Rojo)

The user's existing games (SlimeRun, trash-diggers) use this layout; keep it so skills, tools and habits
transfer between projects. `scaffold/roblox/` is the verified starting point; `scripts/new-game.sh` copies it.

```
<game>/
├── default.project.json     Rojo tree: paths, Lighting/StarterPlayer/Workspace properties
├── selene.toml              std = "roblox"
├── stylua.toml              tabs, width 120, double quotes
├── .gitignore               *.rbxl, Packages/, sourcemap.json, build/
├── README.md                how to run, architecture table, publishing notes
├── design.html              rendered GDD (generated, committed)
├── docs/gamedev/            discovery.md, gdd.md, tech-design.md, art-bible.md, asset-list.md,
│                            decisions.md, state.md, plans/, qa/, release-checklist.md
├── src/
│   ├── shared/              ReplicatedStorage.Shared  (Config, Economy, Remotes, Signal, Loader, codecs, layouts)
│   ├── server/              ServerScriptService.Server (init.server.luau + Services/ + World/)
│   ├── client/              StarterPlayerScripts.Client (init.client.luau + Controllers/)
│   ├── character/           StarterCharacterScripts (movement scripts)
│   └── first/               ReplicatedFirst (loading screen)
├── tests/                   ServerStorage.Tests (Runner.luau + *.spec.luau)
├── assets/                  blender/, export/, rbxm/ (tracked), audio/
└── tools/                   dev scripts (python/luau harnesses)
```

## Rules

- **The place file is a build artifact.** `*.rbxl` is git-ignored. Everything the game needs is in `src/`,
  `assets/rbxm/` and `default.project.json`. The world is built from code at server start so it is
  reproducible; hand-made art goes through `assets/rbxm/` and is placed by code.
- **`default.project.json` carries settings**: Lighting (Technology, ClockTime, Atmosphere, post
  effects), StarterPlayer (walk speed, jump power, camera zoom, auto-jump off for platformers), Workspace
  (Gravity, FallenPartsDestroyHeight, StreamingEnabled), SoundService. Changing them in Studio and not in
  the file loses them on the next build.
- **Remotes** are declared in `src/shared/Remotes.luau` and created by the server at start (scaffold), or
  declared in the project tree under `ReplicatedStorage.Remotes` (SlimeRun style). Either is fine;
  don't mix.
- **Scripts:** `*.server.luau` (Script), `*.client.luau` (LocalScript), `*.luau` (ModuleScript).
  A folder with `init.server.luau` becomes a Script that contains the folder's children.
- **Lint and format** before every commit: `stylua src tests && selene src tests`.
- **Commits** are per task: `T03 feat(economy): cost curve + spec`. Types: feat, fix, art, ui, data, perf, test, chore, docs.

## Workflow

```bash
rojo serve                 # then Studio → Rojo plugin → Connect (accept initial sync)
rojo build -o build/Game.rbxl   # headless build to validate the tree (CI, or when no Studio)
```

Tests: in Studio command bar or through the MCP `execute_luau`:

```lua
require(game.ServerStorage.Tests.Runner).Run()
```

## Tooling present on this machine (as of the plugin's creation)

rojo 7.7, selene 0.32, stylua 2.5, gh, python3. Not installed: wally, rokit/aftman, lune, luau-lsp.
`scripts/doctor.sh` checks. Add `wally` only when a dependency is actually needed; the scaffold has none.
