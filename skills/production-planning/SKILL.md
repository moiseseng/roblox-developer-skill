---
name: production-planning
description: Use when the GDD, tech design and art bible exist and the next milestone (M0 prototype, M1 vertical slice, M2 alpha, M3 beta, M4 release) needs a task plan, when the user asks "what's next", for a roadmap, estimates or a sprint, or when an approved change request needs to become tasks. Producer + dev-lead hat. Produces docs/gamedev/plans/YYYY-MM-DD-<milestone>.md.
---

# Production planning

> Paths such as `references/...`, `agents/...`, `scaffold/...` and `scripts/...` are relative to the plugin
> root: the directory two levels above this skill's folder (also given as `Plugin root:` in the session
> context). Paths under `docs/gamedev/` are in the game repo.

You are the producer with the dev lead beside you. A milestone plan turns the GDD and the tech design
into tasks small enough that each can be built, tested and committed in one sitting by an engineer who
has only the plan and the repo in front of them. The plan is shorter than the code it describes, and it
never decides what the implementer can reasonably decide.

Inputs: `gdd.md`, `tech-design.md`, `art-bible.md`, `asset-list.md`, `state.md`, previous plans and QA
reports. Output: `docs/gamedev/plans/YYYY-MM-DD-<milestone>.md` (template in `assets/plan-template.md`).

## Milestones

| Milestone | Definition of done | Typical content |
|---|---|---|
| **M0 prototype** | The core loop is playable end to end with grey boxes, data persists, one person can judge if it's fun. | Scaffold, Economy + spec, world from code, movement, the loop's 2-3 mechanics, HUD text, DataService wired. |
| **M1 vertical slice** | One slice of the game at final quality: art, UI, audio, feel. The pitch video could be shot here. | Final assets for the slice, UI screens, SFX/music, tutorial, polish on feel. |
| **M2 alpha** | All v1 systems and content from the GDD exist; rough is fine. | Remaining mechanics, content tables, shop, monetization wiring (test mode), analytics events. |
| **M3 beta / soft launch** | Published privately or to a small group; stable, no data loss, metrics flowing. | Bug fixing, performance, exploit tests, device matrix, publishing checklist, flags. |
| **M4 release** | Public, with a live-ops plan. | Store page, icon/thumbnails, launch config, iteration brief. |

**M0 and fun.** M0 is done when the owner has played it for five minutes on their phone and QA's
minute-by-minute table matches GDD §3 (minute 3 looks like the GDD said). "Playable" is not the bar;
"someone wanted to keep going" is. If it isn't fun grey, route back through the GDD change request before
any M1 art; that is the cheapest moment the pipeline has.

**M1 and feel.** The slice isn't at final quality until the core action answers inside the feedback
budgets in `references/design/player-psychology.md` and `references/roblox/game-feel.md` (input response,
three channels, celebration scaled to rarity), the build passes the reward-loop audit at the first 60 s
and minute 3, a good session has a release moment to end on, and nothing earned is lost by leaving. Each is
a task with a Studio check against GDD §13 and the M1 feel checklist in `game-feel.md`. In step 6, dispatch
`agents/player-psychologist.md` with the GDD, the plan and that reference alongside the designer review
for the M1 plan.

Small games merge M2 and M3; say so. Never skip M0: it's where the GDD meets reality cheapest.

## Process

1. **Read state and the last QA report.** Carry forward open bugs as tasks at the top of the plan.
2. **Pull the milestone's scope** from the GDD's v1 list and the systems map in the tech design. Each
   system becomes 1 to N tasks; each asset in the list for this milestone becomes a task.
3. **Write tasks** with the template fields: goal (one sentence), files to create or change (exact
   paths), the test that proves it (spec name and what it asserts, or the Studio check), acceptance from
   the GDD's "hecho significa", and dependencies. Each task is S (≤ 1 h) or M (≤ 3 h); L (≤ 1 day) only
   for art production. If it's bigger, split; if it needs a decision, make it here and log it.
4. **Order** by dependency, then by risk (riskiest first; the earlier a plan is wrong, the cheaper).
5. **Self-review against the GDD and tech design.** Every v1 system of the milestone has tasks; every
   task has a test or a named QA check; no task says "and also"; file paths exist or are created by an
   earlier task; types and names match the tech design.
6. **Designer and producer review.** Dispatch `agents/game-designer.md` (Agent tool,
   `subagent_type: gamedev-team:game-designer`) with the GDD and the plan: does the plan build the designed
   game, and is anything in the plan not in the GDD? Dispatch `agents/producer.md`
   (`gamedev-team:producer`) with the plan, the discovery brief and the last QA report: scope, order,
   estimates against what the owner said about time, gate demo described in three steps. Fix both.
7. **Hand off.** Update `state.md` (`phase: 5-build`, `milestone: M0`, `next_gate: M0 demo`) and
   start `implementing`. No user check-in is needed here under the autonomy protocol.

## Estimates

Give a range per task (S ≤ 1 h, M ≤ 3 h, L ≤ 1 day) and a total per milestone in days of focused work.
Don't promise calendar dates; the user knows their calendar. If the total exceeds what the discovery
brief said they wanted before "jugable", say so and propose what to cut, before building.

## Red flags

- A task without a file path or a test. It's a wish, not a task.
- "Implement the shop" as one task. Shop = data table, server purchase validation, client UI, remote,
  spec, placeholder art. Five tasks.
- The plan re-explains the architecture. Link the tech design instead.
- M0 includes final art or a tutorial. Those are M1.
- You asked the user to approve the plan. The GDD was the approval; the M0 demo is the next gate.
