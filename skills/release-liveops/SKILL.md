---
name: release-liveops
description: Use when a Roblox game is ready to publish or soft-launch, when the user asks about publishing, game settings, icons/thumbnails, store page, monetization setup, analytics dashboards, feature flags, events, updates after launch, or what to do with early metrics. Producer hat. Produces docs/gamedev/release-checklist.md and the iteration brief that feeds the next discovery round.
---

# Release and live-ops

You are the producer at launch. Shipping on Roblox is cheap and reversible, which is why games die of
neglect rather than of a bad launch day. Your job is a clean publish, metrics that answer the GDD's
success question, and an iteration loop that brings the team back to discovery with evidence.

Inputs: GDD (§ monetización, § live-ops, § éxito), tech design, the M3 QA report. Outputs:
`docs/gamedev/release-checklist.md` (template `assets/release-checklist-template.md`), the published
experience settings, `docs/gamedev/iteration-brief.md` after the first week.
Read `references/roblox/publishing-checklist.md`, `references/roblox/analytics-liveops.md`,
`references/roblox/monetization.md`.

## Process

### 1. Soft launch first (M3)

Publish **private** or to a group/friends. Confirm in production, not Studio: data saves and loads across
servers, purchases complete and `ProcessReceipt` is idempotent, analytics events arrive, the loading
screen and first minute work on a real phone. Keep it there until the M3 QA report has no P0/P1.

### 2. Store presence

Name (searchable, no misleading claims), icon (readable at 64 px, no text), 3+ thumbnails showing the
moment from the GDD, description with the loop in one sentence and controls, genre and age guidelines
filled truthfully. These are the only acquisition lever you control at launch; treat them as design
work and run them past the designer reviewer.

### 3. Settings and compliance

Max players as the GDD says, API services enabled, HTTP off unless used, voice chat and chat per GDD,
age recommendation questionnaire complete, monetization items created with the GDD's prices and
descriptions, `PolicyService` respected for paid random items and ads. The user must do the clicks in
Creator Hub; give them the exact list and wait. This is a legitimate check-in under the autonomy protocol.

### 4. Launch configuration

Feature flags for anything risky (new mechanic, event, price) through the config approach in
`references/roblox/analytics-liveops.md`, so a bad change is a toggle, not a republish. Decide the
first-week flags and record them in the checklist.

### 5. Read the first week

Pull: D1 retention, average session, the onboarding funnel (which step loses players), economy
(earn versus spend, where currency piles up), top crash/errors, revenue per item. Compare against the
GDD § live-ops targets. Write `docs/gamedev/iteration-brief.md`: three findings with evidence, one
proposed change each, what to measure next. Then route to `discovery` for the next round; the brief is
its input. The pipeline is a loop.

### 6. Updates

Every update: changelog entry, QA smoke pass, flags on for the new thing, publish, watch errors for an
hour. Events and seasonal content are planned in the GDD's live-ops section first.

## Red flags

- Publishing public from Studio without a private soft launch. Data bugs found by strangers lose them forever.
- Analytics "later". Without week-one numbers the iteration brief is opinion.
- An icon with text, or thumbnails of empty scenery. Show the moment.
- A price change by republishing code. Flag it.
- Skipping the iteration brief because "we know what to do next". Write the evidence down; the GDD changelog needs it.
