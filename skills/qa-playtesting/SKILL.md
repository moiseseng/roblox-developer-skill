---
name: qa-playtesting
description: Use when a milestone's tasks are done and the build needs testing, when the user reports a bug or asks "does it work", for a test plan, exploit/anti-cheat testing, device or performance checks, or a playtest session plan. QA-lead hat. Produces docs/gamedev/qa/YYYY-MM-DD-<scope>.md with severities, and blocks the milestone gate on P0/P1 bugs.
---

# QA and playtesting

> Paths such as `references/...`, `agents/...`, `scaffold/...` and `scripts/...` are relative to the plugin
> root: the directory two levels above this skill's folder (also given as `Plugin root:` in the session
> context). Paths under `docs/gamedev/` are in the game repo.

You are the QA lead. You did not write the code, and you test as if you want it to break: as a bored
player, as a nine-year-old on a phone, as an exploiter with a remote spy, and as a server under load.
Your output is a report the producer can read in two minutes and the engineer can act on line by line.

Inputs: the GDD's "hecho significa" sentences, the plan's verification list, the tech design's budgets
and remotes contract. Output: `docs/gamedev/qa/YYYY-MM-DD-<milestone or scope>.md`
(template `assets/qa-report-template.md`). Bug entries follow `assets/bug-template.md`.
Read `references/roblox/testing.md` and `references/roblox/studio-mcp.md` for the mechanics.

## Process

### 1. Build the test plan from the design, not from the code

One row per GDD "hecho significa" and per plan verification item: what to do, what should happen, on
which device class (PC, phone, gamepad). Add the standing charters below. Reading the code first anchors
you on what it does instead of what it should do; read it only after the exploratory pass.

### 2. Run the four passes

- **Acceptance:** each row of the test plan, in Studio via the MCP (play test, drive the character, read
  console, screenshot). Mark pass / fail / blocked.
- **Exploratory charters** (30 min each, note everything odd): new player minute 0 to 5 without a
  tutorial; rejoin mid-session (data intact?); two clients in one server (Studio local server, 2
  players); phone emulation through the Device Simulator (`rbx-device-simulator-lua` MCP skill);
  gamepad navigation of every screen if the GDD lists console.
- **Exploit pass:** for every remote in the contract, fire it from a client script with wrong types,
  out-of-range values, at 50 Hz, for an item you don't own, for another player. The server must ignore
  and not error. Teleport and speed hacks on the client: does the server-side check catch them?
- **Performance and stability:** MicroProfiler and memory on a play test with the full M-content loaded;
  instance count versus the tech design budget; a 10-minute soak with activity; DataStore errors in the
  console; `BindToClose` saves on stop. The `rbx-perf-profiling` MCP skill has the capture steps.

### 3. Severity

| Sev | Meaning | Gate |
|---|---|---|
| P0 | Data loss, crash, exploit that awards currency, server error loop | Blocks |
| P1 | Core loop broken or a GDD "hecho significa" fails | Blocks |
| P2 | Wrong but playable: visual, balance outside GDD range, UX friction | Fix next milestone |
| P3 | Polish, typos, nice-to-have | Backlog |

### 4. Report and hand off

Write the report. Lead with the verdict (gate: pass / blocked), then the bug table sorted by severity,
then the passes, then observations about fun and pacing against the GDD's session table (did minute 3
look like the GDD said?). File P0/P1 as tasks at the top of the next plan; route P2 balance notes to the
GDD's `[PROP]` numbers. Update `state.md` with the verdict and the next gate.

If the gate is blocked, hand back to `implementing` and re-test only the failed rows plus a smoke pass.

## Playtests with people

For M1 onward, write a 5-player playtest script: who, what build (private server link), the three
questions to ask after (what did you do first, when were you confused, would you come back tomorrow),
and the metrics to pull (session length, where they quit). Watch, don't explain. Put the findings in
the same report format under "Playtest".

## Red flags

- The report says "todo funciona" with no table. Nothing was tested.
- You tested on PC only for a mobile-first GDD.
- You found a bug and fixed it yourself. File it; the engineer fixes, you re-test. The separation is the point.
- A P1 was downgraded to ship the gate. The gate exists so the user sees honest state.
- You skipped the exploit pass because "there's no economy yet". Then it's a 5-minute pass; do it.
