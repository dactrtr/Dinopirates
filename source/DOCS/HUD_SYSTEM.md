# HUD System

This document describes all player HUD elements: their on-screen position, update logic, the `PlayerData` fields each one reads, and portability notes.

---

## Overview

The HUD is composed of the following elements:

| Class | File | Description |
|---|---|---|
| `playerHud` | `entities/UI/playerHud.lua` | Main container; follows the player |
| `Battery` | `entities/UI/battery.lua` | Battery bar |
| `HealthIndicator` | `entities/UI/healthIndicator.lua` | Health points |
| `sanityHud` | `entities/UI/sanityHud.lua` | Sanity indicator (independent) |
| `keyHud` | `entities/UI/keyHud.lua` | Key indicator (independent) |
| `UIHud` | `entities/UI/UIHud.lua` | Contextual interaction indicator |

---

## `playerHud` — Main Container

Extends `NobleSprite`. Base image: `assets/images/ui/UIHud`.

### On-Screen Position

The HUD follows the player every frame in `update()`:

```
normal position: (player.x, player.y - 36)
isTiny mode:     (player.x, player.y - 22)
```

`Battery` is positioned 3 pixels above the container:
```
Battery: (player.x, player.y - 39)  -- normal
Battery: (player.x, player.y - 25)  -- isTiny
```

`HealthIndicator` shares position with the container:
```
HealthIndicator: (player.x, player.y - 36)  -- normal
```

### Layer Z-Index

| Element | Z-Index |
|---|---|
| `playerHud` (background) | `ZIndex.hud` (2000) |
| `Battery` | `ZIndex.hud + 1` (2001) |
| `HealthIndicator` | `ZIndex.hud + 2` (2002) |

### Visibility — Requires `hasDWatch`

The full HUD (background, battery, health) is only visible when `PlayerData.items.hasDWatch == true`. Without the D-Watch, all three elements are hidden with `setVisible(false)`.

### Animation States — Sanity

The HUD background image changes based on `PlayerData.sanity`:

| Animation State | Frames | Condition |
|---|---|---|
| `sanity100` | 1–1 | `sanity > 80` |
| `sanity80` | 3–4 | `sanity > 60` |
| `sanity60` | 5–6 | `sanity > 40` |
| `sanity40` | 7–9 | `sanity > 20` |
| `sanity20` | 10–11 | `sanity > 0` |
| `sanity0` | 12–13 | `sanity == 0` |

Frame duration: 12.

### `PlayerData` Fields Read

| Field | Purpose |
|---|---|
| `PlayerData.items.hasDWatch` | Controls visibility of the entire HUD |
| `PlayerData.sanity` | Selects the background animation state |
| `PlayerData.isTiny` | Adjusts the HUD Y offset |

### Lifecycle

- Instantiated in `MazeScene:enter()` after the player is created.
- `playerHud:removeAll()` removes Battery, HealthIndicator, and the sprite itself when leaving a room.

---

## `Battery` — Battery Bar

Extends `Graphics.sprite` (native Playdate sprite, no Noble).

### How It Works

Each frame it draws a 27×2 px image where the filled width is proportional to the battery:

```lua
local fillWidth = 27
local batteryPercent = (PlayerData.battery * fillWidth) / 100
-- fillWidth = 27 px → full battery
-- 0 px → empty battery
```

Draws a black rectangle of 27×2 px on a `Graphics.image.new(27, 2)` using `pushContext`.

### Update Condition

Only updates the image when `PlayerData.items.hasLamp == true` OR `PlayerData.items.hasBoots == true`. If the player has neither, nothing is drawn.

### `PlayerData` Fields Read

| Field | Purpose |
|---|---|
| `PlayerData.battery` | Value 0–100 to calculate bar width |
| `PlayerData.items.hasLamp` | Activates indicator update |
| `PlayerData.items.hasBoots` | Activates indicator update |

---

## `HealthIndicator` — Health Points

Extends `Graphics.sprite`.

### How It Works

Draws a 2×3 px rectangle for each health point at predefined X positions:

```lua
local xPositions = {4, 5, 10, 11, 16, 17, 22, 23, 28, 29}
local yPos = 8
local spotWidth = 2
local spotHeight = 3
-- A rect is drawn at xPositions[i], yPos for each i = 1..healthPoints
```

Supports up to 10 health points. With the default value of 3, only the first 3 rectangles are drawn.

The image is regenerated only when `PlayerData.healthPoints` changes relative to the previous frame.

### Canvas Size

