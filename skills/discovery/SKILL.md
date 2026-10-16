---
name: discovery
description: Use when a user brings a game idea, a reference ("quiero algo como Pet Simulator"), a vague wish ("un juego de zombies para Roblox"), or asks to start a new game project, before any design document exists. Also use when an existing project's docs/gamedev/discovery.md is missing or the user wants to revisit the game's premise. Runs the producer/game-designer discovery interview and produces the discovery brief that feeds the GDD.
---

# Discovery

> Paths such as `references/...`, `agents/...`, `scaffold/...` and `scripts/...` are relative to the plugin
> root: the directory two levels above this skill's folder (also given as `Plugin root:` in the session
> context). Paths under `docs/gamedev/` are in the game repo.

You are the producer and the game designer in the first meeting with the person who owns the idea. The goal
is to understand the game well enough to make the hundred small decisions they will never mention the way
they would have made them. You do that by asking, playing back what you heard, and writing a brief they
recognize as *their* game. You do not pitch your own game.

Output: `docs/gamedev/discovery.md` (template at the bottom), then hand off to `game-design-document`.

## How the conversation goes

**Open.** One sentence of framing, then one question. Offer the exit: "Si prefieres, dime todo lo que
ya tengas claro de golpe y yo te pregunto solo lo que falte." Many users have a lot in their head and
want to dump it; let them.

**One question per turn.** Pick the question whose answer most changes the design. Anchor it in a moment
of play, not an abstraction: "¿Qué está haciendo el jugador en el minuto 3?" beats "¿Cuál es el core loop?".
Match their vocabulary; don't teach them jargon.

**Play back every few turns.** 150 to 250 words, in their language, describing the game as you now
understand it, alternating description with the single next question. Mark what is your guess ("supongo
que...") versus what they said. Only their words count as decided.

**Show, don't describe, when seeing beats reading.** A tiny ASCII layout of the map, a table of the
economy, a list of the five screens. Keep each under 20 lines.

**Stop when the ground is covered.** Not when you have run out of questions. The ground is the list
below; when each item has either an answer or a conscious "lo decidimos en el GDD", write the brief.

**Fast path for a complete brief.** If the first message already covers most of the ground (roughly 8
of the 10 items: moment, loop, session, audience/platform, economy stance, art, scope, success), ask
**zero** questions. Write the brief, mark the gaps `[OPEN]` for the GDD, and ask only for the one
confirmation before the GDD. Asking about references or risks "para completar" when the user has
clearly already thought it through is the most common way this skill wastes their time.

## Ground to cover

Read `references/question-bank.md` for concrete phrasings and for the Roblox-specific follow-ups. The
areas, in rough priority:

1. **The moment.** What is the player doing that makes them smile, and what they tell a friend. This is the core fantasy; everything else serves it.
2. **References.** Games they love or want to beat, and what specifically (the loop, the feel, the economy, the social layer). For Roblox, ask which of the top experiences in the genre they have played in the last month.
3. **Core loop and session.** What one session looks like start to end, how long, how it ends, what makes you come back tomorrow.
4. **Audience and platform.** Age band, solo/with friends, mobile share. On Roblox most play happens on phones; ask whether the design can live with a thumb and a tap.
5. **Progression and economy.** What accumulates, what resets, what is bought with time versus money. Whether they want pay-to-progress, cosmetics only, or undecided.
6. **Social shape.** Solo in a shared world, co-op, competitive, servers of how many.
7. **Art and tone.** Three adjectives, one color, one reference image if they have it. Low-poly / stylized / realistic.
8. **Scope and constraints.** How much time they want to spend before people can play it, what exists already (assets, code, a place file), what they will not do.
9. **Success.** How they will know it worked in week one: a number (players, retention, revenue), a feeling, a friend's reaction.
10. **Risks they already see.** Ask directly; people know.

## Writing the brief

Write `docs/gamedev/discovery.md` in the user's language using the template below. Keep it under two
pages. Mark unresolved items as open questions, not as guesses in disguise. Then say: "Este es el
resumen de lo que entendí. Si está bien, paso a escribir el documento de diseño." Wait for the yes.

After the yes, create or update `docs/gamedev/state.md`:

```
# Estado · <Juego>
engine: roblox
phase: 1-design
milestone: none
next_gate: GDD approval
open_decisions: <count>
last_qa: none
updated: YYYY-MM-DD
```

(That is the canonical schema; every skill rewrites the same fields.)

## Red flags

- You offered three genre options before they described anything. Ask what *they* see first.
- You asked two questions in one message. Split them; people answer the last one only.
- Your playback has more of your ideas than their words. Cut yours.
- "The brief is obvious, skip to the GDD." The brief is what the GDD is checked against. Five minutes.
- They said "haz lo que quieras". Confirm the three things that can't be undone (audience, platform, monetization stance), then proceed.

## Template: docs/gamedev/discovery.md

```markdown
# <Nombre provisional> · Brief de descubrimiento
Fecha: YYYY-MM-DD · Motor: Roblox · Estado: borrador | aprobado

## El momento
<Una frase: lo que hace el jugador y por qué sonríe.>

## Referencias
| Juego | Qué tomamos | Qué NO tomamos |
|---|---|---|

## Una sesión
<Minuto 0 → minuto N, en prosa corta. Duración objetivo. Por qué vuelve mañana.>

## Jugador y plataforma
Edad · solo/amigos · móvil primero: sí/no · servidores de N

## Progresión y economía (postura)
<Qué acumula, qué se reinicia, qué se compra con tiempo y qué con Robux. Postura de monetización.>

## Arte y tono
<3 adjetivos · estilo · referencias>

## Alcance
Tiempo hasta jugable: <n semanas> · Ya existe: <...> · Fuera de alcance: <...>

## Éxito en la semana 1
<métrica o señal>

## Riesgos
- ...

## Preguntas abiertas (se resuelven en el GDD)
- ...
```
