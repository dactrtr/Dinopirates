# Tile Loading

This document describes the `tilemap.lua` structure, IntGrid values, the `CreateTileColliders` algorithm, the `Box` class, the `FXshadow` system, and portability notes.

---

## `tilemap.lua` Structure

File: `assets/data/tilemap.lua`

Defines the global table `tileMapData`, an array of 2D matrices. Each entry is the collision layout for one room.

```lua
tileMapData = {
    -- index 1
    {
        {5, 5, 5, 5, ...},    -- row 1
        {5, 1, 1, 4, 4, ...}, -- row 2
        ...
    },
    -- index 2
    { ... },
    ...
}
```

Each room in `levelsLDTK` has a `customFields.tile` field (integer) that acts as an index into `tileMapData`. The index is stored in `PlayerData.actualTilemap` when the room is entered.

The matrices are pure Lua data with no Playdate dependencies — they transfer directly to Love2D.

---

## IntGrid Values

Defined in `Config.Tiles.IntGrid`. These are the values that appear in the cells of the `tileMapData` matrices.

| Value | Name | In-game Effect |
|---|---|---|
| `1` | `wall` | Not walkable; generates a `Box` collider |
| `2` | `slime` | Walkable; player slides (`IsPlayerOnSlime`) |
| `3` | `hole` | Walkable; drains battery (`IsPlayerOnHole`) |
| `4` | `floor` | Walkable; no special effect |
| `32` | `tinyHole` | Walkable; only accessible in `isTiny` mode (`IsPlayerOnTinyHole`) |
| `0` | (empty) | Treated as non-walkable (wall) |
| `5` | (border) | Treated as non-walkable (wall) |
| any other | (decorative) | Treated as non-walkable (wall) |

The walkable lookup table in `Utilities.lua`:

```lua
local WALKABLE_TILES = {
    [Config.Tiles.IntGrid.slime]    = true,  -- 2
    [Config.Tiles.IntGrid.hole]     = true,  -- 3
    [Config.Tiles.IntGrid.floor]    = true,  -- 4
    [Config.Tiles.IntGrid.tinyHole] = true,  -- 32
}
```

Any value not in this table is treated as a wall and generates a collider.

---

## `CreateTileColliders` Algorithm

Global function defined in `utilities/Utilities.lua`. Converts the 2D matrix into optimized `Box` sprites.

```lua
function CreateTileColliders(tileData)
```

Receives `tileMapData[PlayerData.actualTilemap]` from `MazeScene:enter()`.

### Phase 1 — Horizontal Identification

Scans each row looking for contiguous sequences of non-walkable tiles:

```
Row y=3: [1][1][1][4][4][1][1]
          ^segment1^  ^seg2^
          x=1, w=3     x=6, w=2
```

Each segment is stored as `{x=startX, w=segmentWidth, used=false}` in `allSegments[y]`.

### Phase 2 — Vertical Merging

For each segment not marked as `used`, looks in subsequent rows for a segment with the same `x` and same `w`. If found, marks it as `used` and increments the height (`currentH`).

```
row 1: segment x=1, w=3  ─┐
row 2: segment x=1, w=3  ─┤ → Box(0, 0, 48, 32)  -- 3 tiles × 16px, 2 rows × 16px
row 3: NO match           ─┘
```

### `Box` Sprite Creation

When merging is complete, a `Box` instance is created:

```lua
local px = (segment.x - 1) * TILE_SIZE   -- x coordinate in pixels
local py = (y - 1) * TILE_SIZE            -- y coordinate in pixels
local pw = segment.w * TILE_SIZE          -- width in pixels
local ph = currentH * TILE_SIZE           -- height in pixels
Box(px, py, pw, ph)
```

`TILE_SIZE` is `Config.Tiles.size` = **16 px**.

### Optimization Benefit

Without merging: a 25×15 tile room = up to 375 collision sprites.
With merging: most walls collapse into 20–40 rectangles.

---

## `Box` Class

Defined in `utilities/Utilities.lua`. Extends `playdate.graphics.sprite`.

```lua
function Box:init(x, y, width, height)
    Graphics.setColor(playdate.graphics.kColorWhite)
    Graphics.fillRect(x, y, width, height)
    Graphics.drawRect(x, y, width, height)
    self:setSize(width, height)
    self:moveTo(x, y)
    self:setCenter(0, 0)
    self:addSprite()
    self:setCollideRect(0, 0, width, height)
    self:setGroups(CollideGroups.wall)   -- group 5
end
```

- Draws a white rectangle (useful in debug mode to visualize colliders).
- Collision group: `wall` (ID 5 in `Config.CollideGroups`).
- No update logic — it is a pure static collider.

---

## Tile Detection Under the Player

### `GetTileUnderPlayer(px, py)`

Converts pixel coordinates to cell indices and returns the IntGrid value:

```lua
local tileX = math.floor(x / TILE_SIZE) + 1
local tileY = math.floor(y / TILE_SIZE) + 1
return tileMapData[PlayerData.actualTilemap][tileY][tileX]
```

### 3×3 Grid Sampling

`IsPlayerOnSlime`, `IsPlayerOnHole`, and `IsPlayerOnTinyHole` sample 9 points around the player's feet to capture tile-edge overlaps:

```lua
local feetY = py + 12
local halfW = PlayerData.isTiny and 5 or 8
local xOffsets = { -halfW, 0, halfW }
local yOffsets = { -4, 0, 4 }
-- If any point falls on the target tile → returns true
```

