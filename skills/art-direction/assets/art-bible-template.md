# <Juego> · Biblia de arte
Versión 1.0 · YYYY-MM-DD · GDD v1.0

## 1. Dirección
Tres adjetivos: ... · Referencias: ... · Lo que NO es: ...

## 2. Paleta
| Rol | Hex | Uso |
|---|---|---|
| Base | #...... | suelo, muros |
| Secundario | #...... | props |
| Acento | #...... | pickups, botones primarios |
| Peligro | #...... | enemigos, daño |
| UI fondo / texto | #...... / #...... | contraste ≥ 4.5:1 |

Comprobación daltonismo: ningún estado se distingue solo por color (icono o forma además); simular deuteranopia sobre la paleta antes de aprobarla.

## 3. Estilo y materiales
Low-poly / estilizado / realista · Aristas: duras / biseladas · Texturas: colores planos / atlas / PBR 512 · SurfaceAppearance: sí/no

## 4. Escala
1 stud = ... · Personaje: R15 estándar (≈ 5 studs) / propio · **Escala de avatar:** fija en Game Settings → Avatar (mín = máx) o `HumanoidDescription` forzada, para que puertas, cámaras y hitboxes no dependan del cuerpo que traiga el jugador (los avatares varían ~3–7 studs, verify) · Puerta: ... studs · Altura de salto: ... studs

## 5. Iluminación (valores reales para default.project.json)
Technology: ... · ClockTime: ... · Brightness: ... · Atmosphere: Density ... · Bloom/ColorCorrection: ...

## 6. UI
Fuente: ... · Radio: ... px · Botón mínimo: 44 px · Colores por rol · Estilo de iconos

## 7. Presupuestos por clase
| Clase | Tris | Textura | Instancias | Notas |
|---|---|---|---|---|
| Prop pequeño | ≤ 300 | 256 | 1 MeshPart | |
| Prop grande | ≤ 1 500 | 512 | ≤ 3 | |
| Personaje/enemigo | ≤ 3 000 | 512 | | |
| Edificio/zona | ≤ 10 000 | 1024 | | |

## 8. Pivotes y nombres
Props: centro-abajo · Personajes: pies · Nombre: `Categoria_Nombre_Variante` · Tamaño registrado en asset-list.md

## 9. Audio
Música: ... · SFX clave: ... · Volumen por grupo (SoundGroup): ...

## 10. Silhouette / legibilidad
Pickups legibles a 40 studs · Enemigos: color de peligro + forma única · Interactuables: brillo/outline
