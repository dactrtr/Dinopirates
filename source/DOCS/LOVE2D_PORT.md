# Port Guide: DinoPirates from Inner Space → Love2D

This document describes how to port DinoPirates from the Playdate SDK + Noble Engine to Love2D with bump.lua. It is based on the actual game source code, not on generic assumptions.

---

## 1. Original Stack Summary

| Component | Technology |
|-----------|------------|
| Platform | Panic Playdate (dedicated hardware) |
| Resolution | 400×240 px, 1-bit display (black/white) |
| Framerate | 50 fps (`playdate.display.setRefreshRate(50)`) |
| Language | Lua 5.4 |
| Framework | Noble Engine — handles scenes, sprites, transitions, input |
| Graphics | `playdate.graphics` — sprites, images, polygons, dithering |
| Collisions | Noble/Playdate collision group system (`setGroups`, `moveWithCollisions`) |
| Levels | LDtk exported as Lua (`levelsLDTK` in `assets/data/levels.lua`) |
| Saves | `playdate.datastore.write/read` — stores serialized Lua table |
| Special input | Crank (physical handle), accelerometer, pedometer |

The game uses **soft turn-based input**: time advances when the player moves. The `PlayerData.isActive` flag synchronizes enemies with player movement.

---

## 2. Equivalent Love2D Stack

### Recommended version
**Love2D 11.5** (stable) or **12.0** if already available. Version 11.x has solid support across all platforms.

### Replacement libraries

| Original need | Love2D replacement |
|---------------|-------------------|
| Noble Engine (scenes, sprites) | Custom Scene Manager (see section 5) |
| `Graphics.sprite` with groups | bump.lua for collisions + `love.graphics` for rendering |
| `playdate.graphics.setDitherPattern` | GLSL shaders (see section 7) |
| `playdate.geometry.polygon` | `love.math.newPolygon` / `love.graphics.polygon` |
| `playdate.datastore` | `love.filesystem` + json.lua |
| Spritesheet animations | anim8 |
| Smooth transitions | flux or tween |
| Tilemap loading | Optional: STI (Simple Tiled Implementation) |

### Resolution and scaling

The native game runs at **400×240**. In Love2D you can keep that logical resolution and scale it up:

```lua
-- main.lua (Love2D)
function love.conf(t)
    t.window.width  = 800   -- 2x scale
    t.window.height = 480
    t.window.title  = "DinoPirates from Inner Space"
end

-- In love.draw(), apply global scale:
love.graphics.scale(2, 2)
-- Then draw everything in 400×240 coordinates
```

---

## 3. Critical API Mapping

### Full equivalence table

| System | Playdate / Noble | Love2D equivalent |
|--------|-----------------|-------------------|
| **Main loop** | `playdate.update()` auto | `love.update(dt)` + `love.draw()` |
| **Sprites** | `NobleSprite`, `Graphics.sprite.new()` | Lua tables with position + `love.graphics.draw()` |
| **Collision groups** | `setGroups(n)`, `setCollidesWithGroups({...})` | bump.lua filters by object type |
| **Move with collision** | `self:moveWithCollisions(x, y)` | `world:move(item, x, y, filter)` |
| **Animations** | `animation:addState('walk', 1, 8)`, `setState()` | anim8: `anim8.newGrid()`, `anim8.newAnimation()` |
| **Button input** | `playdate.buttonIsPressed(playdate.kButtonRight)` | `love.keyboard.isDown("right")` |
| **Input callbacks** | `scene.inputHandler = { AButtonDown = fn }` | `love.keypressed(key)` and `love.keyreleased(key)` |
| **Crank** | `playdate.getCrankChange()`, `getCrankTicks(4)` | Mouse wheel: `love.wheelmoved(x, y)` or an analog gamepad axis |
| **Crank docked** | `crankDocked = function()` | `love.gamepadaxis` / state detection |
| **Accelerometer** | `playdate.readAccelerometer()` → `x, y, z` | `love.joystick:getAxes()` or relative mouse |
| **Delay timers** | `playdate.timer.performAfterDelay(ms, fn)` | Manual `dt` accumulator (see section 3.1) |
| **Generic timers** | `playdate.timer.new(ms, fn)` | Manual `dt` accumulator |
| **Saves** | `playdate.datastore.write(data, 'gameState', true)` | `love.filesystem.write("gameState.json", json.encode(data))` |
| **Load save** | `playdate.datastore.read('gameState')` | `json.decode(love.filesystem.read("gameState.json"))` |
| **Images** | `Graphics.image.new('path')` | `love.graphics.newImage("path.png")` |
| **Spritesheets** | `Graphics.imagetable.new('path')` | `love.graphics.newImage` + anim8 quads |
| **Fonts** | `Graphics.font.new('path')` | `love.graphics.newFont("path.ttf", size)` |
| **Draw text** | `Graphics.drawText("*bold*", x, y)` | `love.graphics.print(text, x, y)` |
| **Sound** | `playdate.sound.sampleplayer.new()`, `.play()` | `love.audio.newSource()`, `:play()` |
| **Music** | `playdate.sound.fileplayer.new()` | `love.audio.newSource("file.ogg", "stream")` |
| **Dithering / Masking** | `Graphics.setDitherPattern(amount, kDitherTypeBayer8x8)` | GLSL shader with Bayer texture or simple alpha |
| **Image canvas** | `Graphics.image.new(400, 240)` + `pushContext/popContext` | `love.graphics.newCanvas(400, 240)` + `setCanvas/setCanvas(nil)` |
| **Polygon** | `playdate.geometry.polygon.new(x1,y1, x2,y2, ...)` | `love.graphics.polygon("fill", x1,y1, x2,y2, ...)` |
| **Filled rectangle** | `Graphics.fillRect(x, y, w, h)` | `love.graphics.rectangle("fill", x, y, w, h)` |
| **Circle** | `Graphics.fillCircleAtPoint(x, y, r)` | `love.graphics.circle("fill", x, y, r)` |
| **Color** | `Graphics.setColor(kColorBlack)` | `love.graphics.setColor(r, g, b, a)` (0–1) |
| **Z-Index / draw order** | `sprite:setZIndex(n)` — Noble sorts automatically | Manually sort object list before drawing |
| **Scene transitions** | `Noble.transition(TitleScene, 0.3, Noble.Transition.MetroNexus)` | Scene Manager with fade (see section 5) |
| **FPS** | `playdate.display.setRefreshRate(50)` | `love.conf → t.window.vsync`, no 50fps cap in Love2D |
| **Time** | `playdate.getCurrentTimeMilliseconds()` | `love.timer.getTime() * 1000` |
| **Timestamp** | `playdate.getTime()` | `os.time()` |

