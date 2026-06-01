# CreditsScene — Scrolling Credits

**File**: `scenes/CreditsScene.lua`
**Assets**: `assets/credits/credits-kenney.png`, `assets/credits/credits-tangara.png`

A credits scene with automatic vertical scrolling. Reached from TitleScene via the "Credits" menu item, or upon completing the `1→3→2→4` sequence in CockpitScene. Automatically returns to TitleScene when the scroll finishes; Button B cancels at any time.

Background: `Graphics.kColorBlack`. Text in white. Images with `kDrawModeCopy`.

---

## Layout Constants

| Constant | Value | Purpose |
|---|---|---|
| `SCROLL_SPEED` | 1 px/frame | Normal scroll speed |
| `SCROLL_SPEED_FAST` | 3 px/frame | Fast speed (while A is held) |
| `LINE_HEIGHT` | 20 px | Reserved height for a `text` item |
| `ITEM_SPACING` | 16 px | Vertical gap between consecutive items |
| `START_OFFSET` | 260 px | Initial Y of the first item (just below the screen's bottom edge at 240) |

---

## Scroll System

The scroll operates on a `scrollY` coordinate that increments every frame. The rendering Y position of the first item is:
```
y = START_OFFSET - scrollY
```
As `scrollY` grows, `y` decreases, causing items to scroll up the screen.

**Speed**: each frame in `update()`:
```lua
local speed = isHoldingA and SCROLL_SPEED_FAST or SCROLL_SPEED
scrollY = scrollY + speed
```

**Fast scroll (A held)**: `isHoldingA` is set in `AButtonDown` and cleared in `AButtonUp`. Speed changes from 1 to 3 px/frame for the duration of the press.

**End detection**: when all content has scrolled off the top edge:
```lua
if not isDone and scrollY >= START_OFFSET + totalHeight then
    isDone = true
    Noble.transition(TitleScene)
end
```
`isDone` is a boolean guard so that `Noble.transition` is called exactly once even if the condition is met over multiple frames.

**Coordinate system**: Y=0 is the top edge of the screen, Y=240 the bottom. Items start off-screen below (Y≈260) and scroll upward (decreasing Y). An item is visible when `y + h >= 0 and y <= 240`.

---

## Item Types

The `credits` table defines content as a flat list of items. Three supported types:

### `{ type = "text", value = "string" }`
- Height: `LINE_HEIGHT = 20` px.
- Rendering: `Graphics.drawTextAligned(value, 200, y, kTextAlignment.center)` with mode `kDrawModeFillWhite`.
- White text horizontally centered at x=200.

### `{ type = "image", path = "assets/..." }`
- Height: the actual height of the loaded image (`img:getSize()` second return value). If the image could not be loaded, height = 0.
- Rendering: `img:draw(200 - w//2, y)` with mode `kDrawModeCopy` — horizontally centered.
- The path is relative to the `source/` directory.

### `{ type = "space", height = N }`
- Height: `N` px (the `height` field).
- No rendering — a blank vertical gap between other items.

The `ITEM_SPACING = 16` px separator is added automatically between all items (including between the last item and the end). There is no need to add a `space` entry for basic separation.

---

## Image Preload Strategy

All images are loaded in `enter()` before scrolling begins:

```lua
for _, item in ipairs(credits) do
    if item.type == "image" and not loadedImages[item.path] then
        local img = Graphics.image.new(item.path)
        if img then
            loadedImages[item.path] = img
        else
            printDebug("Credits: image not found:", item.path)
        end
    end
end
```

Images are stored in `loadedImages[path]` (local table, keyed by path string). `drawBackground()` never reads from disk during gameplay — it only queries `loadedImages`. This prevents I/O hitches during scrolling.

**Memory release**: in `exit()` `loadedImages = {}` is assigned, discarding all references.

**Note on `Graphics.sprite.redrawBackground()`**: in `enter()` an explicit redraw is forced because CreditsScene has no sprites of its own. Without sprites, the Playdate system does not generate dirty regions to trigger `drawBackground`, so the black background would not be applied on the first frame.

---

## `totalHeight` Calculation

In `enter()`, after preloading:
```lua
totalHeight = 0
for i, item in ipairs(credits) do
    totalHeight = totalHeight + itemHeight(item)
    if i < #credits then
        totalHeight = totalHeight + ITEM_SPACING
    end
end
```
`itemHeight(item)` returns `LINE_HEIGHT` for text, the image height for image, and `item.height` for space. `totalHeight` is the sum of all item heights plus all `ITEM_SPACING` values between items (not after the last). Used exclusively for the scroll end condition.

---

## Scene Lifecycle

### `init()`
Only calls `scene.super.init`. No additional logic.

### `enter()`
1. Resets state: `scrollY = 0`, `isHoldingA = false`, `loadedImages = {}`, `isDone = false`.
2. Forces `Graphics.sprite.redrawBackground()` to apply the black background immediately.
3. Preloads images (see previous section).
4. Calculates `totalHeight`.

### `update()`
1. Advances `scrollY` by the active speed.
2. Calls `Graphics.sprite.redrawBackground()` to force `drawBackground` every frame (required when there are no own sprites).
3. Checks the end condition with the `isDone` guard.

### `drawBackground()`
```lua
local y = START_OFFSET - scrollY
for _, item in ipairs(credits) do
    local h = itemHeight(item)
    if y + h >= 0 and y <= 240 then
        -- render based on type
    end
    y = y + h + ITEM_SPACING
end
```
Iterates all items while maintaining the accumulated Y position. The visibility check `y + h >= 0 and y <= 240` avoids unnecessary calculations for off-screen items.

### `exit()`
Clears `loadedImages = {}` to release image memory.

### `finish()`
Resets `Graphics.setImageDrawMode(Graphics.kDrawModeCopy)` to clean up state for the next scene.

---

## Input

| Input | Effect |
|---|---|
| Hold A | 3× scroll speed (SCROLL_SPEED_FAST) |
| Button B | Returns immediately to TitleScene (`Noble.transition(TitleScene)`) |
| Auto | Returns to TitleScene when scroll completes |

---

## Credits Data (actual content)

Order from top to bottom as they appear while scrolling:

| # | Type | Content |
|---|---|---|
| 1 | space | 20 px |
| 2 | text | "DinoPirates from Inner Space" |
| 3 | text | "Brocolation" |
| 4 | space | 30 px |
| 5 | text | "A game by" |
| 6 | space | 8 px |
| 7 | text | "Sebastian Andres Guillermo Zuniga Rivas" |
| 8 | text | "A.K.A" |
| 9 | text | "dactrtr.rocks" |
| 10 | space | 30 px |
| 11 | text | "Music" |
| 12 | space | 8 px |
| 13 | text | "Alan Muñoz" |
| 14 | space | 30 px |
| 15 | text | "Cursor pack and Input Prompts Pixel 1-Bit by:" |
| 16 | image | `assets/credits/credits-kenney.png` |
| 17 | space | 30 px |
| 18 | text | "Special thanks to:" |
| 19 | space | 8 px |
| 20 | text | "Jacob Wilschrey - Dev help" |
| 21 | text | "Christian Padilla - Game test" |
| 22 | space | 8 px |
| 23 | text | "This game wouldnt been possible " |
| 24 | text | "without the support and love of" |
| 25 | text | "Jenna Heo" |
| 26 | space | 40 px |
| 27 | text | "Thanks for playing!" |
| 28 | space | 80 px |
| 29 | image | `assets/credits/credits-tangara.png` |
| 30 | space | 60 px |

To modify the content, edit the `credits` table at the top of `CreditsScene.lua`. No changes to any other file are required.

---

## Notes — Differences from Love2D / Non-Playdate Environments

- `Graphics.sprite.redrawBackground()` forces a background redraw in Playdate. In Love2D this concept does not exist: `love.draw()` runs every frame regardless. Remove these calls in a port.
- `Graphics.drawTextAligned()` with `kTextAlignment.center` is equivalent to `love.graphics.printf(text, x - width/2, y, width, "center")`.
- `Graphics.setImageDrawMode(Graphics.kDrawModeFillWhite)` has no direct equivalent in Love2D; in Playdate it draws the image shape in white regardless of the original color. In Love2D use `love.graphics.setColor(1,1,1)` before `img:draw()`.
- `img:draw(x, y)` in Playdate draws from the top-left corner. `love.graphics.draw(img, x, y)` works the same way.
- `Graphics.image.new(path)` in Playdate automatically searches in `source/`. In Love2D use `love.graphics.newImage(path)`.
- `Noble.transition(TitleScene)` is Noble Engine-specific. In Love2D it is equivalent to switching the active game state.