---

## FXshadow — Darkness and Light Mask System

File: `entities/FX/FXshadow.lua`

`FXshadow` extends `Graphics.sprite`. It covers the entire screen with a shadow image (400×240) that has a dual light mask around the player. It is instantiated in `MazeScene:enter()` when `customFields.shadow == true`.

### Constructor

```lua
FXshadow(player, lightSize, globalLightAmount, Zindex)
```

| Parameter | Description |
|---|---|
| `player` | Reference to the player sprite |
| `lightSize` | Base radius of the light circle (in pixels) |
| `globalLightAmount` | Base global darkness level (0.0–1.0) |
| `Zindex` | Render layer — normally `ZIndex.fx` (1999) |

### Change Detection System

`refresh()` compares 6 variables against their last values to avoid redrawing every frame:

```
battery, direction, playerX, playerY, lightSizeMulti, globalLightAmount, showLightCone
```

If none changed and `shouldRefresh == false`, the function returns immediately.

### Lamp Levels by Battery

Battery is scaled internally: `battery = PlayerData.battery * 2` (effective range 0–200).

| Effective Battery Range | lightAmount (mask) | lightSourceSize | lightSourceAmount | globalLightAmount |
|---|---|---|---|---|
| 160 > bat > 120 | 0.2 | 35 px | 0.1 | 0.08 |
| 120 > bat > 80 | 0.5 | 30 px | 0.3 | 0.06 |
| 80 > bat > 40 | 0.7 | 25 px | 0.0 | 0.04 |
| 40 > bat > 0 | 0.9 | 20 px | 0.7 | 0.02 |
| bat <= 0 | 1.0 | 15 px | 0.9 | 0.01 |
| No lamp | 1.0 | 15 px | 0.9 | — |

`lightAmount` of 0.0 = fully transparent (maximum visibility); 1.0 = fully opaque (total blindness).

`maskSize` decreases as battery drops: `maskSize -= decreaseSize * N` where `N` is 1–5 depending on the level. `decreaseSize = maskSize / 10`.

When `PlayerData.isTiny == true`, `lightSizeMulti = 0.5` — the light radius is halved.

### Dither Patterns

All darkness is applied with Bayer 8×8 dithering:

```lua
Graphics.setDitherPattern(value, Graphics.image.kDitherTypeBayer8x8)
```

- `globalDither = self.globalLightAmount` — base global darkness layer.
- `lightAmount` — mask of the vision area (cone or circle).
- `lightSourceAmount` — small circle centered on the player for a point light source effect.

### Light Cone Geometry

The cone is a 9-vertex polygon built with `playdate.geometry.polygon.new(...)`.

Normal parameters:
- `d = 90` — forward distance in pixels.
- `h = 8` — lateral scale factor.

For `left`/`right`: polygon on the X axis with negative `d` if facing left.
For `up`/`down`: polygon on the Y axis with negative `d` if facing down.

If the player is in `idle`, a circle is drawn instead of a polygon:

```lua
if Direction == 'idle' then
    Graphics.fillCircleAtPoint(self.player.x, self.player.y, maskSize)
else
    Graphics.fillPolygon(Light)
end
```

### Lightburst (Flash Activated)

When `PlayerData.showLightCone == true` and `hasLamp == true`:
- The cone expands to `d=200`, `h=12`.
- `lightAmount`, `lightSourceAmount`, and `globalLightAmount` are all set to `0` — maximum visibility.
- `shouldRefresh = true` to force redraw every frame while the flash is active.

### Dual-Layer System

```
shadow (400×240 image)
  ├── layer 1: global fillRect with dithering = background darkness
  ├── mask 1 (shadowMask): cone/circle with lightAmount = main vision area
  └── mask 2 (lightSource): small circle with lightSourceAmount = point light source
```

---

## Notes for Porting to Love2D

### Tile Matrices — Direct Transfer

`tileMapData` is pure Lua. It can be used without modification in Love2D.

### Wall Colliders

```lua
-- Love2D with bump.lua
local TILE_SIZE = 16
local walkable = { [2]=true, [3]=true, [4]=true, [32]=true }

function buildWallColliders(tileData, world)
    -- Apply the same horizontal+vertical merge algorithm
    -- then add each merged rectangle:
    world:add({type="wall"}, rectX, rectY, rectW, rectH)
end
```

### Slime/Hole Detection

```lua
function getTileAt(px, py)
    local col = math.floor(px / 16) + 1
    local row = math.floor(py / 16) + 1
    local data = tileMapData[PlayerData.actualTilemap]
    if data and data[row] then return data[row][col] end
    return nil
end

function isSlime(px, py) return getTileAt(px, py) == 2 end
function isHole(px, py)  return getTileAt(px, py) == 3 end
```

### FXshadow in Love2D

Replace the sprite mask with a `love.graphics.Canvas` + stencil or a lighting shader. The cone geometry logic (9-vertex polygon) is compatible with `love.graphics.polygon`.

```lua
-- Equivalent of global dither
love.graphics.setColor(0, 0, 0, globalLightAmount)
love.graphics.rectangle("fill", 0, 0, 400, 240)

-- Light cone: clip with stencil
love.graphics.stencil(function()
    love.graphics.polygon("fill", unpack(coneVertices))
end, "replace", 1)
love.graphics.setStencilTest("equal", 1)
-- ... draw lit area
love.graphics.setStencilTest()
```