### 3.1. Keyboard Input Mapping (canonical reference)

All Playdate hardware inputs map to fixed keys in the Love2D port. **Every section of this document uses these keys — do not deviate.**

| Playdate input | Love2D key | Notes |
|----------------|-----------|-------|
| **A button** | `Z` | Interact, confirm, trigger dialog, start minifying |
| **B button** | `X` | Use active ability (plungerang, flash), cancel minifying, close menu |
| **D-pad Up** | `Up arrow` | Move up |
| **D-pad Down** | `Down arrow` | Move down |
| **D-pad Left** | `Left arrow` | Move left |
| **D-pad Right** | `Right arrow` | Move right |
| **Crank clockwise** | `E` | **Increase value**: charge battery, grow (in minifier if tiny) |
| **Crank counterclockwise** | `Q` | **Decrease value**: shrink (in minifier if not tiny) |
| **DanceScene A** | `Z` | A button input in rhythm combat |
| **DanceScene B** | `X` | B button input in rhythm combat |
| **DanceScene Up** | `Up arrow` | Arrow input in rhythm combat |
| **DanceScene Down** | `Down arrow` | Arrow input in rhythm combat |
| **DanceScene Left** | `Left arrow` | Arrow input in rhythm combat |
| **DanceScene Right** | `Right arrow` | Arrow input in rhythm combat |
| **System Menu** | `Escape` | Pause / in-game menu |
| **A held (1s)** | `Z` held 1 second | Open equipment menu (requires `hasDWatch`) |

> **Note on crank**: the Playdate crank has no speed/tick-rate sensitivity in this game — only direction matters. `getCrankTicks(4)` returns `+1` or `-1` per quarter revolution. Holding E or Q and repeating at ~4 presses per second is the exact equivalent for battery charging and minifier transformation. There is no analogue ramp-up to implement.

---

### 3.2. Implementing timers with a dt accumulator

The game uses `playdate.timer.performAfterDelay(ms, fn)` extensively (ability cooldowns, invincibility, sanity ticks). That helper does not exist in Love2D — use an accumulator instead:

```lua
-- Define a simple timer utility
local Timer = {}
Timer.__index = Timer

function Timer.after(seconds, callback)
    return { elapsed = 0, duration = seconds, callback = callback, done = false }
end

function Timer.update(t, dt)
    if t.done then return end
    t.elapsed = t.elapsed + dt
    if t.elapsed >= t.duration then
        t.done = true
        t.callback()
    end
end

-- Equivalent to playdate.timer.performAfterDelay(1000, fn):
local t = Timer.after(1.0, function()   -- 1000 ms = 1.0 sec
    player.isInvincible = false
end)
-- In update(dt): Timer.update(t, dt)
```

For the LightBurst cooldown (`Config.LightBurst.cooldown = 1000` ms) and invincibility (`Config.Invincibility.duration = 1000` ms), this pattern directly replaces the Playdate timers.

### 3.3. Crank → Q and E keys

The crank maps to **Q** (counterclockwise / decrease) and **E** (clockwise / increase). See the canonical mapping table in section 3.1.

| Use | Key | Condition |
|-----|-----|-----------|
| Charge battery (+3 per press) | **E** | `isGaming == true`, battery < 100, not in minifier, not tiny |
| Grow (tiny → normal) | **E** | `isGaming == false`, `readyToShrink == true`, `isTiny == true` |
| Shrink (normal → tiny) | **Q** | `isGaming == false`, `readyToShrink == true`, `isTiny == false` |

Implementation replacing the `cranked` callback:

