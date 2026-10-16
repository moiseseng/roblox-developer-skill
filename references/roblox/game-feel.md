# Game feel

Feel is the part of fun that no GDD table captures and every player notices in the first ten seconds.
It is the difference between a button that "works" and one that is satisfying to press. On Roblox, where
the competition is one tap away, feel is retention. The psychology behind it (why the brain rewards
fast, layered, proportionate feedback) is in `references/design/player-psychology.md`; this file is how to
build it in Luau.

## The three channels, every time

Every player action gets feedback on three channels at once, inside the input-response budget
(≤ 100 ms **(verify)**; in practice "the same frame" for the visual channel):

| Channel | Cheap default | What makes it feel professional |
|---|---|---|
| Visual | tween the target (scale punch 1.0 → 1.15 → 1.0 in 0.15 s), color flash, particle burst | anticipation before impact, squash-and-stretch, a short hit-stop (freeze 30–60 ms) on big hits, number pops that arc and fade |
| Audio | one short SFX, pitch ± 5–10 % random | layered: a transient (click/thud) + a body (tone) + a tail for rare events; a "rising" family for streaks |
| UI / haptic | counter increments with a tween, bar fills with easing | `HapticService` pulse on mobile for impacts (verify API), counter "roll" instead of jump, bar overshoot on milestones |

Scale the celebration to rarity: common pickups are 0.15 s and quiet; a level-up is 0.6–1 s, has a
flash, a chord and a brief camera push; a prestige is a sequence. If everything is loud, nothing is.

## Tweens and curves

`TweenService` with `TweenInfo(duration, EasingStyle, EasingDirection)`:

- UI pops and pickups: `Back`/`Out` or `Elastic`/`Out`, 0.15–0.3 s.
- Bars and counters: `Quad`/`Out`, 0.2–0.4 s; never linear.
- Camera and large objects: `Sine`/`InOut`, 0.3–0.8 s.
- Something dying or disappearing: `Quad`/`In` (accelerates away).

Never tween on `RenderStepped` by hand when `TweenService` does it; never chain `task.wait` for animation.
Cancel the previous tween on the same property before starting a new one (store it per instance).

## Numbers that feel good

- Counter rolls toward the new value over 0.3 s (interpolate the displayed number, not the real one).
- Number pops at the point of impact, arc up and to the side, fade over 0.6 s, slightly larger for criticals.
- Format with suffixes (`Economy.format`) from the first thousand; a long raw number reads as noise.
- Bars: fill with easing, overshoot 3–5 % on a full bar, flash on completion, then reset with a quick
  "drain" so the player sees the next goal start.

## Camera

Default Roblox camera is fine for most genres; feel comes from small policies, not a custom camera:

- Zoom limits per GDD (`CameraMaxZoomDistance`, `CameraMinZoomDistance`), a default distance set on spawn.
- FOV: 70 default; a brief push to 75–80 on sprint/dash, back on stop (tween 0.2 s).
- Shake: only for big impacts, tiny amplitude (0.2–0.5 studs), 0.15–0.3 s, with a "reduce motion" option
  that disables it. Implement with `Camera.CFrame` offsets on `RenderStepped` for the shake duration only.
- Never take control of the camera during the core action without the GDD saying so.

## Character and movement

- Jump and landing: a squash on landing (scale the character model's `Humanoid` via `HumanoidDescription`
  scales is heavy; use a short animation or a dust particle instead), a dust puff, a landing thud.
- Responsiveness: coyote time (≈ 80–120 ms after leaving a ledge, verify by feel), jump buffering (press
  slightly before landing still jumps), instant turn. Implemented in `StarterCharacterScripts`.
- Speed lines, trails (`Trail` instance) and FOV push make speed feel fast without being fast.
- Hit reactions: knockback via `AssemblyLinearVelocity` impulse, a red flash, a hit-stop on the attacker's
  animation.

## Audio direction

- `SoundGroup` per category (Music, SFX, UI, Ambience) with volumes exposed in settings.
- Music: loops with clean points; duck music 20–30 % under celebrations; a different track or layer for
  the hub versus the action.
- SFX pooling: a small pool of `Sound` instances per effect, play the next free one, randomize `PlaybackSpeed`
  0.95–1.05, never `Sound:Play()` on an instance that's already playing (clips).
- Positional audio for world events (parent to the part, `RollOffMaxDistance` tuned); UI sounds in
  `SoundService` (non-positional).
- Silence is a tool: a beat of quiet before a rare reveal makes it land.

## Reading the world

- Interactables glow or bob; the thing to do next is the brightest thing on screen.
- Pickups: readable silhouette, idle bob (0.5 Hz, 0.2 studs), rotate slowly, a beam or arrow for the first one.
- Danger: red, sharp, animated; safe: round, calm.
- `Highlight` instance for selected/targeted objects (budget: few at once, verify limits).

## Mobile feel

- Touch targets ≥ 44 px, buttons react on press (not release) with a scale-down, confirm on release.
- One-thumb playable if the GDD says mobile-first: the core action is a tap or a hold, not a drag.
- Haptics on impacts and purchases; off switch in settings.
- Device Simulator pass for feel: a tap must feel instant on a low-end preset.

## The M1 feel checklist (QA runs it at the M1 gate)

- [ ] Core action: three channels, same frame, celebration proportional to rarity.
- [ ] Every counter and bar animates; nothing jumps.
- [ ] Landing, jump, hit have visual + audio.
- [ ] Camera: zoom limits set; shake only on big impacts; reduce-motion option works.
- [ ] Audio: music loops cleanly, ducks under celebrations, SFX pitch varies, no clipping.
- [ ] The next thing to do is the most visible thing on screen at minute 0, 3 and 10.
- [ ] Phone: taps feel instant; nothing under the thumbs; haptics present.
- [ ] A session has a satisfying stopping point (goal reached, next goal shown).

## Anti-patterns

- Feedback that waits for the server round trip. Predict locally (the counter rolls, the pickup pops),
  reconcile when the server answers; roll back visibly only on refusal.
- Everything at full celebration. Pick one hero moment per session.
- Shake and flash with no option to reduce them.
- Feel work in M0. M0 is grey and silent on purpose; feel is M1's whole job.
