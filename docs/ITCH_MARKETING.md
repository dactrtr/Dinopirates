# Itch.io Page — Marketing Copy & Asset Ideas
> Borrador de features y cómo presentarlos. Cada sección tiene copy sugerido + qué GIF/screenshot capturar.

---

## 🎯 Tagline principal

**"Time moves when you move."**
> Simple, comunica el sistema turn-based sin explicarlo. Tiene peso.

Alternativa más narrativa:
**"A tiny dino, a sinking spaceship, and a lot of broccoli."**

---

## Features para destacar (en orden de impacto)

---

### 1. Un mundo que responde a tu tamaño

> *"Explore a world that shifts with your size — shrink down to reach hidden paths, uncover new dialogue, and see the ship from a whole new perspective."*

El Minifier es uno de los features más únicos del juego. Cambia colisiones, diálogos, accesos, y la forma en que los enemigos te perciben.

**Assets sugeridos:**
- GIF: player entrando al Minifier → shrink animation → moviéndose por un pasaje que antes era imposible
- GIF side-by-side o secuencial: mismo NPC con `isTiny=false` vs `isTiny=true` mostrando diálogos distintos
- Screenshot: player tiny junto a props normales para dar escala

---

### 2. Combate rítmico

> *"When enemies catch you, the fight goes to the dance floor. Read their moves, hit the right buttons, and keep your balance — or face the consequences."*

La DanceScene es el diferenciador más grande del juego. No hay combate de acción ni stats — todo depende de timing y lectura de patrones. La dificultad escala con tu estado mental (sanity), no con el nivel.

**Assets sugeridos:**
- GIF: transición maze → DanceScene (el momento del "oh no")
- GIF: secuencia de botones apareciéndose y el player respondiéndolos con la barra de balance moviéndose
- Screenshot: pantalla de resultado (victoria/derrota)

---

### 3. El tiempo avanza cuando vos avanzás

> *"Move to make time pass. Stand still and the world waits with you. Every step is a decision."*

El sistema turn-based es invisible pero se siente inmediatamente. Los enemigos solo se mueven cuando el player se mueve. La batería solo drena cuando hay acción. Es roguelike sin ser roguelike.

**Assets sugeridos:**
- GIF: player quieto → enemigo quieto → player mueve un paso → enemigo mueve un paso
- GIF: player cargando batería con el crank mientras un enemigo espera inmóvil

---

### 4. Cutscenes en cómic

> *"Full comic-panel cutscenes — flip through the story at your own pace using the crank."*

Panels integrado, páginas dibujadas, narración visual. El crank para pasar páginas es un uso perfecto del hardware de Playdate.

**Assets sugeridos:**
- GIF: cutscene de intro corriendo, con énfasis en el crank girando para avanzar páginas
- Screenshot: panel de cómic bien dibujado (el más vistoso que haya)

---

### 5. La oscuridad es el enemigo real

> *"Your lamp runs on battery. Your battery drains in the dark. Manage both — or watch your sanity crumble."*

El triángulo batería → oscuridad → sanity es el loop de supervivencia del juego. Cuanto más baja la sanity, más agresivo se vuelve el combate rítmico.

**Assets sugeridos:**
- GIF: player con lamp encendida vs sin lamp en oscuridad (el FXshadow cubriendo todo)
- Screenshot: HUD con batería crítica + indicador de sanity bajo

---

### 6. Un barco que explorar verticalmente

> *"Fall through floors. Rise through hatches. The ship is yours to unravel — one room at a time."*

La navegación vertical (caer entre pisos, subir por tubos si sos tiny) da sensación de lugar real, no de pantallas desconectadas.

**Assets sugeridos:**
- GIF: player cayendo de un piso al siguiente con la transición custom
- GIF: player tiny subiendo por un tubo neumático (que bloqueado en tamaño normal)

---

### 7. El crank tiene un rol real

> *"Charge your battery. Turn the pages. The crank isn't a gimmick — it's how you survive."*

El crank se usa para cargar la batería en gameplay y para pasar páginas en cutscenes. No es decorativo.

**Assets sugeridos:**
- GIF: player quieto girando el crank → barra de batería subiendo
- Mención en copy: "optimizado para Playdate — incluyendo el crank"

---

### 8. Tripulantes a rescatar

> *"Your crew is scattered across the ship. Find them before the enemy does."*

Los CrewMembers tienen IA propia — se esconden, rebotan, reaccionan al jugador. No son solo NPCs estáticos.

**Assets sugeridos:**
- GIF: crew member escondiéndose cuando el player se acerca
- Screenshot: crew member con hat en el menú (el sistema de hats es un detalle lindo)

---

### 9. Habilidades que cambian cómo jugás

> *"Dash through walls. Blind enemies with your lamp. Launch the plungerang and watch it come back."*

Cada habilidad cambia la forma de moverse y sobrevivir. No son power-ups — son herramientas que permanecen.

**Assets sugeridos:**
- GIF: dash atravesando un espacio y destruyendo una caja
- GIF: Lightburst cegando a un enemigo (el cono de luz es visualmente fuerte)
- GIF: Plungerang yendo y volviendo

---

### 10. Japonés + Inglés

> *"Fully localized in English and Japanese."*

Para un juego de Playdate, esto es notable. Vale mencionarlo aunque sea en los detalles.

---

## Copy de descripción general (borrador)

> You're a small dino on a sinking spaceship full of broccoli enemies.
>
> Move to make time pass. Manage your battery. Keep your sanity intact. When enemies catch you, the fight moves to the dance floor — read their button patterns and keep your balance bar from tipping.
>
> Shrink yourself down to reach places others can't. Find your crew before they're taken. Flip through comic cutscenes with the crank.
>
> **DinoPirates from Inner Space** is a turn-based exploration game built for Playdate — every mechanic designed around the hardware, including the crank.

---

## Notas de producción de assets

| Asset | Prioridad | Notas |
|---|---|---|
| GIF tiny vs normal (diálogo) | Alta | Capturar mismo trigger, dos runs |
| GIF DanceScene en acción | Alta | El más espectacular visualmente |
| GIF oscuridad con/sin lamp | Alta | Contraste inmediato, se entiende solo |
| GIF Minifier shrink | Media | La animación de shrink tiene que verse bien |
| GIF crank cargando batería | Media | Simple pero comunica el hardware |
| GIF caída entre pisos | Media | La transición custom se ve bien |
| GIF plungerang | Baja | Bonito pero no el feature principal |
| Screenshot panel de cómic | Alta | Si el arte está bien, vende solo |

---

## Qué NO poner (trampas comunes)

- ❌ "Roguelike" — no lo es, no generar expectativas equivocadas
- ❌ Screenshots del editor LDtk o código — obvio pero vale decirlo
- ❌ GIFs muy largos — Playdate es 1-bit, los GIFs tienen que ser cortos y de alto contraste para verse bien en previews
- ❌ Mencionar que está en desarrollo si ya es demo pública — genera desconfianza
