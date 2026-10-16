# Roblox Studio MCP (this environment)

The desktop app can be connected to Roblox Studio through an MCP server. Tool names start with
`mcp__Roblox_Studio__`. Several Studio instances may be open; **every call needs a `studio_id`**:

1. `list_roblox_studios` → `[{ id, name: "<Place> (placeId: …)" }]`. Pick by name. If none: tell the
   user to open the place in Studio (and press Connect in the Rojo plugin if the project uses Rojo),
   then continue with the static fallbacks below.
2. The tool description asks to **confirm with the user before modifying their game**. Do that once per
   session for the instance you'll change (play tests and reads don't need it; `multi_edit`,
   `insert_asset`, generated assets and `execute_luau` that mutates do).

## Tools, by use

| Need | Tool |
|---|---|
| Run the test runner, inspect values, call a service in edit mode | `execute_luau` (code string; returns prints/errors) |
| Read / search scripts in the place | `script_read`, `script_grep`, `script_search` |
| Edit scripts in the place (non-Rojo projects only; with Rojo edit the files) | `multi_edit` |
| Explore the tree | `search_game_tree`, `inspect_instance`, `get_studio_state` |
| Play test | `start_stop_play` (start/stop), `character_navigation` (move to a point), `user_keyboard_input`, `user_mouse_input` |
| See it | `screen_capture` (store with `store_image` for a QA report), `get_console_output` |
| Assets | `search_asset`, `insert_asset`, `generate_mesh`, `generate_texture`, `generate_material`, `generate_procedural_model`, `segment_mesh`, `upload_image` |
| Long jobs | `wait_job_finished` |
| Delegation inside Studio | `subagent` |
| Docs | `http_get` for Creator Docs pages; `skill("rbx-docs-search")` |

## Roblox-provided skills (call `skill(skill_name, studio_id)`)

| Skill | When |
|---|---|
| `rbx-docs-search` | any API detail you'd otherwise state from memory |
| `rbx-unit-test` | Roblox's own guidance for unit tests in Studio |
| `rbx-debug` | breakpoints and thread inspection for a scripting bug |
| `rbx-perf-profiling` | MicroProfiler / memory capture steps for the QA performance pass |
| `rbx-scene-analysis` | instance counts, heavy objects, scene audit |
| `rbx-device-simulator-lua` | switch to phone/tablet/console and capture UI |
| `rbx-convert-to-streaming` | turn streaming on safely or fix streaming bugs |
| `rbx-configs-experimentation` | live values, feature flags, A/B tests (ConfigService) |
| `rbx-create-skill` | if you want to author a Roblox-side skill |

These are maintained by Roblox and may be more current than this folder; prefer them for API specifics.

## Rojo projects and the MCP

With Rojo, the files in `src/` are the source of truth and Studio mirrors them while `rojo serve` is
connected. Don't `multi_edit` scripts in Studio in a Rojo project; edit the file and let Rojo sync
(two-way sync is off by default; changes made in Studio are lost). `execute_luau` is fine: it runs code,
it doesn't edit scripts.

## Verification recipe

```
list_roblox_studios → studio_id
execute_luau: require(game.ServerStorage.Tests.Runner).Run()        → all green?
start_stop_play: start
character_navigation / user_keyboard_input                           → drive the scenario
get_console_output                                                   → no errors/warnings?
screen_capture (+ store_image for the report)
start_stop_play: stop
```

## Fallbacks when no Studio is connected

`rojo build -o build/<name>.rbxl` validates the tree; `selene` and `stylua --check` validate code;
specs can't run (no lune). Say "verificación en Studio pendiente" in the task report and list the exact
commands the user can paste in the command bar.
