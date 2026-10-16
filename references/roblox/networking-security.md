# Networking and security

Roblox replicates with FilteringEnabled always on: the client can change its own copy of the world and
its own character, and nothing else reaches the server unless a remote carries it. Exploiters run
arbitrary code on their client. Therefore: **the client is a renderer that sends requests.**

## Threat model

An exploiter can: fire any remote with any payload at any rate; move their character anywhere at any
speed; read every module replicated to the client (so `Shared` is public); change local values (coins
display, cooldown timers); delete client-side checks. They cannot: run server code, read ServerStorage
or ServerScriptService, change other players' characters directly, or change server-side state except
through remotes you expose.

## Rules for every remote handler

1. **Type check** every field: `typeof(x) == "number"`, finite, integer where expected; strings with a
   max length; tables with a known shape; instances exist and are of the expected class.
2. **Range check** against the data table (item exists, level ≤ max, amount ≥ 1 and ≤ cap).
3. **Ownership check**: the player may only act on their own profile, plot, character.
4. **State check**: the action is legal now (round active, cooldown passed, enough currency) using
   server state, never client-reported state.
5. **Rate limit** per player per remote (see `luau-style.md`). Drop silently on breach; log once per
   player per minute at most.
6. **Act, then reply.** Mutate server state, publish attributes, return `(true)` or `(false, reason)`.
   Reasons are short codes the client maps to text; don't leak internals.

Anything invalid: return/ignore. Never `error()` in a handler because of client input (it fills the
console and can be used to spam logs). Never kick on the first bad payload (lag and bugs produce them);
count strikes and kick on a clear pattern.

## Movement and physics

The client simulates its own character; the server sees position with latency. Server-side sanity
checks for anything movement-gated (race finish, zone reward, parkour time):

- max distance per tick given `WalkSpeed` and a tolerance (teleport detection);
- vertical sanity (no flying without an ability);
- corridor or checkpoint sequence for races (must pass checkpoints in order within plausible times);
- time measured by the server clock, not the client's report.

Reject the reward on failure; don't fight the character. Cosmetic cheats (walk-speed in a hub) are not
worth server code.

## Strikes, not instant kicks

```lua
local strikes: { [Player]: number } = {}
local function strike(player: Player, reason: string): ()
	strikes[player] = (strikes[player] or 0) + 1
	if strikes[player] == 1 or strikes[player] % 10 == 0 then
		warn(`[AntiCheat] {player.Name} strike {strikes[player]}: {reason}`)
	end
	if strikes[player] >= 25 then -- clear pattern, not lag
		player:Kick("Se detectó actividad inusual.")
	end
end
```

Clear on `PlayerRemoving`. `Players:BanAsync` exists for repeat offenders across sessions **(verify API
and policy)**; use it from a reviewed admin path, never automatically on the first pattern.

## Player-authored text and chat (kids platform)

- Every string a player types that others can see (names of pets, plots, messages, signs) goes through
  `TextService:FilterStringAsync` on the server, and the *filtered* result is what's stored and shown.
  Unfiltered text displayed to others is a policy violation that can take the game down.
- Chat is `TextChatService` **(verify current defaults)**; configure channels and whether chat exists at
  all in the GDD's social section. Age guidelines affect chat and voice availability.
- `PolicyService` decides per player what can be shown or sold; cache it at join (see `monetization.md`).

## What not to replicate

- Server-only data tables (drop rates, hidden values): `ServerStorage` or `ServerScriptService`.
- Future content or event flags that spoil: keep server-side until live.
- Other players' private data: never send a profile to a client other than its owner; publish public
  fields as attributes.

## Payload hygiene

Keep payloads small and flat. Batch high-frequency updates (positions, scores) and send on a timer;
prefer attributes for slowly changing state. `UnreliableRemoteEvent` for visual streams; never for
anything the server must act on.

## HTTP and external

`HttpService` only from the server, only if the game needs it (webhooks, external APIs). Secrets through
Secrets Store, never in code. Off by default in published settings.

## Checklist (QA exploit pass uses this)

For each remote: wrong type · missing field · negative · huge · NaN/inf · very long string · for an item
not owned · for another player · 50 Hz for 5 s · during the wrong state. Expected: ignored, no server
error, no reward. Plus: a player-typed string with profanity reaches other players filtered; a
speed/teleport exploit on the client does not earn the server-side reward; `Touched`-based rewards
(client-influenced) are confirmed by a server distance check.