```lua
-- In love.keypressed(key):
elseif key == "e" then
    -- Clockwise crank (E = increase value)
    if PlayerData.isGaming then
        if PlayerData.battery < 100 and not PlayerData.readyToShrink and not PlayerData.isTiny then
            player:chargeBattery(3)
        end
    elseif PlayerData.readyToShrink and PlayerData.isTiny then
        PlayerData.actualPlayerSize = math.min(PlayerData.actualPlayerSize + 1, PlayerData.playerSize)
        player:transformCycle()
        if PlayerData.actualPlayerSize >= PlayerData.playerSize then
            player:grow(); player:finishMinifying()
        end
    end

elseif key == "q" then
    -- Counterclockwise crank (Q = decrease value)
    if PlayerData.readyToShrink and not PlayerData.isTiny then
        PlayerData.actualPlayerSize = math.max(PlayerData.actualPlayerSize - 1, 0)
        player:transformCycle()
        if PlayerData.actualPlayerSize <= 0 then
            player:shrink(); player:finishMinifying()
        end
    end
    -- Q has no effect in normal gameplay
end
```

> Each key press = one `getCrankTicks(4)` tick (±1). No speed ramp-up needed — the original game has no velocity-sensitive crank logic.

---

## 4. Collision System with bump.lua

### The original system

The game uses **6 collision groups** defined in `Config.CollideGroups`:

```lua
Config.CollideGroups = {
    player     = 1,
    enemy      = 2,
    props      = 3,
    items      = 4,
    wall       = 5,
    noCollide  = 6,
    crewMember = 7,
}
```

Each sprite declares which group it belongs to (`setGroups`) and which groups it collides with (`setCollidesWithGroups`). The Player collides with: enemy, props, items, wall, crewMember. Enemies (Brocorat) collide with: player, props, wall, enemy.

The method `self:moveWithCollisions(x, y)` returns `actualX, actualY, collisions, length`. Each collision has `.other` (the hit sprite) and `.normal` (impact vector).

### Creating the bump.lua world

```lua
-- In the scene manager / MazeScene equivalent
local bump = require("libs/bump")
local TILE_SIZE = 16

-- Create world with cell size equal to tile size
world = bump.newWorld(TILE_SIZE)
```

### Adding entities

```lua
-- Each entity is a table with a defined type
local player = {
    type = "player",
    x = spawnX, y = spawnY,
    w = 30, h = 24   -- from Config.Player.collideRect
}
world:add(player, player.x, player.y, player.w, player.h)

local enemy = {
    type = "enemy",
    x = ex, y = ey,
    w = 32, h = 32
}
world:add(enemy, enemy.x, enemy.y, enemy.w, enemy.h)
```

### Filters by type (equivalent to collision groups)

In bump.lua the filter is a function passed to `world:move()`:

```lua
-- Filter for PLAYER: slide with walls/props, overlap with enemy/items/crew
local function playerFilter(item, other)
    if other.type == "wall" then
        return "slide"
    elseif other.type == "enemy" then
        return "cross"   -- detect but don't block (collision triggers fight())
    elseif other.type == "item" then
        return "cross"
    elseif other.type == "door" then
        return "cross"
    elseif other.type == "crewMember" then
        return "cross"
    elseif other.type == "prop" then
        return "slide"
    end
    return nil  -- ignore everything else
end

-- Filter for ENEMIES: slide with walls/props/other enemies, cross with player
local function enemyFilter(item, other)
    if other.type == "wall" then
        return "slide"
    elseif other.type == "prop" then
        return "slide"
    elseif other.type == "enemy" then
        return "slide"
    elseif other.type == "player" then
        return "cross"   -- detect contact but don't block
    end
    return nil
end
```

### Moving entities

```lua
-- Equivalent to self:moveWithCollisions(movementX, movementY)
function movePlayer(player, targetX, targetY)
    local actualX, actualY, cols, len = world:move(player, targetX, targetY, playerFilter)
    player.x = actualX
    player.y = actualY

    -- Process collisions
    for i = 1, len do
        local col = cols[i]
        local other = col.other

        if other.type == "enemy" then
            fight(player, other)   -- equivalent to player:fight()
        elseif other.type == "item" then
            collectItem(player, other)
        elseif other.type == "door" then
            goToRoom(other.nextRoom)
        end
    end
end
```

### bump.lua response types

| Response | Behavior | Use when |
|----------|----------|----------|
| `"slide"` | Slides along the surface (like normal moveWithCollisions) | Walls, solid props |
| `"bounce"` | Bounces at the opposite angle | Not used in this game |
| `"cross"` | Passes through, detection only | Enemy↔Player, items, doors |
| `"touch"` | Stops exactly at the edge | Not needed here |

### Enemy bounce (bounceFactor)

The `Enemy:moveCollision()` code applies a push of `Config.Enemy.bounceFactor = 3` px in the opposite direction when the enemy hits props or walls. In bump.lua:

```lua
-- After world:move() in enemy logic:
for i = 1, len do
    local col = cols[i]
    if col.other.type == "wall" or col.other.type == "prop" then
        local nx = col.normal.x
        local ny = col.normal.y
        -- Push 3px in the normal direction
        enemy.x = enemy.x + nx * 3
        enemy.y = enemy.y + ny * 3
        world:update(enemy, enemy.x, enemy.y)
    elseif col.other.type == "player" then
        col.other.onEnemyHit(enemy)   -- trigger fight
    end
end
```

### CreateTileColliders with bump.lua

The game has a `CreateTileColliders(tileData)` function in `Utilities.lua` that merges horizontal and vertical segments to create large rectangles. The same algorithm works in Love2D:

