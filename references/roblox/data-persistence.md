# Data persistence

Players forgive an ugly game; they do not forgive lost progress. Data is an M0 feature.

## DataStore rules

- **One DataService.** All `DataStoreService` calls go through it. Other services ask for the profile
  table and mutate it in memory; DataService saves.
- **Session locking.** A profile is loaded with `UpdateAsync` that writes a lock `{ jobId, time }`. If
  another server holds a fresh lock (younger than ~2 min **(verify)**), wait and retry a few times, then
  refuse to load (kick with a friendly message) rather than loading stale data and overwriting newer
  data later. Release the lock on save-at-leave. This is what ProfileService / ProfileStore do; the
  scaffold's DataService implements a minimal version. Prefer the scaffold unless the GDD needs
  ProfileStore features (global updates, metadata); then add the dependency with wally and log the decision.
- **`UpdateAsync`, not `SetAsync`,** for anything that could be written from two places. The
  transform function must be pure and fast; return `nil` to abort.
- **Retry with backoff** on any DataStore error: 3 attempts, 1 s → 2 s → 4 s; log the final failure;
  never crash the player's session because a save failed.
- **Autosave** every 2 to 5 minutes per player, staggered; **save on `PlayerRemoving`**; **`BindToClose`**
  saves everyone and waits (Studio: skip the wait so stop doesn't hang, but still save).
- **Budget.** Requests per minute are limited **(verify current limits)**; one profile per player, one
  key per profile, no per-item keys.
- **Schema version** inside the profile: `version = 1`. Migrations are a list of functions
  `[v] = function(data) ... end` applied in order on load; add defaults for new fields with a
  `reconcile(data, template)` that fills missing keys without overwriting existing ones.
- **Studio:** `DataStoreService` works only with "Enable Studio Access to API Services" on. Detect
  failure and run in memory with a visible warning; never let a dev session think it saved when it didn't.
- **Never store** instances, functions, CFrames or mixed arrays; only JSON-compatible tables of
  numbers, strings, booleans and nested tables with string keys or dense arrays. Keep the profile
  under a few hundred KB **(limit verify)**.

## Leaderboards

`OrderedDataStore` keyed by userId, value is the score (integer). Write on milestones (end of run,
every N seconds while a value changes), not every change. Read the top 100 on a server timer (60 s) and
publish once; clients render from the published table. Usernames via `Players:GetNameFromUserIdAsync`
with a cache.

## Cross-server

`MemoryStoreService` (queues, sorted maps, hash maps) for things that live minutes, not forever:
matchmaking, live events, global counters. `MessagingService` to broadcast small messages
(announcement, "player X got a world record"). Both have rate limits **(verify)**; wrap with pcall and
fallbacks.

## Monetization data

Purchases are recorded in the profile inside `ProcessReceipt`, with the `PurchaseId` saved so a repeated
receipt is ignored (idempotency). Return `PurchaseGranted` only after the save succeeds; otherwise
`NotProcessedYet` and Roblox retries. See `monetization.md`.

## GDPR / right to be forgotten

Have a Studio-only command (DebugService) that deletes a profile by userId; Roblox may send removal
requests. Log the command in the README.

## Testing data code

Pure parts (migrations, reconcile, the transform in UpdateAsync) are unit-tested with the runner using
plain tables. The DataStore wrapper is tested in Studio with API access on: join, change, leave, rejoin,
verify; then with the lock scenario simulated by seeding a fresh lock.
