# Asset pipeline

## Scale

Roblox units are studs. A default R15 avatar is about 5 studs tall; Roblox's documented convention is
roughly **1 stud ≈ 0.28 m** **(verify)**, but what matters is consistency. Player avatars vary widely
(body scales, Rthro, roughly 3 to 7 studs **(verify)**); either fix avatar scaling in Game Settings →
Avatar or force a `HumanoidDescription` at spawn, and write the chosen rule in the art bible, or doors,
camera offsets and hitboxes will fit some players and not others. Consistency: the art bible fixes "character
= 5 studs, door = 7 studs, one floor = 12 studs" and every asset obeys it. In Blender, model at
1 unit = 1 stud and export with scale 1; check the imported bounding size in Studio against the art bible.

## Blender → Roblox

1. Model with real-world proportions per the bible; apply transforms (Ctrl+A: rotation, scale); origin at
   the pivot rule (bottom-center for props, feet for characters). Name objects `Categoria_Nombre_Variante`.
2. Triangulate implicitly on export; keep quads in source. Polycount within the class budget
   (bible § 7). Single material per mesh where possible; one UV set; texture atlas for small props.
3. Export FBX: selected objects, apply unit scale, mesh only (plus armature for rigged), no animation
   unless needed, forward -Z / up Y (Roblox's importer handles FBX defaults; verify orientation after import).
4. Import in Studio: Avatar Setup / 3D Importer (`File → Import 3D`); check "Import only as model" vs
   "Insert in workspace"; keep "Merge meshes" off for props with multiple parts you'll animate or color.
5. Set `MeshPart` properties: `CollisionFidelity` (Box for props, Hull/PreciseConvex only when needed),
   `RenderFidelity` Automatic, anchor static, `CanQuery`/`CanTouch` off where not needed.
6. Materials: flat colors via `Color`/`Material`; textures via `SurfaceAppearance` (ColorMap, NormalMap,
   RoughnessMap, MetalnessMap) at 512 or 1024; `TextureID` only for simple cases.
7. Save as `.rbxm` into `assets/rbxm/<category>/` (right-click → Save to File) and commit. The code
   inserts it by path at world build. Record bounding size, tris and texture size in `asset-list.md`.

The Blender MCP (`execute_blender_code`, `get_objects_summary`) can do steps 1 to 3 if connected.
Inspect the scene before changing it and keep its naming.

## Generated assets (Studio MCP)

`generate_mesh`, `generate_texture`, `generate_material`, `generate_procedural_model`, `segment_mesh`:
fast placeholders and secondary props. Review each result against the bible (scale, silhouette,
palette), fix the pivot, and save as `.rbxm` under `assets/rbxm/generated/`. Don't ship a hero asset
from a generator without an artist pass.

## Creator Store assets

`search_asset` / `insert_asset` from the MCP, or the Toolbox. Before using: creator, license/usage
terms **(verify per asset)**, polycount and texture size (many store assets are heavy), scripts inside
(delete any script that comes with a store model unless reviewed). Record id, creator, license in the
asset list. Prefer Roblox-created packs and well-known creators.

## Audio

Audio assets have usage permissions; many store sounds are only usable by their uploader or need
granting **(verify)**. Upload your own or use assets explicitly marked usable; test that the sound
plays in a published game, not only in Studio. Short SFX (< 1 s) in `.ogg`/`.mp3`; music loops
with clean loop points. Volumes per `SoundGroup`.

## UI assets

Icons as 2x PNG (e.g. 128 px for a 64 px slot), uploaded via Asset Manager; ids in a `UIAssets.luau`
table. 9-slice frames with `SliceCenter`. One font family (Roblox built-in fonts avoid upload).

## Images and moderation

Every uploaded image/mesh/audio passes moderation; plan a day for approvals before a gate. Names and
descriptions are moderated too. Keep a list of asset ids in `assets/README.md` with status.

## Budgets by class (defaults; bible overrides)

| Class | Tris | Texture | Notes |
|---|---|---|---|
| Small prop | ≤ 300 | 256 | atlas several props |
| Large prop | ≤ 1 500 | 512 | |
| Character / enemy | ≤ 3 000 | 512 | R15-compatible rig if animated with Roblox animations |
| Building / zone chunk | ≤ 10 000 | 1024 | split for streaming |
| Hero / centrepiece | ≤ 20 000 | 1024 | one or two per game |

## Placeholder → final swap

Placeholders are code-built parts with the final asset's name and bounding size. Final assets must
match the size (the asset list records it) and pivot; the world builder swaps by name without code
changes. QA checks that nothing moved.
