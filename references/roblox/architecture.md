# Architecture

## Shape

Three layers, mirrored by the folder layout:

- **Shared** (`ReplicatedStorage.Shared`): pure modules both sides require. Config, Economy formulas,
  Remotes declaration, Signal, Loader, codecs, layout math, format helpers. No instances created here, no
  side effects at require time.
- **Server** (`ServerScriptService.Server`): one entry `init.server.luau` that runs the Loader over
  `Services/`. Each service is a table with optional `Priority`, `Init()` and `Start()`. World builders
  live in `World/` and are called by a `WorldService`.
- **Client** (`StarterPlayerScripts.Client`): one entry `init.client.luau` that runs the Loader over
  `Controllers/`. Same lifecycle. UI, camera, input, effects, sounds.

Lifecycle: the loader requires every module, calls all `Init()` (sorted by `Priority`, lower first),
then all `Start()` in their own `task.spawn`. `Init` wires state and listeners without touching other
modules' state; `Start` is where work begins. This removes require-order bugs.

## Services per typical game (name → responsibility)

| Service | Owns |
|---|---|
| DataService | Profiles: load/lock/save/release, `UpdateAsync`, migrations, `BindToClose` |
| PlayerService | PlayerAdded/Removing, character spawn, attributes publishing |
| EconomyService | Award/spend through Economy formulas; the only writer of currency |
| ShopService | Purchase validation, catalog from shared data tables |
| WorldService | Builds the map from `World/` builders at start; owns spawn points |
| <Loop>Service | The game's core loop rule enforcement (round, run, wave...) |
| LeaderboardService | OrderedDataStore reads on a timer, writes on milestones |
| MonetizationService | MarketplaceService: passes, products, `ProcessReceipt` |
| AnalyticsService (wrapper) | Funnel/economy/progression events with one call site per event |
| DebugService | Studio-only commands (`RunService:IsStudio()`), never in production paths |

Controllers mirror: HudController, ShopController, InputController, CameraController,
EffectsController, SoundController, TutorialController.

## Remotes contract

Declare once in `src/shared/Remotes.luau`:

```lua
return {
	-- name = kind
	RequestPurchase = "RemoteFunction",
	ActionReport = "RemoteEvent",
	Notify = "RemoteEvent",
	StateDelta = "UnreliableRemoteEvent", -- high-frequency, loss-tolerant
}
```

The server creates them under `ReplicatedStorage.Remotes` at `Init`; clients `WaitForChild`. Every
handler: validate (type, range, ownership, rate) → decide → mutate → reply. The client never computes an
award; it reports an action and renders the server's answer. Payloads are plain tables of primitives.

Use `UnreliableRemoteEvent` for position/visual streams where a dropped packet doesn't matter;
`RemoteEvent` for anything that must arrive; `RemoteFunction` only client→server when the client needs a
reply, never server→client (a hanging client stalls the server).

## State

- **Public, observable state** goes in Attributes on the owning instance (player, plot model, round
  folder): cheap, replicated, `GetAttributeChangedSignal`, visible in the explorer. Example: a player's
  coins, best time, level; a plot's owner and tier.
- **Private state** stays in the service's table.
- **Derived state** (formatted text, progress bars, predicted next cost) is computed on the client from
  attributes and shared formulas; never replicated.
- **Transient events** (hit, pickup, level-up) are remotes, not attributes.

## Data tables, not code

Items, upgrades, enemies, levels: Luau tables in `src/shared/Data/*.luau` with types. Adding content
means adding a row. Code reads the table; no `if itemName == "Sword"` chains. Pair each table with a spec
that validates integrity (unique ids, prices positive, references resolve).

## Tags and CollectionService

Objects that need behaviour (pickups, doors, hazards) get a tag and a per-tag controller that handles
`GetInstanceAddedSignal`/`RemovedSignal`. Works with streaming and with code-built worlds.

## Character

Custom movement (coyote time, buffered jump, dash) lives in `StarterCharacterScripts` as a client script
plus server sanity checks (max speed, teleport distance per tick, grounded checks) in the loop service.
The client owns feel; the server owns truth.

## Anti-patterns

- Logic in `init` scripts or in Studio-placed scripts that aren't in `src/`.
- A `Main` module everyone requires (cycles). Shared modules don't require services.
- `_G` or `shared` for state.
- A service that reaches into another service's private table. Expose a function or a Signal.
- Yielding in `Init`. Yield in `Start`.
