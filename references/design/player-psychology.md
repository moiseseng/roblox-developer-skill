# Player psychology · reward, attention, motivation

What this file is: the behavioural science behind the patterns in `references/roblox/market-and-design.md`
and `references/roblox/ui-ux.md`, written so the designer can reason about *why* a loop holds attention
and the reviewer (`agents/player-psychologist.md`) can audit one. What it isn't: a licence to build
compulsion. Every mechanism below has an ethical line; the audience is mostly children, and a loop that
works on them but that you would not explain to their parents is a defect, not a feature. Engine-agnostic;
Roblox specifics (tween values, PolicyService details, onboarding steps) are pointed to in `references/roblox/`, not restated. Numbers
marked **(verify)** come from the literature or are design heuristics; check before quoting them.

## Three ideas that explain most of the rest

**Dopamine signals prediction error, not pleasure.** Midbrain dopamine neurons fire when a reward is
better than expected, stay flat when it is exactly as expected, and dip when an expected reward does not
arrive (Schultz). Once a reward is fully predictable the signal moves to the cue that predicts it and the
reward itself goes quiet. For design: attention follows *uncertainty about a good outcome* and
*anticipation*, not the size of the payout. A guaranteed +10 per click stops registering within minutes;
"maybe a rare one" keeps the cue alive. Wanting and liking are separate systems (Berridge & Robinson): a
loop can make players want to continue without enjoying it. That gap is where the ethics live.

**Motivation that lasts is intrinsic.** Self-Determination Theory (Deci & Ryan; Ryan, Rigby & Przybylski
for games) finds that enjoyment and the intention to keep playing track three needs: **competence** (I am
getting better and the game shows me), **autonomy** (I chose this, and the choice mattered),
**relatedness** (someone sees me; we did this together). Extrinsic rewards layered on an activity the
player already enjoys can undermine the enjoyment (Deci; Deci, Koestner & Ryan). Pay the player for the
chore, never for the fun part. Rewards that *inform* ("you did that well") feed competence; rewards that
*control* ("do this or lose that") erode autonomy.

**Flow needs a matched challenge, clear goals and immediate feedback** (Csikszentmihalyi). Challenge
above skill produces anxiety and quitting; below it, boredom and quitting. The channel between them is
narrow and moves as the player learns, so difficulty must move with them. Juul adds that failure is part
of the pleasure *when the player can attribute it to themselves and improve*; failure that feels like the
game's fault is just loss.

## Mechanisms

Each: what it is → what it does to attention and retention → how to use it in the loop → how it goes
wrong → the ethical line.

### Reward prediction error and anticipation (Schultz)
- **What:** rewards that are partly uncertain, and cues that reliably precede them.
- **Effect:** attention attaches to the cue (the chest, the growing plant, the egg) and to the moment before the outcome; fully predictable rewards fade within minutes.
- **Use:** make the *anticipation* legible: a cue, a short build-up, the outcome. Vary outcomes within an honest, mostly-good range (common / uncommon / rare). Let a fully expected reward be fast rather than ceremonial.
- **Wrong:** every action gets a fanfare (habituation: the brain stops reading them); the ceremony is padded to sell a skip.
- **Line:** uncertainty is for *earned* outcomes. Uncertainty bought with Robux is a paid random item: odds disclosed and policy respected (`references/roblox/monetization.md`), or not in the game.

### Reinforcement schedules (Ferster & Skinner; Hopson)
- **What:** fixed ratio (every N actions), variable ratio (on average every N, unpredictably), fixed interval (every T minutes), variable interval.
- **Effect:** variable ratio produces the highest, steadiest activity and the most persistence when rewards stop; fixed ratio produces a pause after each reward; fixed interval produces a lull, then a ramp as the time approaches.
- **Use:** the core action on variable ratio (drops, crits, rare spawns) *inside* a loop that is already fun; structural rewards (upgrades, zones) on fixed ratio so progress is plannable; appointment content on an honest fixed interval.
- **Wrong:** the post-reward pause after a level-up with nothing new to want (players leave there); a variable schedule used to mask an empty loop. Hopson's warning: schedules shape behaviour independently of fun, so they can hold a player at a game they no longer enjoy.
- **Line:** a variable schedule on earned play is a game; the same schedule with a price per pull is a slot machine. For an under-13 audience, prefer no paid pulls at all.

