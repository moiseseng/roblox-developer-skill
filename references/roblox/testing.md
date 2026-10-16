# Testing

Three layers, each with a tool:

| Layer | What | Tool |
|---|---|---|
| Unit | pure Luau: economy, validation, codecs, migrations, layout math, data table integrity | `tests/Runner.luau` + `*.spec.luau` (scaffold) |
| Studio | behaviour that needs instances: world build, remotes, UI, data round trip | Studio MCP: `execute_luau`, `start_stop_play`, `get_console_output`, `screen_capture` |
| QA | acceptance against the GDD, exploratory, exploit, performance, devices | `qa-playtesting` skill, Device Simulator, MicroProfiler |

## The runner

Dependency-free so no wally is needed. Specs are ModuleScripts named `<Name>.spec.luau` in `tests/`
returning `function(t)`; `t.describe`, `t.it`, `t.expect(x)` with `.toBe`, `.toEqual` (deep),
`.toBeCloseTo(y, eps)`, `.toBeTruthy`, `.toThrow`. The runner prints a summary and returns
`(passed, failed)`. See `scaffold/roblox/tests/Runner.luau`.

Run:

```lua
require(game.ServerStorage.Tests.Runner).Run()         -- all
require(game.ServerStorage.Tests.Runner).Run("Economy") -- filter by name
```

Through the MCP: `execute_luau` with that string; read the printed summary; fail the task on any red.

Write specs from the GDD's numbers, before implementation, for anything with a formula or a rule. Keep
specs independent (no shared mutable state), fast (no yields), and named for the behaviour
("cost grows 1.15x per level"), not the function.

## Studio verification sequence (engineer and QA)

1. `list_roblox_studios` → pick the studio whose name matches the place; confirm with the user the
   first time you will modify their open place.
2. If using Rojo: ensure `rojo serve` is running and the plugin is connected (ask the user if not;
   the MCP can't press Connect). Alternatively build (`rojo build -o build/X.rbxl`) and ask them to open it.
3. `execute_luau` the test runner; read output.
4. `start_stop_play` → play; `character_navigation` / `user_keyboard_input` to drive; `screen_capture`
   for the visual check; `get_console_output` for warnings and errors; stop.
5. For UI on phone: `rbx-device-simulator-lua` skill to switch device and capture.
6. For a crash or a wrong value: `rbx-debug` skill for breakpoints and thread inspection.

No Studio connected: unit tests can't run headless without lune (not installed); do `rojo build` to
validate the tree and `selene`/`stylua` for static checks, and state clearly that runtime verification
is pending.

## Two-player tests

Studio → Test → Clients and Servers → 2 players, Start. Needed for: replication of attributes, remotes
from a second client, what a joiner sees mid-round. The MCP targets one instance; use it for the server
and ask the user to watch the clients, or script client behaviour with a test LocalScript behind a
`Config.Debug` flag.

## Data tests

API services enabled in the place; join → change → leave → rejoin; kill the server (stop) and check
`BindToClose` saved; seed a fresh lock in the DataStore and check the second join waits/refuses.

## What QA automates

A `tests/Smoke.spec.luau` that builds the world in a sandbox folder, counts instances against the
budget, checks every remote in `Remotes.luau` exists after `Init`, and validates data tables. Run it
at every gate.
