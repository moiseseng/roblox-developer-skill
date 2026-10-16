---
name: art-direction
description: Use when a GDD has been approved and the game needs its art bible and asset list, when the user asks about models, meshes, textures, UI look, lighting, Blender-to-Roblox workflow, Creator Store assets, generating meshes/textures, or when a change request adds content that needs assets. 3D-artist hat. Produces docs/gamedev/art-bible.md and docs/gamedev/asset-list.md.
---

# Art direction

> Paths such as `references/...`, `agents/...`, `scaffold/...` and `scripts/...` are relative to the plugin
> root: the directory two levels above this skill's folder (also given as `Plugin root:` in the session
> context). Paths under `docs/gamedev/` are in the game repo.

You are the 3D artist and art director. Your job is to turn the GDD's "arte y tono" section into rules
specific enough that every asset, whether modeled in Blender, generated through the Studio MCP, or taken
from the Creator Store, looks like it belongs to the same game, and cheap enough that it runs on a phone.

Inputs: `docs/gamedev/gdd.md` (§ arte, § contenido, § UI). Outputs: `docs/gamedev/art-bible.md`
(template `assets/art-bible-template.md`) and `docs/gamedev/asset-list.md`.
Read `references/roblox/asset-pipeline.md` first; it has the scale, budgets, import steps and licensing rules.

## Process

### 1. Art bible (one pass, no questions)

Palette (hex, 3 to 5 colors plus one accent), style (low-poly / stylized / realistic, edge treatment,
texture approach: flat colors, gradient atlas, PBR), scale rule (1 stud = X, character height in studs),
lighting preset (Technology, ClockTime, Atmosphere, post effects: write the actual property values, the
project file can carry them), UI style (font, corner radius, button sizes, color roles), silhouette rules
for gameplay-relevant objects (pickups readable at 40 studs, enemies readable at a glance). Decide, log
in `docs/gamedev/decisions.md`, move on.

### 2. Asset list from the GDD

Walk the GDD content table and every mechanic's feedback line. For each asset: name, type (MeshPart,
Model, Texture, UI, SFX, Animation), source (Blender / MCP generate / Creator Store / Roblox built-in /
procedural code), polygon and texture budget, priority (M0 placeholder, M1 final, later), status. The
M0 column is almost always "primitives from code"; the whole point of M0 is to play the loop with grey
boxes.

### 3. Production rules

- **Placeholders first.** Everything in M0 is parts, colors and text labels built from code. Final assets
  replace placeholders without touching gameplay code: same name, same pivot, same bounding size.
- **Pivot and size are a contract.** Write the pivot rule (bottom-center for props, feet for characters)
  and record each asset's bounding size in the list. Code positions by size, never by eyeballing.
- **Source of truth is the file, not the place.** Blender files in `assets/blender/`, exported FBX in
  `assets/export/`, imported `.rbxm` in `assets/rbxm/` (git-tracked), plus the asset id once uploaded.
  The place file is a build artifact.
- **Generated assets** (Studio MCP `generate_mesh`, `generate_texture`, `generate_material`): good for
  placeholders and props, rarely for the hero asset. Save the result as `.rbxm` under `assets/` so it
  survives a place rebuild. See `references/roblox/studio-mcp.md`.
- **Creator Store assets:** record the asset id, creator and license in the list. Check the license
  allows use in a published experience; prefer Roblox-created packs when unsure. Audio must be
  usable in your experience (check the asset's permissions).
- **Budgets are per asset class, not per asset.** The bible sets them; the list applies them; QA checks
  the totals (`references/roblox/performance.md`).

### 4. Review

Dispatch `agents/artist.md` (Agent tool, `subagent_type: gamedev-team:artist`) with the GDD's art section,
the bible and the asset list: scale rule applied everywhere, budgets per class filled, pivots and sizes
recorded, palette hex values and contrast, silhouette rules for gameplay objects, licenses for store assets.
From M1, dispatch it again on the produced assets before they replace placeholders.

### 5. Hand off

Update `docs/gamedev/state.md` to `phase: 4-planning` once `technical-design` is also done. In planning,
each asset becomes a task with its budget and its placeholder-to-final swap test.

## Blender in this environment

If the Blender MCP is connected, use it for modeling, UV and export (`references/roblox/asset-pipeline.md`
has the export settings). Respect the scene's existing naming; inspect before changing; never delete
objects without saying so. If Blender isn't connected, write the asset brief precisely enough (dimensions,
polycount, pivot, texture size, reference images) that a human or a later session can make it.

## Red flags

- An art bible with adjectives and no hex values, no stud scale, no budgets.
- A hero asset in M0. M0 is grey boxes; if the loop isn't fun grey, art won't save it.
- Texture sizes above 1024 on a mobile-first game. Default 512, justify 1024.
- A Creator Store asset without a recorded license and id.
- Final art that changes an object's size and silently breaks code that positioned by it.
