# Market and design on Roblox

What this file is: patterns that repeatedly show up in retained Roblox games, to inform discovery and
GDD questions. What it isn't: numbers to quote. Where a figure appears it is marked **(verify)**; check
Creator Hub, the Creator Docs or current charts before telling the user.

## The platform in one paragraph

Roblox is a social platform where most play is on phones **(verify current share; historically a
majority)**, players are young and skew towards short, repeated sessions with friends, discovery comes
mostly from the home page's recommendation surfaces, search, friends' activity and sponsored ads, and
revenue comes from Robux spent inside experiences plus engagement payouts. Games are updated
constantly; the ones that survive ship weekly.

## Genres that retain (and why)

| Genre | Loop | Why it works | Watch out |
|---|---|---|---|
| Simulator / incremental | click/collect → sell → upgrade → bigger numbers; rebirth | always a next goal, visible progress, works with a thumb | shallow after week 1 without content cadence |
| Tycoon | buy buttons → base grows → income | ownership, visible to others, relaxing | pay-to-skip dominates if not careful |
| Obby / parkour | run → fail → retry → checkpoint | instant restart, skill expression, short sessions | needs great feel; mobile controls |
| Horror / escape | explore → tension → chase/escape round | strong social moments, streamable | round-based churn if no meta |
| Roleplay / life | hang out, roles, houses, cars | social glue, long sessions | huge content needs; moderation |
| Fighting / battlegrounds | PvP rounds, abilities | mastery, competitiveness | balance, exploits, toxicity |
| Tower defense / survival | waves, co-op, build | co-op with friends, clear goals | difficulty curve, late-game |
| Hangout / minigames | rounds of small games | easy to join, social | retention without progression |
| Pet / collection | hatch, collect, trade | collection drive, trading economy | gambling-adjacent rules; inflation |

Hybrids win: a simulator loop plus an obby skill layer (SlimeRun), a tycoon with a survival round.

## What the first week looks like for a game that works

- Minute 1: the loop is understood without text; first reward in 30 s.
- Minute 10: first meaningful upgrade; the player sees what the next 20 minutes bring.
- Day 1: there is a reason to come back (offline earnings, daily reward, a goal that was just out of reach).
- Day 7: social hooks fired (friend saw it, group, leaderboard) and an update landed.
- Players tell their friends about a *moment*, not about features. The GDD's "el momento" is the pitch.

## Discovery levers you control

Title (genre word + hook, searchable), icon (a character or object, no text, readable at 64 px), 3 to 5
thumbnails of the moment, description first sentence, genre tags, age guidelines, update frequency,
sponsorship budget (optional). Everything else is retention; the home page rewards it.

## Economy patterns

- Cost curves: `cost(n) = base * growth^n`, growth 1.07 to 1.20 for frequent upgrades, 1.5 to 2.5 for
  rare ones. Earn rate must grow with upgrades so the time-to-next-upgrade stays roughly flat (the
  "soft wall" appears when it doubles).
- Rebirth/prestige: resets currency and upgrades for a permanent multiplier; first one around day 1 to 2.
- Offline earnings capped (e.g. 8 h **(design choice)**), claimed on join, with a paid 2x.
- Two currencies: soft (earned, spent on progression), hard (rare drops + Robux, spent on cosmetics
  and conveniences). Never let hard currency buy raw power unless the GDD stance allows.
- Numbers formatted (1.2K, 3.4M, 5.6B…) from minute 5; the GDD table decides the pacing.

## Session design

Target 10 to 20 minutes for simulators/tycoons, 3 to 8 minutes per round for round-based games with
a meta that spans rounds. A session ends on a goal reached, not on boredom: show the next goal and the
time to it. Daily hooks: daily reward, timed events, friends online.

## Social

Visible progress (your base, your pets, your lane) is a social feature. Leaderboards with weekly resets
beat all-time ones. Co-op mechanics (shared boss, trade, gifting) raise retention more than PvP for
young audiences. Servers of 6 to 12 for simulators, 20 to 30 for roleplay, 8 to 16 for rounds
**(design choice)**.

## Content cadence

Plan the first three updates in the GDD's live-ops section: new zone/pets/event every 1 to 2 weeks at
launch. Updates are discovery events; the store page says "UPDATE" and the icon changes.

## Red flags in a concept

- No reason to return tomorrow.
- The fun requires 4 friends and a working voice chat.
- A moment that can't be shown in a thumbnail.
- More than one core loop in v1.
- A monetization stance that contradicts a pillar.
