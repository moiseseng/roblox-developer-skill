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

## 8. UI y HUD
Lista de pantallas (HUD, tienda, inventario, ajustes, tutorial) con qué muestra cada una y en qué momento aparece. Móvil primero: zonas seguras, botones ≥ 44 px.

## 9. Arte y audio
Estilo, paleta (3–5 colores), referencias, escala (1 stud = ...), presupuesto de polígonos por tipo de asset, música y SFX clave. Detalle en art-bible.md.

## 10. Multijugador y social
Jugadores por server [OK], qué se comparte, qué se ve de otros, chat, grupos/amigos, qué pasa al unirse a mitad.

## 11. Monetización
Game passes, developer products, suscripciones; precios propuestos en Robux [PROP]; qué NO se vende; cumplimiento de PolicyService y normas de Roblox.

## 12. Live-ops y métricas
Eventos de analítica a registrar (funnel de onboarding, economía, progresión). Flags de configuración (ConfigService). Objetivos: D1 ≥ ..% · sesión media ≥ .. min · [PROP].

## 13. Restricciones técnicas
Streaming, límite de instancias, presupuesto de rendimiento móvil, autoridad del servidor, persistencia de datos. Detalle en tech-design.md.

## 14. Alcance
**v1 (M2 alpha debe tener):** lista corta.
**Después:** lista ordenada por valor.
**Nunca en esta versión:** ...

## 15. Riesgos
| Riesgo | Impacto | Mitigación | Dueño |
|---|---|---|---|

## 16. Preguntas abiertas [OPEN]
- ...

## Historial de cambios
| Versión | Fecha | Cambio | Motivo |
|---|---|---|---|
| 0.1 | | borrador inicial | |