### Flow and the difficulty curve (Csikszentmihalyi; Chen; Juul)
- **What:** challenge tracking skill, with clear goals and instant feedback.
- **Effect:** time distortion and "one more try"; sessions feel short. Leaving flow in either direction is the most common quit point.
- **Use:** a sawtooth, not a line: introduce each mechanic at low challenge, ramp, release, introduce the next. Offer ways to self-select difficulty inside play (a harder path, an optional boss) so the curve adapts without a menu. See "Tuning difficulty and flow".
- **Wrong:** a flat loop that never asks more (boredom by minute 10); a spike at the first new mechanic; failure that cannot be read ("why did I die?").
- **Line:** silent adaptation is fine for solo progression; it never touches competitive outcomes and is never sold.

### Competence, autonomy, relatedness (Deci & Ryan)
- **What:** the three needs above.
- **Effect:** the strongest predictors of returning *by choice* rather than by habit or fear. Players say "I'm good at this", "it's my base", "my friend saw it".
- **Use:** competence: visible skill growth (faster runs, cleaner combos) separate from stat growth. Autonomy: at least one real choice per session (which upgrade, which zone, what to build) with no dominant answer. Relatedness: something another player can see or do with you (a visible base, a co-op boss, a gift).
- **Wrong:** all progress is numbers going up (competence faked by inflation); "choices" with one right answer; a social layer that is only leaderboards (comparison without connection).
- **Line:** controlling rewards ("log in or lose your streak") trade autonomy for compliance. Use informational ones.

### Goal gradient (Hull; Kivetz, Urminsky & Zheng)
- **What:** effort accelerates as the goal gets closer.
- **Effect:** the last stretch of a bar is the stickiest part of a session; a player near a goal rarely quits.
- **Use:** always show the next goal and the distance to it; nest goals so one is always close (a micro bar near completion while a macro bar is far). A good session ends *just after* a goal, with the next one visible.
- **Wrong:** goals so far the gradient never kicks in; several bars all far away; a goal reached with no next goal shown (the fixed-ratio pause again).
- **Line:** honest distances. A bar that slows near the end to stretch time is a dark pattern.