```lua
function createTileColliders(tileData, world)
    local colliders = {}
    local WALKABLE = { [2]=true, [3]=true, [4]=true, [32]=true }
    -- (slime=2, hole=3, floor=4, tinyHole=32)

    -- Phase 1: horizontal segments per row
    local allSegments = {}
    for y = 1, #tileData do
        allSegments[y] = {}
        local x = 1
        while x <= #tileData[y] do
            local tileID = tileData[y][x]
            if not WALKABLE[tileID] then
                local startX = x
                while x <= #tileData[y] and not WALKABLE[tileData[y][x]] do
                    x = x + 1
                end
                local segW = x - startX
                table.insert(allSegments[y], {x=startX, w=segW, used=false})
            else
                x = x + 1
            end
        end
    end

    -- Phase 2: vertical merge
    for y = 1, #allSegments do
        for _, seg in ipairs(allSegments[y]) do
            if not seg.used then
                local h = 1
                for ny = y + 1, #allSegments do
                    local found = false
                    for _, ns in ipairs(allSegments[ny]) do
                        if not ns.used and ns.x == seg.x and ns.w == seg.w then
                            ns.used = true
                            h = h + 1
                            found = true
                            break
                        end
                    end
                    if not found then break end
                end

                local px = (seg.x - 1) * 16
                local py = (y - 1) * 16
                local pw = seg.w * 16
                local ph = h * 16

                local collider = {type="wall", x=px, y=py, w=pw, h=ph}
                world:add(collider, px, py, pw, ph)
                table.insert(colliders, collider)
            end
        end
    end

    return colliders
end
```

### Removing entities when leaving a scene

```lua
-- In the equivalent of MazeScene exit()
for _, col in ipairs(tileColliders) do
    world:remove(col)
end
world:remove(player)
for _, e in ipairs(enemies) do
    world:remove(e)
end
```

---

## 5. Scene System

Noble Engine provides: scene classes, automatic lifecycle, and animated transitions. These must be replaced with a custom Scene Manager.

### Base scene structure

```lua
-- scenes/MazeScene.lua (Love2D)
local MazeScene = {}

function MazeScene:init()
    -- Called once when the scene is created
    -- Equivalent to scene:init() in Noble
end

function MazeScene:enter(params)
    -- Called when the scene becomes active
    -- params: data passed from the previous scene (nextRoom, spawn, etc.)
    -- Equivalent to scene:enter()
    self.world = bump.newWorld(16)
    self.player = createPlayer(params.spawnX, params.spawnY, self.world)
    self.tileColliders = createTileColliders(tileData, self.world)
    -- ... load enemies, doors, props
end

function MazeScene:update(dt)
    -- Equivalent to scene:update()
    updatePlayer(self.player, dt, self.world)
    updateEnemies(self.enemies, self.player, dt)
end

function MazeScene:draw()
    -- Equivalent to scene:drawBackground() + sprite rendering
    love.graphics.draw(self.bgImage, 0, 0)
    drawEntities(self.entities)
end

function MazeScene:exit()
    -- Equivalent to scene:exit()
    -- Clean up world, sprites, etc.
    for _, col in ipairs(self.tileColliders) do
        self.world:remove(col)
    end
    self.world = nil
end

return MazeScene
```

### Scene Manager with fade

```lua
-- SceneManager.lua
local SceneManager = {}
local currentScene = nil
local nextScene    = nil
local nextParams   = nil
local fadeAlpha    = 0
local isFadingOut  = false
local isFadingIn   = false
local FADE_SPEED   = 2.0  -- alpha per second (0→1 in 0.5 sec)

function SceneManager.transition(SceneClass, params)
    nextScene  = SceneClass
    nextParams = params or {}
    isFadingOut = true
end

function SceneManager.update(dt)
    -- Update active scene
    if currentScene and currentScene.update then
        currentScene:update(dt)
    end

    -- Fade out
    if isFadingOut then
        fadeAlpha = math.min(1, fadeAlpha + FADE_SPEED * dt)
        if fadeAlpha >= 1 then
            -- Switch scene at the peak of the fade
            if currentScene and currentScene.exit then
                currentScene:exit()
            end
            currentScene = nextScene.new()
            currentScene:enter(nextParams)
            isFadingOut = false
            isFadingIn  = true
        end
    end

    -- Fade in
    if isFadingIn then
        fadeAlpha = math.max(0, fadeAlpha - FADE_SPEED * dt)
        if fadeAlpha <= 0 then
            isFadingIn = false
        end
    end
end

function SceneManager.draw()
    if currentScene and currentScene.draw then
        currentScene:draw()
    end
    -- Fade overlay
    if fadeAlpha > 0 then
        love.graphics.setColor(0, 0, 0, fadeAlpha)
        love.graphics.rectangle("fill", 0, 0, 400, 240)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

-- Usage:
-- SceneManager.transition(TitleScene, {})
-- Equivalent to: Noble.transition(TitleScene, 0.3, Noble.Transition.MetroNexus)
```

### Full equivalent lifecycle

| Noble Engine | Love2D (SceneManager) |
|-------------|----------------------|
| `scene:init()` | `Scene.new()` / constructor |
| `scene:enter()` | `scene:enter(params)` — called after the fade out |
| `scene:start()` | At the end of `enter()` or when the fade in completes |
| `scene:update()` | `scene:update(dt)` — called every frame |
| `scene:drawBackground()` | First block in `scene:draw()` |
| `scene:exit()` | `scene:exit()` — called before destroying the scene |
| `scene:finish()` | Post-transition callback (optional) |
| `scene:pause()` | When the game loses focus: `love.focus(false)` |

