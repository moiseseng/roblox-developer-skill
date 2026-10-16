# Analytics and live-ops

You can't iterate on opinion. The GDD's § live-ops names the targets; this file says how to measure
and how to change the game without republishing.

## Events (AnalyticsService)

Roblox's `AnalyticsService` has typed events that feed the Creator Hub dashboards **(verify API names
against docs; they have changed)**:

- **Onboarding funnel** (`LogOnboardingFunnelStepEvent`): one step per tutorial step. The step where
  the curve drops is your first iteration target.
- **Progression** (`LogProgressionEvent`): start/complete/fail per level, zone, prestige.
- **Economy** (`LogEconomyEvent`): every source and sink with currency name, amount, balance, item sku.
  Expect to see where currency piles up (sinks too weak) or starves (sources too weak).
- **Custom** (`LogCustomEvent`): sparingly; the dashboards favour the typed ones.
- **Funnels** (`LogFunnelStepEvent`): shop open → item view → prompt → purchase.

Wrap in one `Analytics` service with one function per event and the player's session id; call sites
stay simple and QA can grep them. Fire from the server only (clients lie). Don't log per-frame things.

## Dashboards to read in week one

Retention (D1, D7), average session, engagement by platform, the onboarding funnel, economy flow,
monetization per item, errors (Developer Console / Error Report). Compare against GDD § 12 targets and
write `docs/gamedev/iteration-brief.md`.

Typical healthy signs **(verify, genre-dependent)**: D1 around 20 to 40% for casual genres; sessions 10 to
20 minutes; first purchase conversion single-digit percent. A strong game isn't above all of these;
it's above its own last week.

## Changing values live

Hard-coded constants need a republish. Use a config layer:

- Roblox **Experience Configs / ConfigService** (`rbx-configs-experimentation` MCP skill) for live
  values and A/B experiments **(verify availability)**; or
- a `Config` DataStore key read on server start with a 5-minute refresh, plus `MessagingService` to
  push a refresh; or
- at minimum `Config.luau` with every tunable, so a republish is a one-file change.

Flag anything risky: new mechanic, event, price, difficulty. A flag has a default, an owner and an
expiry date in `release-checklist.md`.

## Events and seasons

Designed in the GDD's live-ops section first (what, when, reward, what it teaches about the players).
Implemented as data + a flag, scheduled by server time (`os.time()` against a UTC start/end), tested by
QA with the flag forced.

## Experiments

One variable, one metric, enough players (hundreds per arm at least), a week. Write the hypothesis in
the iteration brief before turning it on.