### Endowed progress (Nunes & Drèze)
- **What:** people given a head start on a goal complete it more often than people starting at zero, even when the remaining effort is identical.
- **Effect:** the first bar should never start empty; "2 of 10" beats "0 of 8" **(verify the paper's figures before quoting)**.
- **Use:** the first quest pre-filled by the tutorial actions; a welcome gift that is item one of a collection; a new zone with one thing already unlocked.
- **Wrong:** endowed progress on a *paid* track so the player feels already invested ("you're 60% to the premium pet").
- **Line:** endow earned paths, never purchase funnels.

### Loss aversion and streaks (Kahneman & Tversky)
- **What:** losses weigh more than equivalent gains (roughly twice **(verify)**).
- **Effect:** the strongest short-term retention lever and the most corrosive. Streaks, decaying resources and "protect your base" drive returns through fear of loss: an avoidance schedule, in Hopson's terms.
- **Use:** sparingly and softly: a streak with a grace day or a freeze; offline earnings that *cap* rather than *decay*; resources that pause rather than rot. Frame returns as gains ("your plants grew") rather than averted losses.
- **Wrong:** progress destroyed by absence; a streak that resets to zero after one missed day for a nine-year-old on a school trip.
- **Line:** nothing the player has earned is taken away for not playing. For this audience it is also a compliance question (see "For kids 8–13").

### Appointment mechanics and honest timers
- **What:** content that becomes available at a known time (crops, a daily chest, an event).
- **Effect:** a fixed-interval schedule: the player plans a return and the game enters their day. Honest appointments are the most reliable day-1 lever on the platform (`market-and-design.md`, "Day 1").
- **Use:** visible timers that mean what they say; several staggered appointments (a short one, a daily one, a weekly one) so one fits the player's schedule; a return that pays off *immediately* on join.
- **Wrong:** every timer sells a skip (the timer exists for the skip, not for the rhythm); a timer long enough to annoy but short enough that the player idles waiting (an idle wait is a lost session, not engagement).
- **Line:** real durations, no fake countdowns, no "last chance" for something that quietly returns next week. If it returns, say so.

### Near misses (Reid; Clark et al.)
- **What:** outcomes that *almost* win.
- **Effect:** in skill challenges a near miss is information ("I can do this") and raises the urge to retry; in random outcomes it recruits the same reward circuitry as a win without delivering one, which is why slot machines manufacture them.
- **Use:** in skill play only: show how close the player was (the gap, the ghost, the one tile left) and give an instant retry.
- **Wrong:** random reveals weighted to display rare items next to the result; "you were one away" messaging on paid draws.
- **Line:** near misses on random outcomes are engineered gambling cues and are forbidden here regardless of disclosure. Near misses in skill play are good design.

### Social proof and visible progress (Cialdini; Eyal)
- **What:** people do what they see others doing; progress others can see is worth more to its owner.
- **Effect:** "others are here, doing this" lowers the barrier to act; a base, pet or skin others see turns progress into status, a strong return reason for young players. Eyal's "investment" step: what the player puts in (a base, a name, a collection) is stored value that makes returning the default.
- **Use:** other players visibly doing the core action near spawn; the main progression wearable or placeable; others' wins celebrated briefly in the shared space ("X hatched a rare") so they signal possibility, not inferiority.
- **Wrong:** feeds of others' purchases; leaderboards ranked by spend; comparison with no path to catch up (weekly resets fix part of it; `market-and-design.md`, "Social").
- **Line:** social proof shows what *play* achieves, never what *paying* achieves.

### Novelty cadence and curiosity (Bunzeck & Düzel; Loewenstein)
- **What:** novel stimuli engage the same midbrain circuit as reward; curiosity is an information gap the player wants closed.
- **Effect:** novelty is the antidote to habituation and the engine of week-2 retention; its absence is why simulators die after week one.
- **Use:** something new *to see* every few minutes in session one and in every update afterwards (a zone, an enemy, an interaction); visible locked content that poses a question ("what is behind the gate?"). The cadence is written in the GDD live-ops section.
- **Wrong:** novelty as reskin (new colour, same loop); mystery that resolves only with payment.
- **Line:** curiosity gaps are closed by play.

### Juice and feedback timing (Swink; Jonasson & Purho)
- **What:** fast, layered, proportional feedback on every action: motion, sound, UI, a little screen response.
- **Effect:** feel is what the player cannot name and quits over. Feedback inside the perceived-instant window makes the game an extension of the hand; late or missing feedback reads as broken even when the logic is correct.
- **Use:** three channels on the core action first (`ui-ux.md`, "Feedback"); celebration scaled to rarity so the hierarchy reads at a glance; budgets in the table below.
- **Wrong:** feedback on everything at the same volume (nothing stands out); feedback that waits for the server round trip; reward ceremonies that cannot be skipped.
- **Line:** juice amplifies real outcomes. It never dresses an empty one.

### The onboarding attention window
- **What:** a new player grants the game a few seconds of trust before deciding, and most players who ever try it try it exactly once.
- **Effect:** the first minute decides day-1 more than any later system (`ui-ux.md`, "Onboarding"). Attention is spent on *reading* and kept by *doing*.
- **Use:** core action within seconds, first reward well under a minute, first real choice within three minutes **(verify)**; teach with one verb and a beam, not a panel; endow the first goal.
- **Wrong:** a lore screen; a tutorial that explains the shop before the player has wanted anything; a hub with twelve doors.
- **Line:** no purchase prompt until the player has felt the loop (`monetization.md`, "Design guidance").

## Reward-loop audit

Run it over the GDD session table (`## 3. Bucle principal`, rows 0–1, 1–3, 3–10, 10–30) and, from M1,
over the build. Each cell is a yes/no with the section, screenshot or metric that proves it; a "no" is
a finding.

| Moment | Ask | Mechanisms |
|---|---|---|
| **First 60 s** | Is the player doing the core action, not reading? Does the first reward arrive with all three feedback channels? Does the first goal start partly filled? Is something novel in view that poses a question? | attention window, juice, endowed progress, curiosity |
| **Minute 3** | Has the player made one real choice? Has the reward become partly uncertain (a better drop, a variant)? Is the next goal visible and near? Has the challenge asked slightly more than at minute 1? | autonomy, prediction error, goal gradient, flow |
| **Minute 10** | Did the first big upgrade change what the player *does*, not only the numbers? Is there one new thing to see? Has another player been visible doing something worth copying? Would a slightly worse, or slightly better, player still be in flow? | competence, novelty, social proof, flow |
| **Session end** | Does a good session end on a reached goal with the next one shown, or on boredom? Is an appointment set (what grows, what unlocks, when)? Is nothing lost by leaving now? | goal gradient, appointment, loss aversion |
| **Day-1 return** | What pays off *immediately* on join? Is the return framed as a gain? Can a returning player skip the teaching? Is at least one return reason intrinsic (my base, my friend), not only a timer? | appointment, SDT, loss aversion |
| **Day 7** | Has something new arrived and was it announced honestly? Is skill growth visible separately from stat growth? Does the social layer connect rather than only rank? Is the curve still asking more, and still readable? | novelty cadence, competence, relatedness, flow |
| **Every moment** | Is anything on the dark-patterns list present without its disclosure? Could the team explain this mechanism to a parent in one sentence without embarrassment? | ethics |

## Tuning difficulty and flow

1. **Name the skill.** For each mechanic, write what the player gets better at (timing, routing, reading
   a pattern) separately from what they buy. If nothing improves with practice there is no competence
   channel, flow will not form, and progression there is pure schedule.
2. **Instrument failure, not only success.** Log start, complete and fail per challenge with time spent
   and retries (`analytics-liveops.md`, progression events). Three numbers matter: failure rate per
   attempt, time from a failure to the next attempt, and quits that follow a failure.
3. **Read the shape.** A fail-rate spike at one step with quick retries is a learning step (fine); the
   same spike with long pauses or quits is a wall. Zero failures across a session means the curve is
   flat; players will say "easy" and mean "boring".
4. **Pick a target band, then test it with people.** Write the intended fail rate per step in the GDD
   as `[PROP]` and tune to the observed one; there is no universal number. Juul's conditions for the
   band: failure attributable to the player, legible, recoverable in seconds.
5. **Shape the sawtooth.** New mechanic → low challenge → ramp → release moment (a reward, a calm room)
   → next mechanic. Release moments are where sessions end well; put appointments there.
6. **Adapt quietly where it helps.** Rubber-banding, an extra checkpoint after repeated failure, a hint
   after N fails: for solo progression, silent and never sold. For anything competitive, none.
7. **Retry latency is part of the curve.** Death-to-control in about a second **(verify)** keeps the near-miss
   information fresh; a long death animation turns it into a loss.

## Feedback-timing budgets

All figures **(verify)**. "lit." marks values from the perception and HCI literature (Card, Moran &
Newell; Nielsen; Swink); "heur." marks design heuristics to tune by playtest. Roblox tween values and
the three channels are in `ui-ux.md`.

| Event | Budget | Class | Why |
|---|---|---|---|
| Input → first visible response | ≤ 100 ms | lit. | perceived as instantaneous; beyond it the game feels laggy or deaf. Predict on the client, confirm on the server |
| Visual ↔ sound for the same event | within a frame or two (≤ ~50 ms) | lit./heur. | audio-visual desync reads as "broken" before it reads as "late" |
| Number pop / currency tick | start ≤ 100 ms, animate 300–600 ms | heur. | start inside the instant window; let the roll-up be readable |
| UI tween, hover, press | 100–300 ms | heur. (`ui-ux.md`) | faster is invisible, slower is sluggish |
| Screen transition | ≤ 300 ms | heur. | longer breaks the thread of thought between screens |
| Reward reveal (chest, hatch) | 0.5–1.5 s anticipation, then reveal; longer only for rarer | heur. | anticipation is where the prediction-error signal lives; pad it and it becomes a skip sale |
| Toast / notification | 2–4 s visible, never blocking | heur. | long enough to read, short enough to ignore |
| Loading, "something is happening" | ≤ 1 s; progress indicator beyond that | lit. (Nielsen) | about 1 s keeps the thread of thought; around 10 s attention leaves |
| Fail → retry available | ≤ 1 s; death-to-control ≤ 2 s | heur. | keeps near-miss information actionable |
| Idle nudge (no input) | not before 10–15 s, once | heur. | earlier is nagging; repeated is noise |

Rule of thumb: everything the player *caused* answers inside 100 ms; everything the player is *given*
may take a beat, scaled to how rare it is.

## Dark patterns: forbidden, or allowed only with disclosure

Categories after Zagal, Björk & Lewis ("Dark Patterns in the Design of Games") and Eyal's regret test:
would the player, knowing exactly how it works, feel tricked? Roblox's rules on paid random items,
misleading content and age recommendations apply on top (`monetization.md`, "Policy";
`publishing-checklist.md`). The reviewer treats the first list as a `revisar` verdict.

**Forbidden in this studio's games**
- Engineered near misses or weighted "almost" displays on any random outcome.
- Fake or elastic timers, false scarcity ("only 3 left"), countdowns that restart.
- Progress or items removed because the player did not log in; streaks without a grace mechanism.
- Shame or guilt messaging on leaving, losing or not buying ("your pet is sad", "stay weak?").
- Purchase prompts that interrupt the core action, appear at spawn, or repeat uninvited in a session.
- Social pyramid gates (invite N friends to unlock); leaderboards or feeds ranked by spend.
- Grinding lengthened so that the paid skip is the intended path.
- Pre-selected purchases, confirm-shaming, flows that are hard to leave or cancel.
- Difficulty adaptation that touches competitive outcomes or is sold.
- Mystery or locked content that resolves only with payment.

**Allowed only with disclosure and the policy check**
- Paid random items: odds visible before purchase, `PolicyService` respected, cosmetic-only preferred for this audience; consider a deterministic alternative (a visible pity counter, or direct purchase).
- Limited-time events: real end time shown; say whether and when the item returns.
- Daily rewards and streaks: calendar visible, a missed day costs nothing already earned, freeze or grace shown up front.
- Offline earnings and timers: real durations displayed; any paid skip priced against the cost curve and never the only sane path.
- Bundles and intermediate currency: the Robux price of the thing the player actually wants is computable from what is on screen.

## For kids 8–13

Players in this band are still developing impulse control and the ability to reason about probability
and long-term cost, read on-screen text literally, and are highly sensitive to social comparison
**(developmental consensus; verify specifics before quoting)**. Design as if every mechanism above were
twice as strong and the player could not defend themselves against it.

- **Natural stopping points.** A good session ends on a release moment every 10–15 minutes **(verify; heuristic)**
  with the next goal visible; no cliffhanger timers that punish the child who has to go to dinner.
- **Nothing earned is ever lost.** Caps, not decay; freezes, not resets. Returns are gains.
- **No shame, no comparison by spend.** Celebrate play; rank weekly and by play; never show who bought.
- **Odds are not understood, so disclosure alone is not enough.** Prefer deterministic rewards; keep any
  paid random item cosmetic; design the game to be complete with purchases unavailable
  (`monetization.md`, "Policy"). Roblox's age-recommendation questionnaire and `PolicyService` are the
  compliance hook; the UK ICO Age Appropriate Design Code and the US FTC's dark-patterns report are the
  external standards to read **(verify current text)**.
- **Honest language.** Timers mean what they say; "free" means free; "rare" has a number behind it.
- **Co-op over PvP for retention,** and social features that let a child be *seen* (their base, their
  pet) rather than *measured*.
- **Respect breaks.** Nothing in the design should turn a parent's "time to stop" into a loss event. If
  the team cannot explain a mechanic to a parent in one sentence without embarrassment, it goes.

## Red flags

| Thought | Reality |
|---|---|
| "We'll add juice at the end." | Feel is half the loop; M1 exists to prove it. Without it M0 playtests measure the wrong thing. |
| "The streak is what brings them back." | It brings them back anxious. Check day-7 and who left. |
| "The loot is cosmetic, so it's fine." | Odds, policy, audience. Prefer a deterministic track; disclose if you keep it. |
| "Players love big numbers." | Inflation fakes competence. Ask what the player got better at. |
| "D1 went up, ship it." | Wanting is not liking. Read D1 together with day-7 and session satisfaction. |
| "It's a timer, everyone uses them." | A timer that exists to sell its skip is a toll, not a rhythm. |

## Sources (author and title)
- Schultz, Dayan & Montague, "A Neural Substrate of Prediction and Reward"; Schultz, "Predictive Reward Signal of Dopamine Neurons".
- Berridge & Robinson, "What Is the Role of Dopamine in Reward: Hedonic Impact, Reward Learning, or Incentive Salience?"
- Ferster & Skinner, "Schedules of Reinforcement"; Hopson, "Behavioral Game Design".
- Csikszentmihalyi, "Flow: The Psychology of Optimal Experience"; Chen, "Flow in Games (and Everything Else)"; Juul, "The Art of Failure".
- Deci & Ryan, "Intrinsic Motivation and Self-Determination in Human Behavior"; Ryan, Rigby & Przybylski, "The Motivational Pull of Video Games"; Deci, Koestner & Ryan, "A Meta-Analytic Review of Experiments Examining the Effects of Extrinsic Rewards on Intrinsic Motivation".
- Hull, "The Goal-Gradient Hypothesis and Maze Learning"; Kivetz, Urminsky & Zheng, "The Goal-Gradient Hypothesis Resurrected"; Nunes & Drèze, "The Endowed Progress Effect".
- Kahneman & Tversky, "Prospect Theory: An Analysis of Decision under Risk".
- Reid, "The Psychology of the Near Miss"; Clark et al., "Gambling Near-Misses Enhance Motivation to Gamble and Recruit Win-Related Brain Circuitry".
- Cialdini, "Influence"; Loewenstein, "The Psychology of Curiosity"; Bunzeck & Düzel, "Absolute Coding of Stimulus Novelty in the Human Substantia Nigra/VTA".
- Swink, "Game Feel"; Jonasson & Purho, "Juice It or Lose It"; Card, Moran & Newell, "The Psychology of Human-Computer Interaction"; Nielsen, "Usability Engineering" (response-time limits).
- Eyal, "Hooked" (Hook Model, manipulation matrix) and his later "regret test"; Zagal, Björk & Lewis, "Dark Patterns in the Design of Games".
- Roblox Creator Docs: Community Standards, Paid Random Items policy, Experience Guidelines and age recommendations, PolicyService. UK ICO, "Age Appropriate Design Code"; US FTC, "Bringing Dark Patterns to Light".
