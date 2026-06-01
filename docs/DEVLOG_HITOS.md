# Devlog — DinoPirates from Inner Space
> Hitos mayores de desarrollo, ordenados cronológicamente.
> Basado en el historial de commits desde junio 2022.

---

## Jun 2022 — Primer commit
El proyecto arranca sobre Noble Engine. Player básico con sprites, movimiento 4 direcciones, HUD inicial y una habitación de tilemap fijo.

---

## Oct 2022 – Sep 2023 — SpaceScene: el minijuego espacial
Primer feature grande: una escena de naves con movimiento, crosshair, meteoritos, lásers con timers y dos modos (fighter/travel). El crank controla la nave. Esta escena estuvo en desarrollo intermitente por casi un año.

---

## Nov 2023 — Separación en escenas (MazeScene / SpaceScene)
El juego se parte en escenas propias por primera vez. Noble Engine manejando las transiciones entre ellas.

---

## Dic 2023 — Sistema de luz y batería
La oscuridad se vuelve mecánica de juego: la lamp consume batería, el FXshadow cubre la pantalla, el player se mueve más lento sin luz.

---

## Dic 2023 — Sonar (y su muerte)
Se implementa un sonar como feature de exploración. En febrero 2024 se tiene que **remover por problemas de memoria** (`V 0.1 Sonar Memory Issue`). Una limitación dura del hardware Playdate. Vuelve como "Sonar v2" en junio 2024 en versión más ligera.

---

## Ene 2024 — Sanity system
La cordura del player se vuelve mecánica central: drena con el tiempo, se vincula al nivel de dificultad de la DanceScene (el `powerLevel` sube cada vez que la sanity llega a 0), y tiene su propio HUD animado.

---

## Ene 2024 — Primer enemigo con IA + sistema turn-based
Frogcolli (luego renombrado Bosscolli) con búsqueda lineal. Se introduce el sistema *"el tiempo avanza cuando te movés"* (`isActive`): los enemigos solo se actualizan si el player se mueve o carga batería.

---

## Feb 2024 — Multi-room doors + sistema de diálogos
Las puertas spawnean al player correctamente al cruzar habitaciones. Se agrega el sistema de diálogos con portraits (video feed) y texto por pantalla.

---

## Mar 2024 — Save system v1
Sistema de guardado/carga usando el Playdate datastore. Continue y New Game funcionando.

---

## Abr – May 2024 — DanceScene integrada al juego
El combate rítmico pasa de test scene a flujo real: tocar a un enemigo → transición a DanceScene → resultado → volver al maze. Balance bar, victoria/derrota, indicadores de UI.

---

## May 2024 — Localización japonés + inglés
Soporte completo para JP/EN con archivos `.strings`. Todo el texto del juego pasa por el sistema de localización.

---

## Jun 2024 — Props destructibles + holes + multi-floor
Los props se pueden romper. Los holes se vuelven mecánica real (caer entre pisos). La batería se drena fuera de la oscuridad. Primer soporte para niveles multi-capa.

---

## Sep 2024 — VERSION 0.1 LIVE
Primera versión pública con save habilitado. Hito concreto de "ya es jugable de inicio a fin".

---

## Dic 2024 — VERSION 0.2 + Transitions + Cutscenes con Panels
Sistema de transiciones entre escenas funcionando. Save system mejorado. El sistema de paneles integrado: cutscenes disparadas por triggers que muestran secuencias de cómics, flip con el crank.

---

## Ene 2025 — CrewMembers
Los aliados tripulantes aparecen como entidades propias con colisión, animaciones y sistema de hats.

---

## May 2025 — Sistema de Achievements
Framework completo de logros con la API nativa de Playdate. Los achievements se pueden disparar desde triggers, cutscenes y mecánicas de juego. Incluye un trophy card visual.

---

## Jun 2025 — Inventario (descartado antes del demo)
Se implementa un inventario funcional completo, pero se **desactiva antes del demo** del mismo mes. No llegó al estado necesario para mostrarse públicamente.

---

## Jul 2025 — Bit Summit
El juego se lleva al **Bit Summit** (festival indie de Japón). Commits de hotfix y brainstorm de ideas marcados explícitamente. Un punto de inflexión real en el desarrollo.

