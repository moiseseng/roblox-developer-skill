# <Nombre del juego> · Documento de diseño
Versión 0.1 · borrador · YYYY-MM-DD · Motor: Roblox
Leyenda: [OK] decidido · [PROP] propuesto, revisable · [OPEN] pendiente del dueño (un solo badge por frase, nunca dos juntos)

## 1. Visión
<Dos párrafos: qué es, para quién, por qué existe. La frase de una línea que diría un jugador a un amigo.>

**El momento:** <la jugada que da gusto> [OK]

## 2. Pilares de diseño
Tres a cinco. Cada uno con una frase de "esto significa que..." y una de "...y por eso NO hacemos".
1. **<Pilar>** [OK] · Significa: ... · Por eso no: ...
2. ...

## 3. Bucle principal
**Micro (segundos):** <acción → feedback → recompensa>
**Sesión (minutos):** <tabla de la primera sesión completa; 30 min por defecto, o la duración objetivo del GDD>

| Minuto | Qué hace | Qué gana | Qué puede comprar | Qué desbloquea |
|---|---|---|---|---|
| 0–1 | | | | |
| 1–3 | | | | |
| 3–10 | | | | |
| 10–30 | | | | |

**Meta (días):** <por qué vuelve mañana y la semana que viene>
**Fin de sesión:** <cómo termina una sesión buena>

## 4. Mecánicas
Una subsección por mecánica de v1. Para cada una: regla, input (PC/móvil/mando), feedback, casos límite, "hecho significa".

### 4.1 <Mecánica> [PROP]
- Regla: ...
- Input: PC ... · Móvil ... · Mando ...
- Feedback: visual / sonido / UI
- Límites: ...
- Hecho significa: <una frase comprobable por QA>

## 5. Progresión y economía
**Monedas:** <nombre, de dónde sale, en qué se gasta, se reinicia o no> [OK]
**Fórmulas:**
```
ganancia_por_min(t)   = ...
coste(n)              = base × crecimiento^n      (base = ..., crecimiento = ...)
```
| n | 1 | 5 | 10 | 20 |
|---|---|---|---|---|
| coste | | | | |
| minutos para pagarlo | | | | |

(Adapta los n al ritmo del juego: en un juego de 3 macetas y 15 min, n = 1, 2, 3, 5. Lo que importa es que ganancia y coste conecten; usa `scripts/economy_sim.py` y pega su tabla aquí.)

**Ritmo objetivo:** primera compra < 1 min · primera mejora grande ≈ 10 min · prestigio ≈ día 2 [PROP]
**Qué se compra con Robux y qué nunca:** ... (postura: <cosméticos | progreso suave | ...>) [OPEN]

## 6. Contenido
Mapa/zonas, enemigos/objetos/ítems, niveles. Tabla con nombre, función en el loop, v1 o después.

| Contenido | Rol en el loop | v1 | Notas |
|---|---|---|---|

## 7. Jugador, cámara y controles
Avatar, movimiento, cámara, controles por plataforma, accesibilidad (texto escalable, daltonismo, sin flashes).

## 8. UI, HUD y primeros 60 segundos
Lista de pantallas (HUD, tienda, inventario, ajustes, tutorial) con qué muestra cada una y en qué momento aparece. Móvil primero: zonas seguras, botones ≥ 44 px.

**Idioma de origen de los textos:** <es | en | ...> [OK] · Traducción automática: sí/no
**FTUE (primeros 60 s), un paso por fila; cada paso es un evento del funnel de analítica (§12):**
| Paso | Qué ve / hace el jugador | Qué aprende | Segundo objetivo |
|---|---|---|---|
| 1 | | | ≤ 5 |
| 2 | | | ≤ 20 |
| 3 | | | ≤ 60 |

**Accesibilidad base:** tamaño de texto ajustable, reducir movimiento, mantener/alternar, paleta segura para daltonismo, nada que parpadee > 3 Hz.

## 9. Arte y audio
Estilo, paleta (3–5 colores), referencias, escala (1 stud = ...), presupuesto de polígonos por tipo de asset, música y SFX clave. Detalle en art-bible.md.

## 10. Multijugador y social
Jugadores por server [OK], qué se comparte, qué se ve de otros, chat, grupos/amigos, qué pasa al unirse a mitad.

## 11. Monetización
Game passes, developer products, suscripciones; precios propuestos en Robux [PROP]; qué NO se vende; cumplimiento de PolicyService y normas de Roblox.

## 12. Live-ops y métricas
Eventos de analítica a registrar (funnel de onboarding por paso de §8, economía, progresión). Flags de configuración (ConfigService). Objetivos: D1 ≥ ..% · sesión media ≥ .. min · [PROP].

**Calendario de las tres primeras actualizaciones:**
| Semana | Contenido | Flag | Qué nos enseña |
|---|---|---|---|
| +1 | | | |
| +2 | | | |
| +4 | | | |

## 13. Psicología del jugador y bucles de recompensa
Por qué el bucle retiene y por qué es honesto. Un mecanismo por frase, cada una con su badge. Referencia: `references/design/player-psychology.md`.

**Anticipación:** <qué espera el jugador justo antes de la recompensa y qué parte es incierta (común / raro); qué recompensa es siempre igual y por eso rápida> [PROP]
**Lo que mejora con la práctica:** <la habilidad, separada de los números que suben> [PROP]
**Una decisión real por sesión:** <cuál, y por qué no tiene respuesta única> [PROP]
**Quién ve al jugador:** <qué de su progreso ven otros; qué hacen juntos> [PROP]
**Siguiente meta siempre visible:** <cómo se muestra la distancia; con cuánto progreso inicial arranca la primera barra> [PROP]
**Por qué vuelve, sin miedo:** <citas (qué crece, cuándo), novedad, amigos; qué encuentra al entrar que le paga al momento> [PROP]
**Qué nunca se pierde por no jugar:** todo lo ganado; topes en vez de decaimiento; rachas con día de gracia [PROP]
**Fin de sesión bueno:** <cada ~N min, en una meta cumplida con la siguiente a la vista> [PROP]
**Feel:** <los tres canales en la acción principal; respuesta al input ≤ 100 ms (verify); revelación más larga cuanto más raro> [PROP]
**Dificultad:** <qué pide más a lo largo de la sesión; cómo se lee el fallo; tasa de fallo objetivo por paso> [PROP]
**Patrones oscuros:** ninguno de la lista prohibida; los que exigen aviso (azar de pago, eventos, rachas, temporizadores) y cómo se avisa: <...> [PROP]
**Para 8–13:** <paradas naturales, sin vergüenza ni comparación por gasto, nada que pierda quien tiene que irse a cenar> [PROP]

## 14. Restricciones técnicas
Streaming, límite de instancias, presupuesto de rendimiento móvil, autoridad del servidor, persistencia de datos. Detalle en tech-design.md.

## 15. Alcance
**v1 (M2 alpha debe tener):** lista corta.
**Después:** lista ordenada por valor.
**Nunca en esta versión:** ...

## 16. Riesgos
| Riesgo | Impacto | Mitigación | Dueño |
|---|---|---|---|

## 17. Preguntas abiertas [OPEN]
- ...

## Historial de cambios
| Versión | Fecha | Cambio | Motivo |
|---|---|---|---|
| 0.1 | | borrador inicial | |
