# In-Game Menu (inGameMenu)

This document describes the player's in-game menu: opening and closing, what it
displays, and the distinction between pause and the menu.

The menu is **purely visual / informational**. It shows the current run's map
(the active procedural run graph, with visited rooms highlighted) and the
hats of the captured crew members. There is no skill or item selection — abilities
fire directly from the B button based on context (see `PLAYER_SYSTEMS.md` and
`entities/player/abilities.lua`).

When the `debug` global is on, a **stat readout** is also painted on the menu's empty
right-hand page — see [Debug stat readout](#debug-stat-readout) below.

---

## Files Involved

| File | Class | Description |
|---|---|---|
| `entities/UI/inGameMenu.lua` | `inGameMenu` | Menu container (map + crew hats) |

---

## `inGameMenu` — Structure

Extends `Graphics.sprite`. Instantiated in `MazeScene:enter()`.

### Visual Components

| Component | Description | Position |
|---|---|---|
| `shadow` (400×240) | Semi-transparent background covering the screen | (200, 120) |
| `menuSprite` | Menu frame image (`assets/images/ui/menu/ingame-menu`), with the explored map drawn onto it | (200, 120) centered |
| `hatSprites` | Array of captured crew member hat sprites | Grid starting at (43, 108) |

### Z-Index

| Element | Z-Index |
|---|---|
| `inGameMenu` (shadow) | `ZIndex.menu` (2100) |
| `menuSprite` | `ZIndex.menu + 2` (2102) |
| Hat sprites | `ZIndex.menu + 9` (2109) |

---

## Opening the Menu

### Condition

```lua
function inGameMenu:displayMenu()
    if not PlayerData.items.hasDWatch then return end  -- requires D-Watch
    PlayerData.isGaming = false
    PlayerData.isEquiping = true
    self:drawMapOnMenu()
    if PlayerData.CrewMemberData.amountTaken > 0 then
        self:drawCrewHats()
    end
end
```

**Mandatory requirement:** `PlayerData.items.hasDWatch == true`. Without the D-Watch, `displayMenu()` returns without doing anything.

### Who Calls It

`MazeScene` calls it from `AButtonHeld` (A held for 1 second).

### State Changes

```
PlayerData.isGaming   → false   (disables gameplay, movement input, abilities)
PlayerData.isEquiping → true    (marks the menu as open)
```

---

## Closing the Menu

```lua
function inGameMenu:closeMenu()
    shadow:clear(Graphics.kColorClear)
    if menuSprite then menuSprite:remove() end
    -- Remove hat sprites
    for _, hatSprite in ipairs(self.hatSprites or {}) do
        hatSprite:remove()
    end
    self.hatSprites = nil
end
```

### Who Calls It

`MazeScene` calls it from `BButtonDown` when `isEquiping == true`.

### State Changes After Closing

```
PlayerData.isGaming   → true    (reactivates gameplay)
PlayerData.isEquiping → false
```

---

## Input While the Menu Is Open

The menu has **no interactive controls** of its own. While `isEquiping == true`:

- **A** does nothing menu-specific.
- **B** closes the menu (`MazeScene` `BButtonDown`).
- **◀ / ▶** still move the player's facing internally but perform no menu action.

---

## Distinction: Pause vs. Menu

The game **has no real pause system**. Opening the menu simulates a pause by setting `isGaming = false`, which:

- Stops player movement (movement input checks `isGaming`).
- Stops abilities (B checks `isGaming` to use abilities).
- Stops the enemy turn (`distributeMovementTokens` only runs when a B ability fires, which requires `isGaming == true`).

However, `update()` keeps running — the menu draws its components every frame. There is no literal engine freeze.

`SaveSystem.save()` is called in `scene:pause()` (Playdate system menu) and in `scene:finish()` — **not** when opening the menu.

---

## Crew Hats (`drawCrewHats`)

When opening the menu, if `CrewMemberData.amountTaken > 0`, hat sprites are created for each captured crew member.

### Layout

```
Start: x=43, y=108
Horizontal spacing: 20 px
Vertical spacing: 20 px
Maximum per row: 7 hats
```

Calculates the position of each hat by its grid index:
```lua
local row = math.floor(slotIndex / maxHatsPerRow)
local col = slotIndex % maxHatsPerRow
hatSprite:moveTo(hatX + col*20, hatY + row*20)
```

Hats are removed in `closeMenu()`.

---

## Game Map in the Menu

On opening, `inGameMenu:drawMapOnMenu()` first resets the working buffer to the pristine menu art (`baseMenuImage:draw(0,0)`) — so repeated opens never stack ghost renders — then calls `MapDrawer.drawMap(menuImage)` to draw the **current procedural run graph** directly onto it — not a fixed floor grid.

`MapDrawer` reads the grid cell `MapGenerator` assigned to each node (`node.coord = {col,row}`). The generator builds the run on a 2D grid, so every edge already connects physically adjacent cells (no overlaps, no teleport-looking links) — the map just plots those coordinates. Secret rooms also get a real grid cell next to their host (assigned by the generator), so they live inside the same grid as every other room. The only coord-less node is the revealed final room, which is placed next to a placed neighbour via its edge, nudged to the nearest free cell.

It then draws, inside `Config.Map.panel`:

- **Connection lines** between adjacent rooms (solid when both ends are visited, otherwise dithered).
- **Portal links**: a dithered line from a visited secret room to its host (portals are not cardinal edges, so this is drawn separately).
- **Current room** (`RunState.currentNodeId`): `roomColor` box with a contrasting `markerColor` center.
- **Visited rooms** (`node.visited`): solid `roomColor` box.
- **In-graph but not yet visited**: dithered `roomColor` box.

Colors are `Config.Map.roomColor` / `markerColor`. Secret rooms and the final room are **hidden until the player visits them** (a visited secret node appears offset from its portal host). `MapDrawer.calculateMapPercent()` returns the percent of the current run visited (visited non-secret nodes / total non-secret nodes).

---

## Notes for Porting to Love2D

### Structure in Love2D

```lua
-- InGameMenu.lua
InGameMenu = {}

function InGameMenu:open()
    if not PlayerData.items.hasDWatch then return end
    PlayerData.isGaming = false
    PlayerData.isEquiping = true
end

function InGameMenu:close()
    PlayerData.isGaming = true
    PlayerData.isEquiping = false
end

function InGameMenu:draw()
    if not PlayerData.isEquiping then return end
    -- Semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, 400, 240)
    -- Menu frame (with the explored map already drawn onto it)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.menuImage, 200, 120, 0, 1, 1,
        self.menuImage:getWidth()/2, self.menuImage:getHeight()/2)
    -- Captured crew hats
    self:drawCrewHats()
end
```

### Key Difference: Input Held

In Playdate, `AButtonHeld` is a Noble Engine callback that fires after 1 second. In Love2D, it must be detected manually with a timer in `love.update(dt)`.

---

## Debug stat readout

Only drawn when the `debug` global is on (System Menu → "debug", or the `up up up down`
cheat code). With debug off the menu is byte-for-byte what it was before.

The menu art is a two-page book: the left page carries the map and the crew hats, and the
**right page is empty** — that is where the readout goes. It is painted straight onto
`menuImage` from `drawDebugStats()`, called at the end of `drawMapOnMenu()`. Because it
shares the map's buffer, it inherits the pristine-art reset done there and needs **no sprite
of its own** — nothing extra to tear down in `closeMenu()`.

All values are read fresh from `PlayerData` on each open, so they are never stale.

| Column | Section | Rows |
|---|---|---|
| Left | `RUN` | `room` (`RunState.currentNodeId`), `run` (`runCount`), `map` (`mapPercent`) |
| Left | `FAT LOOP` | `calories`, `fat` (`isFat`), `steps` (`totalSteps`) |
| Left | `STATE` | `size` (BIG/TINY), `food` |
| Right | `BODY` | `hp`, `battery`, `sanity`, `madness` (`sanityCounter`) |
| Right | `PROGRESS` | `crew` (`amountTaken`/`totalCrew`), `power` (`EnemiesData.powerLevel`), `dances` |

Two labelling choices worth keeping:

- **`madness` is `sanityCounter`**, deliberately *not* labelled "sanity". The 0–100 resource
  and the lifetime counter are different numbers with different lifetimes, and conflating
  them has caused doc errors before.
- **`calories` prints one decimal.** Calories became a float when the fat loop landed
  (`Config.Calories.burnPerMove = 0.2`).

### Layout

Everything lives in `Config.DebugStats` — panel rect, line height, column gap, font.

Values are **right-aligned** at `panel.x + valueRight`, not drawn at a fixed offset from the
label. `totalSteps` is a lifetime counter that can reach six digits; right alignment lets a
long value grow back toward its own label instead of overrunning the next column. The
rightmost pixel lands at 380, inside the page border at ~385.

The block is vertically centred inside `panel` against whichever column has more rows.

### Love2D notes

Pure drawing code — port `Config.DebugStats` and `buildStatColumns()` as-is. The Playdate
version relies on `pushContext`/`popContext` saving and restoring the active font, so the
global `shinonome` default is left untouched; Love2D needs an explicit
`love.graphics.setFont()` back to the default after drawing the readout.
