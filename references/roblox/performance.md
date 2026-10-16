# Performance

Most Roblox sessions happen on phones, many of them low-end. Budget for them from M0; a game that
drops frames on a phone loses the majority of its audience before it loses a single PC player.

## Budgets (defaults; the tech design overrides per game)

| Metric | Target (low-end phone) | How to measure |
|---|---|---|
| Frame time | ≤ 16 ms (60 fps) hub, ≤ 33 ms worst | MicroProfiler (Ctrl+F6), `Stats` in Studio |
| Instances in Workspace | ≤ 10k–20k in view **(verify for your game)** | script count, `rbx-scene-analysis` MCP skill |
| Draw calls | keep part/material/color variety low; unions and meshes over many parts | MicroProfiler render tags |
| Textures | ≤ 512² default, 1024² justified, total texture memory watched | Developer Console → Memory |
| Client memory | ≤ ~1 GB on mobile **(verify)**; watch PlaceMemory and CoreMemory | Developer Console (F9) |
| Script per frame | no `Heartbeat` loops iterating all players/instances; event-driven | MicroProfiler script tags |
| Network | ≤ 50 KB/s per client **(verify)**; batch, attributes, unreliable for streams | Developer Console → Network |
| Physics | ≤ few hundred moving parts; anchor everything static; no unanchored debris | Stats → Physics |

## Streaming

`StreamingEnabled = true` for any map larger than a hub: the client receives only nearby content.
Consequences the code must handle: instances may not exist on the client yet (`WaitForChild` with
timeouts, `CollectionService` added/removed signals), `Model.ModelStreamingMode` for models that must stream
whole (Persistent/Atomic), and `Workspace.StreamingMinRadius`/`StreamingTargetRadius` tuned to the
camera distance (verify the current property set in the docs). Disable only for small arenas where everything is
visible anyway. The `rbx-convert-to-streaming` MCP skill audits a non-streaming game.

## World built from code

Great for reproducibility, risky for instance counts: a loop that creates 50k parts will stall the
server at start. Build in `task.wait()` chunks, use `Instance.new` with properties set before `Parent`, move many
parts at once with `workspace:BulkMoveTo` instead of per-part CFrame writes, and count. Prefer one MeshPart over many parts for
repeated decor; use `Terrain` for ground where it fits.

## Common fixes

- Per-frame loops → events (`GetAttributeChangedSignal`, `Touched` with debounce, `Heartbeat` only in the
  loop that needs it, early-exit when nothing changed).
- Many `Touched` listeners → one zone check on a timer with spatial queries (`GetPartBoundsInBox`).
- Thousands of billboard GUIs → one `SurfaceGui`/`BillboardGui` per visible object, culled by distance
  and `MaxDistance`.
- Particle emitters everywhere → `Rate` low, `Enabled` only when visible, pooled.
- Clones/NPC animations on the server → animate on the client from replicated state; server moves a
  root only.
- Sound: `SoundGroup` per category, no more than a handful of `Sound` instances playing; preload with
  `ContentProvider:PreloadAsync` on the loading screen.
- Memory leaks: connections not disconnected, tables keyed by Player not cleared on leave, `Debris`
  not used for temporary parts.

## Mobile-specific

Quality level auto; test with the Device Simulator at a low preset; the user can expose a quality
setting (fewer clones, no shadows) as the GDD's accessibility/perf option. Text sizes ≥ 14 px, touch
targets ≥ 44 px (see `ui-ux.md`).

## Measuring in this environment

`rbx-perf-profiling` MCP skill for capture steps; `get_console_output` for warnings; `screen_capture`
with the MicroProfiler open. Record numbers in the QA report against the budget table.
