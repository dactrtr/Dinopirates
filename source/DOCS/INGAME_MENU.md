# In-Game Menu (inGameMenu)

This document describes the player's in-game menu: opening and closing, what it
displays, and the distinction between pause and the menu.

The menu is **purely visual / informational**. It shows the explored map and the
hats of the captured crew members. There is no skill or item selection — abilities
fire directly from the B button based on context (see `PLAYER_SYSTEMS.md` and
`entities/player/abilities.lua`).

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

On opening, `inGameMenu:drawMapOnMenu()` calls `MapDrawer.drawMap(menuImage)` to draw the explored map directly onto the menu image.

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