### Z-Index (draw order)

Noble Engine sorts sprites automatically by `ZIndex`. In Love2D the list must be sorted manually:

```lua
-- Original Config.ZIndex:
-- player=4, enemy=3, props=2, items=4, foreground=300, fx=1999, ui=2000

-- Before draw(), sort the entity list
table.sort(entities, function(a, b)
    return a.zIndex < b.zIndex
end)

for _, entity in ipairs(entities) do
    entity:draw()
end
```

---

## 6. Loading LDtk Levels

### Good news: levels.lua is directly compatible

The file `assets/data/levels.lua` (along with `levels_floor3.lua`, `levels_floor4.lua`) defines the global table `levelsLDTK`. This format is pure Lua and **works without changes** in Love2D:

```lua
-- In Love2D's main.lua:
require("assets.data.levels")   -- Loads levelsLDTK
-- Note: Love2D uses "." instead of "/" in require()
```

The structure of each room in `levelsLDTK` is:

```lua
{
    identifier     = "Room_23",
    uniqueIdentifer = "3d752854-...",
    neighbourLevels = { { levelIid="...", dir="n" }, ... },
    customFields   = {
        shadow = false, light = 0, visited = false,
        level = 3, roomNumber = 23, tile = 23,
        DoorsConnection = {"Upper"},
        hasForeground = true,
        -- ...
    },
    entities = {
        Brocorat = { { iid="...", x=100, y=80, customFields={...} } },
        Doors    = { { iid="...", x=393, y=122, customFields={DoorsConnection="right"} } },
        -- ...
    }
}
```

### roomsByIid (hash index)

Exactly the same as in the original `main.lua`:

```lua
roomsByIid = {}
for _, room in ipairs(levelsLDTK) do
    if room and room.uniqueIdentifer then
        roomsByIid[room.uniqueIdentifer] = room
    end
end
```

### Rendering tilemaps

The game loads pre-rendered backgrounds as PNG files:
```lua
-- Original (Playdate):
Graphics.image.new('assets/images/rooms/floor3/Room_23')

-- Love2D:
love.graphics.newImage("assets/images/rooms/floor3/Room_23.png")
```

For the IntGrid (tile data for collisions), the `tileMapData` file contains 2D matrices of IDs. STI is not needed — it can be used directly with `createTileColliders()` described in section 4.

If you want to render tiles dynamically (without pre-made PNGs), you can use STI or load the `.ldtk` file with ldtk-love. However, since the game already exports backgrounds as PNGs, reusing those images is the most straightforward approach.

---

## 7. Lighting / FXshadow System

### The original system

`FXshadow` is a 400×240 px sprite that acts as a darkness mask. It uses:
1. **Internal canvas** (`Graphics.image.new(400, 240)`) drawn with `Graphics.pushContext(shadow)`
2. **Bayer 8×8 dithering** (`setDitherPattern(amount, kDitherTypeBayer8x8)`) for a darkness gradient
3. **Light cone polygon** (`playdate.geometry.polygon.new(...)`) directional, based on `PlayerData.direction`
4. **Three layers**: global darkness (heavy dither), primary light mask (circle or cone), secondary light focus (small circle at the origin)

Light parameters scale with `PlayerData.battery * 2`:
- Battery > 80%: little darkness, wide cone
- Battery 0–40%: maximum darkness, small cone
- No lamp: fixed minimum visibility (radius 50px)

### Love2D implementation

```lua
-- FXshadow.lua (Love2D)
local FXshadow = {}

function FXshadow.new(player)
    local self = {
        player = player,
        canvas = love.graphics.newCanvas(400, 240)
    }
    return setmetatable(self, {__index = FXshadow})
end

function FXshadow:refresh(playerData)
    local battery    = playerData.battery * 2
    local direction  = playerData.direction
    local px         = playerData.x
    local py         = playerData.y
    local hasLamp    = playerData.items.hasLamp
    local isTiny     = playerData.isTiny

    -- Calculate light parameters (same logic as the original)
    local maskSize    = (isTiny and 35 or 70)
    local lightAlpha  = 1.0   -- how much to darken (0=transparent, 1=full black)
    local globalAlpha = 0.6

    if hasLamp then
        if battery > 120 then
            lightAlpha = 0.2; globalAlpha = 0.08
        elseif battery > 80 then
            lightAlpha = 0.5; globalAlpha = 0.06
        elseif battery > 40 then
            lightAlpha = 0.7; globalAlpha = 0.04
        elseif battery > 0 then
            lightAlpha = 0.9; globalAlpha = 0.02; maskSize = maskSize - 14
        else
            lightAlpha = 1.0; globalAlpha = 0.01; maskSize = maskSize - 21
        end
    else
        maskSize = 50; lightAlpha = 1.0; globalAlpha = 0.5
    end

    -- Build the cone polygon (same vertices as the original)
    local d = 90
    local h = 8
    if direction == 'left' or direction == 'down' then d = -d end
    local conePolygon = nil
    if direction == 'left' or direction == 'right' then
        conePolygon = {
            px, py,
            px+d,       py-4*h,
            px+1.1*d,   py-3.5*h,
            px+1.2*d,   py-2*h,
            px+1.25*d,  py,
            px+1.2*d,   py+2*h,
            px+1.1*d,   py+3.5*h,
            px+d,       py+4*h,
            px, py
        }
    elseif direction == 'up' or direction == 'down' then
        conePolygon = {
            px, py,
            px-4*h,   py-d,
            px-3.5*h, py-1.1*d,
            px-2*h,   py-1.2*d,
            px,       py-1.25*d,
            px+2*h,   py-1.2*d,
            px+3.5*h, py-1.1*d,
            px+4*h,   py-d,
            px, py
        }
    end

    -- Draw to canvas using a stencil
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(0, 0, 0, 0)

    -- 1. Global darkness (semi-transparent black background, simulating "dither" via alpha)
    love.graphics.setColor(0, 0, 0, globalAlpha)
    love.graphics.rectangle("fill", 0, 0, 400, 240)

    -- 2. Cut out the light area with a stencil
    love.graphics.stencil(function()
        love.graphics.setColor(1, 1, 1, 1)
        if direction == 'idle' or not conePolygon then
            love.graphics.circle("fill", px, py, maskSize)
        else
            love.graphics.polygon("fill", conePolygon)
        end
        -- Secondary focus (small circle at the origin)
        love.graphics.circle("fill", px, py, 15)
    end, "replace", 1)

    -- 3. Primary darkness, clipped by the stencil
    love.graphics.setStencilTest("notequal", 1)
    love.graphics.setColor(0, 0, 0, lightAlpha)
    love.graphics.rectangle("fill", 0, 0, 400, 240)
    love.graphics.setStencilTest()

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
end

function FXshadow:draw()
    love.graphics.draw(self.canvas, 0, 0)
end
```

