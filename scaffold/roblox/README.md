# __GAME_NAME__

<Una frase: qué es el juego.> Documento de diseño: [`design.html`](design.html) · Fuente: `docs/gamedev/gdd.md`.

## Desarrollo

Requiere [Rojo](https://rojo.space) 7.7+ y el plugin de Rojo en Studio.

```bash
rojo serve
```

En Studio: abre el place → plugin Rojo → **Connect**. `default.project.json` también fija Lighting,
StarterPlayer y Workspace. El mapa se construye por código al arrancar el servidor (`src/server/World`),
así que todo es reproducible desde git; el `.rbxl` no se versiona.

### Tests

```lua
require(game.ServerStorage.Tests.Runner).Run()
```

### Lint y formato

```bash
stylua src tests && selene src tests
```

## Arquitectura

| Carpeta | Roblox | Contenido |
|---|---|---|
| `src/shared` | `ReplicatedStorage.Shared` | Config, Economy (puro), ProfileSchema, Remotes, Net, Signal, Loader |
| `src/server/Services` | `ServerScriptService.Server.Services` | Net, Data (session lock), Player, Economy, World |
| `src/server/World` | — | Constructores del mapa |
| `src/client/Controllers` | `StarterPlayerScripts.Client.Controllers` | HUD |
| `src/character` | `StarterCharacterScripts` | Movimiento |
| `src/first` | `ReplicatedFirst` | Pantalla de carga |
| `tests` | `ServerStorage.Tests` | Runner + specs |

Reglas: autoridad del servidor; cada remoto valida tipo, rango, propiedad y ritmo; DataStore solo desde
DataService; tunables en `Config.luau`; estado público como atributos.

## Documentos

`docs/gamedev/`: `discovery.md`, `gdd.md`, `tech-design.md`, `art-bible.md`, `asset-list.md`,
`decisions.md`, `state.md`, `plans/`, `qa/`.

## Publicar

Ver `docs/gamedev/release-checklist.md`. Game Settings → Security → **Studio Access to API Services** para
probar guardado en Studio.