---

## Ago 2025 — Primer sistema de tilemap renderizado en runtime
Antes del PNG estático de 2026, se implementa un sistema de tilemap dibujado tile-por-tile en cada frame. Es la etapa intermedia entre "nada" y la migración a PNGs pre-renderizados.

---

## Ago 2025 — Dificultad dinámica en DanceScene
La DanceScene escala automáticamente con el `powerLevel` del enemigo: velocidad de botones, patrones, timing. Un sistema de dificultad progresiva ligado a la sanity del player.

---

## Oct 2025 — Migración total a LDtk
Cambio arquitectural mayor: el formato de niveles hardcodeado se reemplaza completamente por datos exportados de LDtk. Triggers, entidades, props y puertas ahora viven en el `.ldtk`. El save system se rehace para trackear entidades por `iid`.

---

## Oct 2025 — Transiciones verticales entre pisos
`fallBelow()` / `riseAbove()`: el player puede caer y subir entre habitaciones de distintos pisos con transición custom. Uno de los sistemas de navegación más complejos del juego.

---

## Nov 2025 — Colisores generados desde tiles
Las paredes dejan de ser sprites hardcodeados. Los colisores se generan automáticamente desde el IntGrid de LDtk, con clustering 2D para optimizar el número de rectángulos.

---

## Dic 2025 — Sistema de habilidades + Dash + Lightburst
El player gana un sistema de skills rotatorio en el menú. Dash con cooldown y animación propia. Lightburst: cono de luz como arma/herramienta.

---

## Dic 2025 — Items refactorizados a Skills
El sistema de ítems del inventario se convierte en un sistema de **habilidades activables** (Dash, Lightburst, Plungerang, Tiny). Un cambio de diseño de juego, no solo de código.

---

## Dic 2025 — Modo Tiny (Minificador)
El player puede encogerse usando una máquina Minifier. Cambia el collider, las animaciones, el comportamiento en puertas y triggers. Estado `isTiny` persistido en el save.

---

## Ene 2026 — CrewMember AI: hiding + bounce
Los tripulantes captivos tienen estado de escondite. Rebotan contra paredes con lógica de detección de atrapamiento.

---

## Feb 2026 — Plungerang (proyectil bumerang)
Nueva habilidad: el Plunger se lanza y vuelve al player describiendo una trayectoria de ida y vuelta. Colisiones con enemigos en ambas direcciones.

---

## Feb 2026 — Guías de port a Love2D
Se escriben guías técnicas de porting para Love2D. Indica que se consideró seriamente llevar el juego a otras plataformas.

---

## Mar 2026 — Config central + split de level data
Todos los magic numbers del juego pasan a `Config.lua`. Los datos de niveles se separan en archivos por piso (`levels_floor3.lua`, `levels_floor4.lua`) porque el archivo único se volvió inmanejable.

---

## Mar 2026 — Migración de render a PNG estático + foreground layer
El render de tiles pasa de dibujarse tile-por-tile en runtime a dos PNGs pre-renderizados por LDtk: `_composite.png` para el fondo, y un PNG separado para el foreground. El foreground se renderiza como sprite encima de los personajes para simular profundidad. Mejora de performance y fidelidad visual.

---

## Abr 2026 — NPC system + CreditsScene
NPCs con diálogo condicional y grants de ítems, spawnados desde LDtk. CreditsScene con scroll de texto e imágenes.

---

## Abr 2026 — CockpitScene
Puzzle de secuencia de botones con acelerómetro, radar visual, barras de progreso y sistema de fallos. Lleva a CreditsScene o TitleScene según el resultado.

---

## May 2026 — SpaceScene rehecha como escape runner
La SpaceScene se reescribe completa con sistemas terminados: meteoritos con peligro progresivo, barra de peligro, modos fighter/travel, lásers con energía, acelerómetro para el movimiento.

---

## May 2026 — PortalDoors
Los portales conectan habitaciones con transición especial. Permiten conexiones no lineales entre rooms más allá del sistema de puertas estándar.

---

*~4 años de desarrollo activo | ~570 commits | 2 grandes pivotes arquitecturales (LDtk oct 2025, PNG render mar 2026)*
