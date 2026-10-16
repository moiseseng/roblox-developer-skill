# <Juego> · Diseño técnico
Versión 1.0 · YYYY-MM-DD · GDD v1.0 · Motor: Roblox (Rojo + Luau)

## 1. Resumen
<Tres frases: arquitectura, autoridad, datos.>

## 2. Layout del repo
| Carpeta | Lugar en Roblox | Contenido |
|---|---|---|
| src/shared | ReplicatedStorage.Shared | Config, Economy (puro), Remotes, Signal, utilidades |
| src/server/Services | ServerScriptService.Server.Services | ... |
| src/client/Controllers | StarterPlayerScripts.Client.Controllers | ... |
| src/character | StarterCharacterScripts | ... |
| tests | ServerStorage.Tests | specs del runner |

## 3. Mapa de sistemas
| Sistema (GDD §) | Servicio(s) | Controlador(es) | Shared | Remotes | Datos persistidos | Pruebas |
|---|---|---|---|---|---|---|

## 4. Contrato de remotes
| Nombre | Tipo | Dirección | Payload | Validación | Límite |
|---|---|---|---|---|---|

## 5. Esquema de datos
```lua
-- Profile v1
{
	version = 1,
	coins = 0,
	...
}
```
Migraciones: v1 → v2: ...

## 6. Replicación de estado
Atributos públicos: ... · Remotos: ... · Derivado en cliente: ...

## 7. Mundo
Construido por código en `src/server/World` desde `src/shared/Layouts` · Streaming: on/off (motivo) · Coordenadas y escala.

## 8. Presupuesto de rendimiento
| Métrica | Objetivo móvil gama baja | Cómo se mide |
|---|---|---|
| Frame time | ≤ 16 ms | MicroProfiler / Stats |
| Instancias en Workspace | ≤ ... | script de conteo |
| Partes visibles | ≤ ... | |
| Texturas | ≤ 1024², ... MB | |
| Memoria cliente | ≤ ... MB | DeveloperConsole |

## 9. Seguridad
Autoridad del servidor para: ... · Validaciones por remoto (§4) · Anti-exploit: velocidad/teletransporte/ratio de acciones · Qué se ignora (cosmético).

## 10. Economía en código
`src/shared/Economy.luau` exporta: ... · `tests/Economy.spec.luau` comprueba la tabla del GDD §5.

## 11. Estrategia de pruebas
Unitarias (runner): ... · En Studio vía MCP: ... · QA manual: ...

## 12. Decisiones
Ver `docs/gamedev/decisions.md`. Resumen de las tres más importantes: ...