35×15 px — same as `playerHud` for correct alignment.

### `PlayerData` Fields Read

| Field | Purpose |
|---|---|
| `PlayerData.healthPoints` | Number of squares to draw (0–10) |

---

## `sanityHud` — Sanity Indicator

Extends `NobleSprite`. Base image: `assets/images/ui/sanity.png`.

This sprite is **independent** of `playerHud`. It is not instantiated inside `playerHud:init()` — it is created separately wherever needed.

### Size

17×12 px.

### Animation States

| State | Frames | Condition |
|---|---|---|
| `good` | 1–2 | `sanity >= 80` |
| `normal` | 3–4 | `sanity >= 50` |
| `mediocre` | 5–6 | `sanity >= 30` |
| `insane` | 7–8 | `sanity < 30` |

Frame duration: 12.

### `PlayerData` Fields Read

| Field | Purpose |
|---|---|
| `PlayerData.sanity` | Selects the animation state |

---

## `keyHud` — Key Indicator

Extends `Graphics.sprite`.

This sprite is **independent** of `playerHud`. Although `playerHud.lua` imports it, it never instantiates it. It is created separately in the scene.

### How It Works

Displays the image `assets/images/ui/key.png` when the player has the key, and `nil` (empty image) when they do not:

```lua
function keyHud:update()
    if PlayerData.hasKey == false then
        self:setImage(nil)
    else
        self:setImage(keyIndicator)
    end
end
```

### `PlayerData` Fields Read

| Field | Purpose |
|---|---|
| `PlayerData.hasKey` | Shows or hides the key icon |

---

## `UIHud` — Contextual Interaction Indicator

Extends `NobleSprite`. Base image: `assets/images/ui/interaction.png`.

Displays visual interaction hints to the player (press A, turn the crank, etc.). Positioned at `(player.x + 30, player.y - 30)` and invisible by default.

### Available Animation States

| State | Frames | Description |
|---|---|---|
| `pressA` | 1–6 | Press button A |
| `ring` → `ring5` | 7–8 | Ring sequence (5 chained stages) |
| `answer` | 9–14 | Answer call |
| `crankAntiClock` | 15–18 | Turn crank counter-clockwise |
| `crankClock` | 19–22 | Turn crank clockwise |
| `Investigate` | 23–28 | Investigate object |

Frame duration: 6 (interaction) or 3 (ring).

### Public API

```lua
UIHud:setPressA()         -- shows "press A"
UIHud:setRing()           -- starts ring sequence
UIHud:setCrankClock()     -- shows "turn crank clockwise"
UIHud:setCrankAntiClock() -- shows "turn crank counter-clockwise"
UIHud:setInvestigate()    -- shows "investigate"
```

### Z-Index

`ZIndex.ui` (2000) — same layer as the main HUD.

Does not read `PlayerData` fields directly; it is controlled externally by scene logic.

---

## Notes for Porting to Love2D

### HUD as Screen Layer

In Love2D, the HUD is drawn at the end of `love.draw()` without a camera transform:

```lua
function love.draw()
    -- Game world with camera
    camera:push()
    drawWorld()
    camera:pop()

    -- HUD in screen space (no camera)
    if PlayerData.items.hasDWatch then
        local yOffset = PlayerData.isTiny and -22 or -36
        local hx = player.screenX   -- player screen coordinates
        local hy = player.screenY + yOffset
        drawHudBackground(hx, hy, PlayerData.sanity)
        drawBattery(hx, hy - 3, PlayerData.battery)
        drawHealth(hx, hy, PlayerData.healthPoints)
    end
end
```

### Battery Bar

```lua
function drawBattery(x, y, battery)
    local fillW = math.floor((battery * 27) / 100)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", x, y, fillW, 2)
end
```

### Health Indicator

```lua
local xPositions = {4, 5, 10, 11, 16, 17, 22, 23, 28, 29}
function drawHealth(x, y, hp)
    love.graphics.setColor(0, 0, 0)
    for i = 1, math.min(hp, 10) do
        love.graphics.rectangle("fill", x + xPositions[i], y + 8, 2, 3)
    end
end
```

### Sanity → Image Variant

```lua
local function getSanityState(sanity)
    if sanity >= 80 then return "sanity100"
    elseif sanity >= 60 then return "sanity80"
    elseif sanity >= 40 then return "sanity60"
    elseif sanity >= 20 then return "sanity40"
    elseif sanity > 0  then return "sanity20"
    else return "sanity0" end
end
```