### Bayer dithering → GLSL shader

Playdate's 1-bit dithering can be approximated with a shader in Love2D if you want the exact pixel-art look:

```glsl
-- dither.glsl
extern number threshold;  -- 0.0 to 1.0

// Normalized 8x8 Bayer matrix
float bayer[64] = float[64](
    0.0/64.0,  32.0/64.0,  8.0/64.0, 40.0/64.0, ...
);

vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 screenCoord) {
    int bx = int(mod(screenCoord.x, 8.0));
    int by = int(mod(screenCoord.y, 8.0));
    float bayerVal = bayer[by * 8 + bx];
    float alpha = threshold > bayerVal ? 1.0 : 0.0;
    return vec4(0.0, 0.0, 0.0, alpha);
}
```

For a port that does not require an exact 1-bit look, the canvas with gradual alpha is sufficient.

---

## 8. Save System

### The original system

`SaveSystem.lua` uses `playdate.datastore.write(saveData, 'gameState', true)`. The `saveData` contains:
- `player`: all of `PlayerData` (health, inventory, battery, sanity, position)
- `levelState`: state of all entities across all levels (dead/destroyed/isTaken by `iid`)
- `timestamp`: `playdate.getTime()`
- `version`: `"2.0-LDTK"`

The logic for which fields to save/restore per entity type (Brocorat, PropItem, CrewMember, Trigger, NPC, Items) is identical — only the storage backend changes.

### Love2D equivalent

```lua
-- SaveSystem.lua (Love2D)
local json = require("libs/json")
local SaveSystem = {}

local SAVE_FILE = "gameState.json"

function SaveSystem.save(PlayerData, levelsLDTK)
    local saveData = {
        player     = PlayerData,
        levelState = SaveSystem.getLevelState(levelsLDTK),
        timestamp  = os.time(),
        version    = "2.0-LDTK"
    }
    local encoded = json.encode(saveData)
    local success, err = love.filesystem.write(SAVE_FILE, encoded)
    return success
end

function SaveSystem.load(levelsLDTK)
    if not love.filesystem.getInfo(SAVE_FILE) then
        return false, nil
    end
    local content = love.filesystem.read(SAVE_FILE)
    local saveData = json.decode(content)
    if saveData and saveData.version == "2.0-LDTK" then
        SaveSystem.restoreLevelState(saveData.levelState, levelsLDTK)
        return true, saveData.player
    end
    return false, nil
end

function SaveSystem.delete()
    love.filesystem.remove(SAVE_FILE)
end
```

The `getLevelState()` and `restoreLevelState()` functions are **identical to the original** in `SaveSystem.lua` — only the read/write layer changes. The entity matching by `iid` and the conditional fields (dead, destroyed, isTaken, usedTrigger, collected, hasGranted) require no changes.

### Note on love.filesystem

`love.filesystem` can only write to `love.filesystem.getSaveDirectory()`. Game images and assets are accessed from the executable directory. The save file will automatically live in the OS-specific user data folder.

---

## 9. DanceScene in Love2D

### How the original rhythm system works

- Each `ButtonPress` is a sprite that moves from right to left at speed `bpm` (this is actually a step count, not musical BPM: `Config.Dance.basic.bpm = 16` screen steps)
- `HitZone` is a static sprite at position x=40. When a `ButtonPress` is in that zone (`hitzone:overlappingSprites()`), a hit window opens
- The player registers which button was pressed in `DanceScene.ButtonPressed`
- In `update()`, if there is a collision and `ButtonPressed` matches the `buttonKey` of the ButtonPress: successful hit → `balancePosition += accuracy`
- `balancePosition` is an integer ranging from `-balanceMaxOffset` to `+balanceMaxOffset`. Reaching either extreme results in a win or a loss
- Difficulty is determined by `determineDifficultyUpgrade()` using weighted sanity, powerLevel, and calories

