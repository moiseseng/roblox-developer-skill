# Luau style

Formatting is `stylua` (tabs, 120 columns, double quotes). Lint is `selene` with `std = "roblox"`.
Both run before every commit; zero warnings.

## Rules

- `--!strict` at the top of every module and script. Type exported tables and public functions. Use
  `type Profile = { ... }` in the module that owns the shape and export it.
- Services via `game:GetService("Name")` at the top, once, `local Players = game:GetService("Players")`.
- `task.wait/spawn/defer/delay`. Never `wait()`, `spawn()`, `delay()`, `while wait() do`.
- Prefer events to polling. `Heartbeat` only for per-frame simulation; `RenderStepped` only for camera
  and input on the client; `Stepped` for pre-physics.
- Connections you create you disconnect: keep them in a table per object and clean on removal
  (Maid/Janitor pattern, a 20-line local implementation is fine; no dependency needed).
- `ipairs` for arrays, `pairs` for maps; generalized iteration (`for k, v in t do`) is fine in Luau and
  preferred for new code.
- Naming: `PascalCase` modules, services, controllers, types and instance names; `camelCase` locals and
  functions inside modules; `UPPER_SNAKE` for true constants; `_prefix` for intentionally unused.
- Module shape: a table with functions; state in locals captured by closures or in the table's private
  fields prefixed `_`. Return the table at the end. No side effects at require.
- Early returns over nested ifs. Max nesting 3.
- Errors: `error()` for programmer mistakes (bad arguments), return `(ok, reason)` for expected failures
  (purchase denied). `pcall` only around yielding external calls (DataStore, Marketplace, HTTP) with
  retry and logging; never a bare `pcall` that swallows.
- `warn` for things a developer must see; `print` only in DebugService or behind a `Config.Debug` flag.
- Comments say why, never what. If a function needs a comment to be understood, rename or split.
- No magic numbers in logic: `Config.luau` or the data table. The GDD and the code must share numbers
  through one source.
- Vectors: `Vector3.new`, `CFrame` math for orientation; never build CFrames from Euler angles in loops
  when a `CFrame.lookAt` or `:ToWorldSpace` says it.
- String formatting with `string.format` or interpolation `` `Coins: {coins}` ``.
- Return types matter on remotes: validate with `typeof(x) == "number"` and range checks before use.

## Patterns

**Service skeleton**

```lua
--!strict
local Players = game:GetService("Players")

local Signal = require(game.ReplicatedStorage.Shared.Signal)

local PlayerService = {}
PlayerService.Priority = 10
PlayerService.PlayerReady = Signal.new()

function PlayerService.Init()
	Players.PlayerAdded:Connect(function(player)
		-- wire, don't yield here
	end)
end

function PlayerService.Start()
	for _, player in Players:GetPlayers() do
		-- handle players already present when Start runs
	end
end

return PlayerService
```

**Validation helper**

```lua
local function isFiniteNumber(x: unknown): boolean
	return typeof(x) == "number" and x == x and x ~= math.huge and x ~= -math.huge
end
```

**Rate limit per player per remote**

```lua
local buckets: { [Player]: { [string]: { count: number, resetAt: number } } } = {}
local function allow(player: Player, key: string, maxPerSecond: number): boolean
	local now = os.clock()
	local p = buckets[player] or {}
	buckets[player] = p
	local b = p[key]
	if not b or now >= b.resetAt then
		p[key] = { count = 1, resetAt = now + 1 }
		return true
	end
	b.count += 1
	return b.count <= maxPerSecond
end
```

Clear `buckets[player]` on `PlayerRemoving`.
