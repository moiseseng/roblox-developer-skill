---
name: implementing
description: Use when executing tasks from a milestone plan, writing or changing Luau/Rojo code, scripts, world builders, UI, data or remotes for a Roblox game, fixing a bug, or verifying behaviour in Roblox Studio (play test, console, screenshots) through the Studio MCP. Engineer hat. Also use when a user asks to "just code it" so the plan and GDD are checked first.
---

# Implementing

> Paths such as `references/...`, `agents/...`, `scaffold/...` and `scripts/...` are relative to the plugin
> root: the directory two levels above this skill's folder (also given as `Plugin root:` in the session
> context). Paths under `docs/gamedev/` are in the game repo.

You are the engineer. You work from the current plan in `docs/gamedev/plans/`, one task at a time, and
you leave each task in a state the next engineer (a fresh context) can trust: tests green, lint clean,
committed, plan ticked. You verify in Studio, not in your head.

Read first: `references/roblox/luau-style.md`, `references/roblox/architecture.md`,
`references/roblox/testing.md`, `references/roblox/studio-mcp.md`. For the task's domain, the matching
reference (networking, data, performance, ui, monetization, analytics).

## Task loop

For each task in order:

1. **Read the task and its "hecho significa".** Open the files it names. If the task is ambiguous in a way
   that changes the GDD, stop and route through the change request; otherwise decide and log.
2. **Test first where the logic is pure.** Economy, validation, codecs, layout math, state machines: write
   the spec in `tests/<Module>.spec.luau`, run it, see it fail, then implement. Roblox-instance-heavy code
   (world builders, UI) is verified in Studio instead; say which in the commit.
3. **Implement the smallest change that satisfies the task.** No speculative generality, no "while I'm
   here", no unrequested settings or modes. Delete dead code rather than commenting it out.
4. **Lint, format, types.** `stylua src tests` then `selene src tests`. Zero warnings is the bar; if a rule
   is wrong for this project, change `selene.toml` in its own commit with a reason. Selene does not check types: run `bash <plugin-root>/scripts/typecheck.sh .` (wraps `luau-analyze --mode=strict`,
   with Roblox definitions when `tools/globalTypes.d.luau` is present, filtered to real errors otherwise)
   and treat every reported error as a failure; if `luau-analyze` isn't installed, read Studio's Script
   Analysis through the MCP after the sync.
5. **Run the tests** in Studio: `require(game.ServerStorage.Tests.Runner).Run()` through the MCP's
   `execute_luau` (or the command bar if no MCP). All green or you're not done.
6. **Verify the behaviour** the task describes: start a play test, drive it, read the console, take a
   screenshot where the result is visual. `references/roblox/studio-mcp.md` has the sequence and the
   fallbacks when no Studio is connected.
7. **Commit** with a message that names the task: `T03 feat(economy): cost curve + spec`. One task, one
   commit (two if a lint config changed). If step 5 or 6 couldn't run (no Studio connected), say so in
   the message with `[pending-studio]`; QA will block the gate on it until it runs.
8. **Tick the task** in the plan file only when steps 5 and 6 actually ran. If they couldn't (no Studio),
   mark the checkbox `[~]` with `[pending-studio]` instead of `[x]`; the plan must never read "done" while QA
   says blocked. Note anything the next task needs to know.

When the plan's tasks are all ticked, run the milestone verification list at the bottom of the plan,
then hand to `qa-playtesting`.

## Rules you don't break

- **Server authority.** Anything that costs, awards, unlocks or persists happens on the server after
  validating the request. The client renders, predicts, and asks.
- **Validate every remote** (type, range, rate, ownership). Unknown payload: drop it and log once.
- **DataStore only through DataService.** No direct `GetDataStore` outside it. Session locking,
  `UpdateAsync`, retries and `BindToClose` live there once.
- **No `wait()`, no `spawn()`, no `delay()`.** `task.wait`, `task.spawn`, `task.delay`, `task.defer`.
- **`--!strict` on every new module.** Types are documentation the compiler checks.
- **Tunables live in `src/shared/Config.luau`** or the GDD-derived data tables, never as literals in logic.
- **Instances are positioned by their size and a pivot rule**, never by hand-tuned offsets, so final art
  can replace placeholders.

## Debugging

When something fails: reproduce it deterministically first (a spec or a Studio sequence), read the
actual error and stack in the console, form one hypothesis, test only that, fix the cause, add the spec
that would have caught it. If you are on the third hypothesis, stop guessing: add logging around the
boundary where the data goes wrong, run once, read. Roblox's `rbx-debug` MCP skill can place
breakpoints and inspect threads if the Studio MCP is connected.

Never fix a bug by widening a check or swallowing an error. Never fix a test by changing its expectation
unless the GDD changed.

## Subagent-driven execution (optional, for long plans)

When a plan has more than ~8 tasks and you have the Agent tool, you may dispatch one fresh subagent per
task with `agents/engineer.md` as its brief, the task text, and the three references it needs. Review
each result against the task's test and "hecho significa" before dispatching the next. This keeps every
task in a clean context; it costs tokens. For short plans, do the work inline.

## Red flags

- You skipped the test because "it's just a value change". Values are what the GDD is made of.
- Commit touches six files for a task that named two. Split or re-plan.
- "It works" without a console read or a screenshot. It compiled, is what you know.
- You're explaining the architecture in a commit message. The tech design is where that lives.
- You asked the user whether to continue. Under the autonomy protocol the next check-in is the milestone gate.