### Love2D implementation

```lua
-- DanceScene.lua (Love2D)
local DanceScene = {}

-- Difficulty configuration (identical to Config.Dance)
local DIFFICULTY = {
    basic  = { speed = 16, buttons = 4  },
    evolve = { speed = 24, buttons = 6  },
    badass = { speed = 28, buttons = 8  },
    boss   = { speed = 32, buttons = 12 },
}

local HIT_ZONE_X    = 40    -- X position of the hit zone
local HIT_ZONE_W    = 20    -- Hit window width (tolerance)
local BUTTON_START  = 400   -- Initial button position (off-screen right)
local BUTTON_STEP   = 80    -- Spacing between buttons

function DanceScene:enter(params)
    self.enemyType      = params.enemyType or "basic"
    local diff          = DIFFICULTY[self.enemyType]
    self.buttonSpeed    = diff.speed       -- px per frame at 50fps
    self.numberOfButtons= diff.buttons

    self.balancePos     = 0
    self.balanceMax     = 50              -- equivalent to self.enemyHP
    self.ButtonPressed  = nil
    self.accuracy       = 0
    self.totalAccuracy  = 0
    self.isDancing      = false
    self.condition      = nil

    -- Create buttons
    self.buttons = {}
    local patterns = {"left", "right", "up", "down", "a", "b"}
    for i = 1, self.numberOfButtons do
        table.insert(self.buttons, {
            x       = BUTTON_START + (i-1) * BUTTON_STEP,
            y       = 30,
            key     = patterns[math.random(#patterns)],
            hit     = false,
            visible = true,
        })
    end
end

function DanceScene:update(dt)
    if not self.isDancing then return end

    -- Move buttons from right to left
    for _, btn in ipairs(self.buttons) do
        if not btn.hit then
            btn.x = btn.x - self.buttonSpeed * dt * 50  -- scale to 50fps
        end
    end

    -- Detect buttons in the hit zone
    for _, btn in ipairs(self.buttons) do
        if not btn.hit and math.abs(btn.x - HIT_ZONE_X) <= HIT_ZONE_W then
            if self.ButtonPressed == nil then
                -- Button in zone but not pressed: penalize
                self.accuracy = self.accuracy + 1
                if self.accuracy > 5 then
                    self.balancePos = self.balancePos - 0.3
                end
            elseif self.ButtonPressed == btn.key then
                -- Correct hit
                self.balancePos    = self.balancePos + self.accuracy
                self.totalAccuracy = self.totalAccuracy + self.accuracy
                btn.hit = true
            else
                -- Wrong button
                self.balancePos = self.balancePos - 5
                btn.hit = true
            end
            self.ButtonPressed = nil
            break  -- only process one button per frame
        elseif btn.x < HIT_ZONE_X - HIT_ZONE_W then
            self.accuracy = 0  -- reset accuracy when button exits the zone
        end
    end

    -- Clamp balance
    self.balancePos = math.max(-self.balanceMax, math.min(self.balanceMax, self.balancePos))

    -- Check win/lose
    if self.balancePos >= self.balanceMax then
        self:win()
    elseif self.balancePos <= -self.balanceMax then
        self:lose()
    end
end

function DanceScene:draw()
    -- Hit zone (equivalent to the HitZone sprite)
    love.graphics.setColor(1, 1, 0, 0.5)
    love.graphics.rectangle("fill", HIT_ZONE_X - HIT_ZONE_W/2, 20, HIT_ZONE_W, 20)

    -- Buttons
    for _, btn in ipairs(self.buttons) do
        if not btn.hit then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(btn.key, btn.x, btn.y)
        end
    end

    -- Balance bar
    local barX = 200 + self.balancePos
    love.graphics.setColor(1, 0.5, 0, 1)
    love.graphics.rectangle("fill", barX - 4, 56, 8, 10)
    love.graphics.setColor(1, 1, 1, 1)
end

function DanceScene:keypressed(key)
    -- Canonical key mapping (see section 3.1)
    local keyMap = {
        left  = "left",
        right = "right",
        up    = "up",
        down  = "down",
        z     = "a",   -- Z key = A button
        x     = "b",   -- X key = B button
    }
    if keyMap[key] then
        self.ButtonPressed = keyMap[key]
    end
end
```

### Difficulty calculation

The `determineDifficultyUpgrade()` function uses weights from the original `Config.Dance`. It ports without changes — it only needs to receive `PlayerData.sanityCounter`, `PlayerData.EnemiesData.powerLevel`, and `PlayerData.calories`.

---

## 10. Implementation Priority

An ordered list to get a functional prototype as quickly as possible:

### Stage 1 — Foundation (no gameplay)

1. **Scene Manager** with fade between scenes
   - Empty `TitleScene`, empty `MazeScene`
   - Basic keyboard/gamepad input

2. **Load levels.lua** and build `roomsByIid`
   - Verify all rooms load correctly
   - Equivalent `RoomTranslate()` (returns the scene class by number)

3. **bump.lua world + tile colliders**
   - `createTileColliders()` from `tileMapData`
   - Visualize colliders in debug mode

### Stage 2 — Movement and navigation

4. **Player movement**
   - Player sprite with anim8
   - `movePlayer()` with bump filters
   - Base speed `Config.Player.speed = 2` px per frame
   - Turn-based sync: `isActive` flag

