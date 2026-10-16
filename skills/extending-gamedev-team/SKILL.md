---
name: extending-gamedev-team
description: Use when someone wants to add, change or improve a gamedev-team skill, add a new role, add a new engine (Godot, Unity, Unreal) or a new reference file, write or run the plugin's evals, or when a skill was followed and produced a poor result that should be fixed at the source. Meta skill for growing the plugin.
---

# Extending gamedev-team

> Paths such as `references/...`, `agents/...`, `scaffold/...` and `scripts/...` are relative to the plugin
> root: the directory two levels above this skill's folder (also given as `Plugin root:` in the session
> context). Paths under `docs/gamedev/` are in the game repo.

The plugin grows the way a studio does: a lesson learned on one game becomes a rule, a template or a
reference so the next game doesn't relearn it. Keep that discipline: fix the skill, not just the project.

Layout (plugin root):

```
.claude-plugin/        plugin.json, marketplace.json
hooks/                 SessionStart injects using-gamedev-team
skills/<name>/         SKILL.md (+ assets/, references/, scripts/ local to the skill)
agents/<role>.md       reviewer / worker briefs per role
references/<engine>/   engine knowledge shared by all skills (roblox/ today)
references/design/     cross-engine design knowledge (player psychology)
scaffold/<engine>/     verified starter project
scripts/               new-game.sh, doctor.sh
evals/evals.json       test prompts for the skill-creator loop
```

## Adding or changing a skill

1. Frontmatter: `name` equals the folder name; `description` starts with "Use when" and lists *triggering
   situations only*. Don't summarize the workflow in the description: the model then follows the
   description and skips the body.
2. Body under ~150 lines. Explain why, not only what; prefer a reason over an all-caps MUST. Put heavy
   knowledge in `references/`, templates in `assets/`, deterministic work in `scripts/`.
3. Add a "Red flags" table or list: the rationalizations the model actually used when it went wrong.
4. Add the row to the pipeline table in `skills/using-gamedev-team/SKILL.md` if it is a phase.
5. Add one realistic prompt to `evals/evals.json` and run it with the skill-creator loop (or at least
   one subagent with the skill) before committing.

## Adding an engine

1. `references/<engine>/README.md` as an index, then the same file set as `references/roblox/`
   (architecture, style, networking, data, performance, ui, monetization, analytics, testing, asset
   pipeline, market, tooling, publishing). Write what the engine actually does; mark unverified numbers.
2. `scaffold/<engine>/` that builds and lints with the engine's tools. Verify mechanically before shipping.
3. Teach `scripts/new-game.sh` the engine (`--engine <name>`).
4. In each phase skill, the "Read first" lists reference Roblox files; make them `references/<engine>/`
   by the project's engine (recorded in `docs/gamedev/state.md` as `engine:`).
5. Market knowledge is engine- and platform-specific; don't copy Roblox's.

## Adding a role

A role is an `agents/<role>.md` brief (identity, what it reviews, what it refuses to let pass, output
format) plus the moments in phase skills where it is dispatched. Add the row in the roles section of
`using-gamedev-team`.

## Running evals

Use the skill-creator skill's loop: prompts in `evals/evals.json`, with-skill and baseline subagents,
grade against the expected outputs, review in the viewer. Store workspaces as `gamedev-team-workspace/`
next to the plugin (git-ignored).

## When a skill fails in the field

Write down what the model did, what it should have done, and which sentence in the skill would have
prevented it. Add that sentence (or a red flag) and the eval prompt that reproduces it. That's the
whole loop.