5. **Door transitions**
   - Door sprites at positions from `Config.Doors.positions`
   - `Door:goTo()` → `SceneManager.transition(nextRoom, params)`
   - `Door:prevRoom()` → update `PlayerData.playerSpawn`

### Stage 3 — Entities and combat

6. **Enemy AI (Brocorat)**
   - `blindSearch()` — move toward the player
   - `linealSearch()` — move only when aligned
   - Token system: `addMovementFrames()` / `movementFrames` counter
   - Blind state by frames

7. **Combat → DanceScene**
   - Player–enemy collision triggers `fight()`
   - `PlayerData.lastEnemyTouched` to pass to DanceScene
   - Full DanceScene (see section 9)
   - Win: `findAndKillEnemyById()`, return to MazeScene
   - Lose: go to TitleScene / DeadScene

### Stage 4 — Progression and persistence

8. **Save system**
   - `love.filesystem` + json.lua
   - Same structure as `SaveSystem.lua`
   - Backup of original `levelsLDTK` at startup

9. **HUD**
   - Battery, sanity, and lives bars
   - Update from `PlayerData` every frame

### Stage 5 — FX and polish

10. **Lighting FX**
    - `FXshadow` with canvas + stencil (see section 7)
    - Only activate in rooms where `customFields.shadow == true`
    - Directional light cone based on `PlayerData.direction`

---

## 11. Recommended Dependencies

### Collisions
- **bump.lua** (kikito) — AABB collisions with slide/cross/bounce/touch responses. Exactly what the game needs.

### Animations
- **anim8** (kikito) — spritesheet animations with named states, a direct equivalent of `animation:addState()` / `setState()`.

### Tilemaps (optional)
- **STI (Simple Tiled Implementation)** — loads `.tmx` files (Tiled). Only useful if re-exporting from LDtk to Tiled. For this game, loading `levels.lua` directly is simpler.
- **ldtk-love** — loads `.ldtk` files natively. An alternative if you want to avoid manual re-export to Lua.

### Serialization (saves)
- **json.lua** (rxi) — pure Lua JSON encode/decode. No extra dependencies. Directly replaces `playdate.datastore`.

### Transitions and tweening
- **flux** (rxi) — tweening with easing, similar to `Sequence.new():from(0):to(50, 1.5, Ease.outBounce)`. Syntax: `flux.to(obj, 1.5, {x=50}):ease("outbounce")`.
- Alternative: **tween.lua** (kikito).

### Optional utilities
- **lume** (rxi) — Lua utilities (clamp, lerp, round, shuffle) that replace Noble Engine helpers.

---

## 12. Important Differences and Pitfalls

### The crank maps to Q and E

The Playdate crank is unique hardware, but this game uses it only as a binary direction signal (no speed sensitivity). It maps cleanly to two keys:

- **E** = clockwise (increase): charge battery in normal play; grow inside minifier when tiny
- **Q** = counterclockwise (decrease): shrink inside minifier when not tiny; no effect otherwise

See section 3.1 for the complete canonical mapping and section 3.3 for the implementation. Do not use mouse wheel — the feel of Q/E repeated presses matches the original crank rhythm exactly.

### isActive and turn-based sync

The `PlayerData.isActive` flag is central: enemies only move when the player moves. In Love2D, preserve this logic exactly. Enemies consume `movementFrames` that the player distributes with `distributeMovementFrames(3)` on each move. Do not switch to dt-based updates without understanding that doing so breaks the turn-based movement design.

### Player collision resolution

The Player on Playdate has three `collideRect` values depending on state:
- Normal: `{x=8, y=24, w=30, h=24}` — note it is offset, not the full sprite
- Tiny: `{x=19, y=32, w=10, h=10}` — much smaller
- Head: `{x=8, y=8, w=16, h=16}` — head only

In bump.lua, when switching state (shrink/grow), call `world:update(player, px, py, newW, newH)`.

### Playdate collision groups use numbers; bump.lua uses strings

Original:
```lua
self:setGroups(CollideGroups.enemy)     -- number 2
self:setCollidesWithGroups({CollideGroups.player})  -- number 1
```

In bump.lua the type is a field on the object table:
```lua
enemy.type = "enemy"
-- The filter receives col.other.type to make decisions
```

### NeighbourLevels includes diagonals ("nw", "ne", "sw", "se")

The `ConvertLDTKDirection()` code only maps the pure cardinal directions (n, s, e, w) and stairs (>, <). Diagonals appear in `neighbourLevels` from LDtk but do not generate doors — they are adjacency information only. Do not attempt to create diagonal doors.

### Floors.lua generates dynamic classes

The game uses `_G["Floor408"]` to get the scene class for a room. In Love2D this can be replicated with a registry table:

```lua
-- scenes/Floors.lua (Love2D)
Floors = {}

-- Generate entries for all room ranges
local ranges = {
    {from=166, to=180},
    {from=231, to=274},
    {from=316, to=330},
    {from=401, to=415},
}

for _, range in ipairs(ranges) do
    for i = range.from, range.to do
        local level = math.floor(i / 100)
        local room  = i % 100
        Floors[i] = {
            level = level,
            room  = room,
            sceneClass = MazeScene,  -- all rooms use MazeScene
        }
    end
end

function RoomTranslate(roomNumber)
    return Floors[roomNumber]
end
```
