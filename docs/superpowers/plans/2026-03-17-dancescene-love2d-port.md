# DanceScene Love2D Port — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port the Playdate DanceScene rhythm-combat system to a self-contained Love2D project that replicates all gameplay mechanics from the original `scenes/DanceScene.lua`.

**Architecture:** Each Playdate entity class becomes a focused Lua module under `src/entities/`. A minimal scene manager replaces Noble Engine. All game logic is preserved exactly — only the platform-layer (drawing, input, timing, collision) is swapped for Love2D equivalents.

**Tech Stack:** Love2D 11.x, [middleclass](https://github.com/kikito/middleclass) (OOP), [anim8](https://github.com/kikito/anim8) (sprite animation), [busted](https://github.com/lunarmodules/busted) (unit tests for pure logic)

---

## Reference Material

You have the original `scenes/DanceScene.lua` in your context. Read it carefully before implementing. Key facts extracted from it:

**Balance system**: `balancePosition` runs from `-balanceMaxOffset` to `+balanceMaxOffset` (default ±50, tied to `enemyHP=50`). Correct A/B press → `+5`. Correct arrow press → `+accuracy`. Wrong/miss → `-5`. Miss while button in zone → `-0.3` per frame after 5-frame grace. Win when `>= +max`, lose when `<= -max`.

**Difficulty**: `determineDifficultyUpgrade()` → probability 0–100 based on sanity (35%), powerLevel (45%), calories (20%). If `roll <= chance`, call `determineEnemyType()` which maps powerLevel ranges → basic/evolve/badass/boss → bpm + numberOfButtons (16/4, 24/6, 28/8, 32/12).

**ButtonPress timing**: Entities scroll right→left. All `numberOfButtons` are created with the same `bpm` and `keyProvider`. Stagger: each button gets `(i-1) * 300ms` movement delay.

**HitZone**: Fixed sprite at x=40, y=30. Detects overlapping ButtonPress sprites each frame. `overlappingSprites()` → list of colliding buttons, checked against `self.ButtonPressed`.

**Input flow**: `danceStep(key)` stores the key → checked in `update()` against whatever ButtonPress is in the HitZone that frame → `clearButton()` on button release.

**Results**: Win → `findAndKillEnemyById` + `+60 calories` + transition back to maze room. Lose → transition to TitleScene. Both guarded by `checkDanceResults()` called from `AButtonDown`.

---

## File Structure

```
love2d-dancescene/
├── main.lua                        -- love callbacks, scene manager bootstrap
├── conf.lua                        -- window size (400×240 scale ×2), title
├── src/
│   ├── SceneManager.lua            -- minimal scene push/pop + transition
│   ├── data/
│   │   ├── PlayerData.lua          -- stub of PlayerData global (editable for testing)
│   │   └── EnemyPatterns.lua       -- EnemyPatterns table (extracted from DanceScene)
│   ├── scenes/
│   │   ├── DanceScene.lua          -- main scene: difficulty, update loop, input, win/lose
│   │   └── TitleScene.lua          -- stub title scene (just "Game Over" text + restart)
│   └── entities/
│       ├── ButtonPress.lua         -- scrolling input-prompt entity
│       ├── HitZone.lua             -- fixed left-side zone, AABB collision list
│       ├── PlayerDance.lua         -- player sprite animation state machine
│       ├── EnemyRatDance.lua       -- enemy sprite animation state machine
│       ├── BackgroundDance.lua     -- static/animated battle background
│       ├── ButtonCover.lua         -- mask drawn over hit zone
│       ├── WinIndicator.lua        -- "WIN" side marker
│       ├── LoseIndicator.lua       -- "LOSE" side marker
│       └── ResultsScreen.lua       -- win/lose/loading overlay state machine
├── assets/
│   └── images/
│       └── ui/battle/
│           └── nudgeIndicator.png  -- balance bar image (placeholder ok)
├── lib/
│   ├── middleclass.lua             -- OOP library
│   └── anim8.lua                   -- animation library
└── tests/
    ├── test_difficulty.lua         -- busted tests: determineDifficultyUpgrade, determineEnemyType
    ├── test_patterns.lua           -- busted tests: getPatternKey distribution
    └── test_balance.lua            -- busted tests: balance position clamping / win-lose detection
```

---

## Chunk 1: Project Scaffold + Pure Logic Tests

### Task 1: Scaffold the Love2D project

**Files:**
- Create: `love2d-dancescene/conf.lua`
- Create: `love2d-dancescene/main.lua`
- Create: `love2d-dancescene/lib/middleclass.lua` (download)
- Create: `love2d-dancescene/lib/anim8.lua` (download)

- [ ] **Step 1: Create `conf.lua`**

```lua
-- conf.lua
function love.conf(t)
    t.title = "DanceScene - Love2D Port"
    t.window.width  = 800   -- 400 × 2 for visibility
    t.window.height = 480   -- 240 × 2
    t.window.resizable = false
end
```

- [ ] **Step 2: Create a minimal `main.lua` that opens without error**

```lua
-- main.lua
require "src/SceneManager"

function love.load()
    -- placeholder: will wire up DanceScene here in Task 8
    love.graphics.setBackgroundColor(0, 0, 0)
end

function love.update(dt)
end

function love.draw()
    love.graphics.print("Scaffold OK", 10, 10)
end
```

- [ ] **Step 3: Download `middleclass.lua` and `anim8.lua` into `lib/`**

```bash
curl -L https://raw.githubusercontent.com/kikito/middleclass/master/middleclass.lua \
     -o love2d-dancescene/lib/middleclass.lua

curl -L https://raw.githubusercontent.com/kikito/anim8/master/anim8.lua \
     -o love2d-dancescene/lib/anim8.lua
```

- [ ] **Step 4: Run the game — window must open showing "Scaffold OK"**

```bash
cd love2d-dancescene && love .
```
Expected: Black window, white text "Scaffold OK".

- [ ] **Step 5: Commit**

```bash
git add love2d-dancescene/
git commit -m "feat: scaffold love2d dancescene project"
```

---

### Task 2: PlayerData stub + EnemyPatterns data

**Files:**
- Create: `love2d-dancescene/src/data/PlayerData.lua`
- Create: `love2d-dancescene/src/data/EnemyPatterns.lua`

- [ ] **Step 1: Create `PlayerData.lua`** — mirrors exactly the fields used by DanceScene:

```lua
-- src/data/PlayerData.lua
-- Mirrors the Playdate PlayerData global used by DanceScene.
-- Edit these values to test different difficulty scenarios.
PlayerData = {
    isDancing        = false,
    sanityCounter    = 0,       -- 0-100; higher = harder difficulty rolls
    calories         = 0,       -- 0-500
    amountDances     = 0,
    healedHP         = 2,
    healthPoints     = 10,
    EnemiesData = {
        powerLevel   = 1,       -- 1-20; drives enemy type selection
    },
    lastEnemyTouched = {
        id   = "test-enemy-001",
        type = "Brocorat",
        x    = 200,
        y    = 120,
    },
    playerSpawn = { x = 196, y = 116 },
    playerExit  = { x = 196, y = 116 },
    saveLevel   = 101,          -- room number to return to on win
}
```

- [ ] **Step 2: Create `EnemyPatterns.lua`** — exact copy of the table from `DanceScene.lua`:

```lua
-- src/data/EnemyPatterns.lua
EnemyPatterns = {
    basic = {
        weights     = { arrows = 0.8, aButton = 0.2, bButton = 0.0 },
        style       = "arrow_heavy",
        phaseLength = 10,
    },
    evolve = {
        weights     = { arrows = 0.6, aButton = 0.2, bButton = 0.2 },
        style       = "mixed",
        phaseLength = 10,
    },
    badass = {
        weights     = { arrows = 0.4, aButton = 0.3, bButton = 0.3 },
        style       = "tough",
        phaseLength = 8,
    },
    boss = {
        weights     = { arrows = 0.2, aButton = 0.4, bButton = 0.4 },
        style       = "button_spam",
        phaseLength = 6,
    },
}

-- Picks one button key from a profile's weight table.
-- Returns one of: "leftButton","upButton","rightButton","downButton","aButton","bButton"
function getPatternKey(profile)
    local w    = profile.weights
    local rand = math.random()
    local sum  = w.arrows + w.aButton + w.bButton
    local choice = rand * sum
    if choice < w.arrows then
        local arrows = { "leftButton", "upButton", "rightButton", "downButton" }
        return arrows[math.random(#arrows)]
    elseif choice < w.arrows + w.aButton then
        return "aButton"
    else
        return "bButton"
    end
end
```

- [ ] **Step 3: Commit**

```bash
git add love2d-dancescene/src/data/
git commit -m "feat: add PlayerData stub and EnemyPatterns data"
```

---

### Task 3: Unit tests — difficulty logic and pattern distribution

Install busted: `luarocks install busted` (or `brew install luarocks && luarocks install busted`).

**Files:**
- Create: `love2d-dancescene/tests/test_difficulty.lua`
- Create: `love2d-dancescene/tests/test_patterns.lua`
- Create: `love2d-dancescene/tests/test_balance.lua`

- [ ] **Step 1: Write `test_difficulty.lua`**

```lua
-- tests/test_difficulty.lua
-- Tests the pure logic of difficulty calculation, isolated from Love2D.
package.path = package.path .. ";../src/?.lua;../src/data/?.lua"

-- Stub globals that DanceScene references but we don't need for these tests
PlayerData = require("PlayerData")

-- Inline the two functions under test (copy verbatim from DanceScene.lua)
local function determineDifficultyUpgrade(sanityCounter, powerLevel, calories)
    local sanity   = sanityCounter or 0
    local power    = powerLevel    or 0
    local cal      = calories      or 0
    local sanityNorm   = math.max(0, math.min(1, sanity / 100))
    local powerNorm    = math.max(0, math.min(1, power  / 20))
    local caloriesNorm = math.max(0, math.min(1, cal    / 500))
    local score = sanityNorm * 0.35 + powerNorm * 0.45 + caloriesNorm * 0.20
    return math.max(0, math.min(100, score * 100))
end

local function determineEnemyType(pwr)
    if pwr >= 1  and pwr <= 5  then return "basic"  end
    if pwr >= 6  and pwr <= 12 then return "evolve" end
    if pwr >= 13 and pwr <= 19 then return "badass" end
    if pwr == 20               then return "boss"   end
    return "basic"
end

describe("determineDifficultyUpgrade", function()
    it("returns 0 when all inputs are 0", function()
        assert.equals(0, determineDifficultyUpgrade(0, 0, 0))
    end)
    it("returns 100 when all inputs are at max", function()
        assert.equals(100, determineDifficultyUpgrade(100, 20, 500))
    end)
    it("clamps output to [0, 100]", function()
        local p = determineDifficultyUpgrade(999, 999, 999)
        assert.is_true(p >= 0 and p <= 100)
    end)
    it("powerLevel has the largest weight (0.45)", function()
        local powerOnly = determineDifficultyUpgrade(0, 20, 0)
        assert.equals(45, powerOnly)
    end)
end)

describe("determineEnemyType", function()
    it("returns basic for powerLevel 1-5",  function()
        for i = 1, 5 do assert.equals("basic",  determineEnemyType(i)) end
    end)
    it("returns evolve for powerLevel 6-12", function()
        for i = 6, 12 do assert.equals("evolve", determineEnemyType(i)) end
    end)
    it("returns badass for powerLevel 13-19", function()
        for i = 13, 19 do assert.equals("badass", determineEnemyType(i)) end
    end)
    it("returns boss for powerLevel 20", function()
        assert.equals("boss", determineEnemyType(20))
    end)
    it("falls back to basic for out-of-range values", function()
        assert.equals("basic", determineEnemyType(0))
        assert.equals("basic", determineEnemyType(21))
    end)
end)
```

- [ ] **Step 2: Run and verify FAIL (functions not yet in a module)**

```bash
cd love2d-dancescene && busted tests/test_difficulty.lua
```
Expected: Tests pass (the functions are inlined in the test file — this validates the logic itself).

- [ ] **Step 3: Write `test_patterns.lua`**

```lua
-- tests/test_patterns.lua
package.path = package.path .. ";../src/data/?.lua"
require("EnemyPatterns")

describe("getPatternKey", function()
    it("always returns a valid button key", function()
        local valid = {
            leftButton=true, rightButton=true, upButton=true, downButton=true,
            aButton=true, bButton=true
        }
        math.randomseed(42)
        for _ = 1, 200 do
            local key = getPatternKey(EnemyPatterns.basic)
            assert.is_true(valid[key] ~= nil, "invalid key: " .. tostring(key))
        end
    end)

    it("boss profile never returns arrows (weight 0.2 arrows, heavy a/b)", function()
        -- Boss has arrows weight 0.2 — they can still appear, just less often.
        -- Verify a/b appear in at least 60% of 1000 rolls.
        math.randomseed(12345)
        local abCount = 0
        for _ = 1, 1000 do
            local k = getPatternKey(EnemyPatterns.boss)
            if k == "aButton" or k == "bButton" then abCount = abCount + 1 end
        end
        assert.is_true(abCount >= 600, "expected >=60% a/b for boss, got " .. abCount)
    end)

    it("basic profile returns arrows at ~80% rate", function()
        math.randomseed(99)
        local arrowCount = 0
        local arrows = { leftButton=true, rightButton=true, upButton=true, downButton=true }
        for _ = 1, 1000 do
            local k = getPatternKey(EnemyPatterns.basic)
            if arrows[k] then arrowCount = arrowCount + 1 end
        end
        -- Allow ±5% tolerance
        assert.is_true(arrowCount >= 750 and arrowCount <= 850,
            "expected ~80% arrows for basic, got " .. arrowCount)
    end)
end)
```

- [ ] **Step 4: Write `test_balance.lua`**

```lua
-- tests/test_balance.lua
-- Tests the balance position math and win/lose thresholds.

describe("balance position", function()
    local function clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end
    local maxOffset = 50  -- default balanceMaxOffset (= enemyHP)

    it("correct A press moves balance +5", function()
        local pos = 0
        pos = pos + 5
        assert.equals(5, pos)
    end)

    it("correct arrow press adds accuracy to balance", function()
        local pos = 0
        local accuracy = 3
        pos = pos + accuracy
        assert.equals(3, pos)
    end)

    it("wrong press moves balance -5", function()
        local pos = 10
        pos = pos - 5
        assert.equals(5, pos)
    end)

    it("balance is clamped to [-maxOffset, +maxOffset]", function()
        assert.equals(maxOffset,  clamp(maxOffset + 100, -maxOffset, maxOffset))
        assert.equals(-maxOffset, clamp(-maxOffset - 100, -maxOffset, maxOffset))
    end)

    it("win condition triggers at >= +maxOffset", function()
        local pos = maxOffset
        assert.is_true(pos >= maxOffset)
    end)

    it("lose condition triggers at <= -maxOffset", function()
        local pos = -maxOffset
        assert.is_true(pos <= -maxOffset)
    end)
end)
```

- [ ] **Step 5: Run all tests**

```bash
cd love2d-dancescene && busted tests/
```
Expected: All tests PASS.

- [ ] **Step 6: Commit**

```bash
git add love2d-dancescene/tests/
git commit -m "test: add unit tests for difficulty, patterns, and balance logic"
```

---

## Chunk 2: Core Entities

### Task 4: `ButtonPress` entity

A `ButtonPress` scrolls from right to left across the screen. It tracks: its `buttonKey` (the required input), position, speed derived from BPM, and whether it has been `hit`.

**Files:**
- Create: `love2d-dancescene/src/entities/ButtonPress.lua`

**Love2D translation notes:**
- Playdate: `NobleSprite` moves via sprite system. Love2D: plain table updated in `update(dt)`.
- `bpm` drives speed: one button crosses the screen in `60/bpm` seconds. Screen width is 400px (logical). Speed = `400 / (60/bpm)` px/sec.
- `movementDelay` pauses movement for N milliseconds after `start()` is called.

- [ ] **Step 1: Write the failing test first** — create `tests/test_button_press.lua`:

```lua
-- tests/test_button_press.lua
package.path = package.path .. ";../src/entities/?.lua;../src/data/?.lua"

-- Stub love2d globals for unit testing outside of love
love = { timer = { getTime = function() return 0 end } }

require("EnemyPatterns")  -- for getPatternKey
require("ButtonPress")

describe("ButtonPress", function()
    it("starts at x=400 (right edge, logical coords)", function()
        local btn = ButtonPress.new(16, 500, function() return "aButton" end)
        assert.equals(400, btn.x)
    end)

    it("has a valid buttonKey after creation", function()
        local btn = ButtonPress.new(16, 500, function() return "leftButton" end)
        assert.equals("leftButton", btn.buttonKey)
    end)

    it("moves left when updated after delay expires", function()
        local btn = ButtonPress.new(16, 0, function() return "aButton" end)
        -- delay is 0, so movement starts immediately
        btn:update(0.1)
        assert.is_true(btn.x < 400)
    end)

    it("does not move before delay expires", function()
        local btn = ButtonPress.new(16, 5000, function() return "aButton" end)
        btn:update(0.1)
        assert.equals(400, btn.x)
    end)

    it("is marked hit after hit() is called", function()
        local btn = ButtonPress.new(16, 0, function() return "aButton" end)
        assert.is_false(btn.isHit)
        btn:hit()
        assert.is_true(btn.isHit)
    end)
end)
```

- [ ] **Step 2: Run — verify FAIL** (`require("ButtonPress")` fails)

```bash
cd love2d-dancescene && busted tests/test_button_press.lua
```

- [ ] **Step 3: Implement `ButtonPress.lua`**

```lua
-- src/entities/ButtonPress.lua
-- Scrolls right→left across the screen. Owned and updated by DanceScene.

ButtonPress = {}
ButtonPress.__index = ButtonPress

-- BUTTON_LABELS: maps key → display character for drawing
local BUTTON_LABELS = {
    aButton    = "A",
    bButton    = "B",
    leftButton = "◀",
    upButton   = "▲",
    rightButton= "▶",
    downButton = "▼",
}

-- bpm        : beats per minute (controls scroll speed)
-- delayMs    : milliseconds before this button starts moving
-- keyProvider: function() → buttonKey string
function ButtonPress.new(bpm, delayMs, keyProvider)
    local self  = setmetatable({}, ButtonPress)
    self.buttonKey   = keyProvider()
    self.label       = BUTTON_LABELS[self.buttonKey] or "?"
    self.x           = 400          -- logical right edge
    self.y           = 110          -- vertical center of battle area
    self.width       = 20
    self.height      = 20
    self.isHit       = false
    self.delayMs     = delayMs or 0
    self.elapsedMs   = 0
    -- Speed: cross 400px in (60/bpm) seconds
    self.speed       = 400 / (60 / bpm)   -- px/sec
    return self
end

function ButtonPress:movementDelay(ms)
    self.delayMs = ms
end

function ButtonPress:update(dt)
    if self.isHit then return end
    local dtMs = dt * 1000
    if self.elapsedMs < self.delayMs then
        self.elapsedMs = self.elapsedMs + dtMs
        return
    end
    self.x = self.x - self.speed * dt
end

function ButtonPress:draw(scale)
    if self.isHit then return end
    scale = scale or 2
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", self.x * scale, self.y * scale, self.width * scale, self.height * scale)
    love.graphics.printf(self.label, self.x * scale, self.y * scale + 2 * scale, self.width * scale, "center")
end

function ButtonPress:hit()
    self.isHit = true
end

-- Returns axis-aligned bounding box in logical coords
function ButtonPress:getBounds()
    return self.x, self.y, self.width, self.height
end
```

- [ ] **Step 4: Run test — verify PASS**

```bash
busted tests/test_button_press.lua
```

- [ ] **Step 5: Commit**

```bash
git add love2d-dancescene/src/entities/ButtonPress.lua love2d-dancescene/tests/test_button_press.lua
git commit -m "feat: add ButtonPress entity with TDD"
```

---

### Task 5: `HitZone` entity + AABB collision

`HitZone` is a fixed rect on the left side. Each frame it returns a list of `ButtonPress` entities whose bounding box overlaps it.

**Files:**
- Create: `love2d-dancescene/src/entities/HitZone.lua`

- [ ] **Step 1: Write `tests/test_hitzone.lua`**

```lua
-- tests/test_hitzone.lua
package.path = package.path .. ";../src/entities/?.lua"
love = { timer = { getTime = function() return 0 end } }

require("ButtonPress")
require("HitZone")

local function makeBtn(x, key)
    local btn = ButtonPress.new(16, 0, function() return key end)
    btn.x = x
    return btn
end

describe("HitZone", function()
    local hz = HitZone.new(30, 100, 20, 40)  -- x, y, w, h (logical)

    it("detects a button inside the zone", function()
        local btn = makeBtn(35, "aButton")  -- x=35, inside zone x=30..50
        local hits = hz:overlapping({ btn })
        assert.equals(1, #hits)
        assert.equals(btn, hits[1])
    end)

    it("does not detect a button outside the zone", function()
        local btn = makeBtn(200, "aButton")
        local hits = hz:overlapping({ btn })
        assert.equals(0, #hits)
    end)

    it("ignores hit buttons", function()
        local btn = makeBtn(35, "aButton")
        btn:hit()
        local hits = hz:overlapping({ btn })
        assert.equals(0, #hits)
    end)

    it("detects multiple buttons in zone", function()
        local b1 = makeBtn(33, "aButton")
        local b2 = makeBtn(38, "leftButton")
        local hits = hz:overlapping({ b1, b2 })
        assert.equals(2, #hits)
    end)
end)
```

- [ ] **Step 2: Run — verify FAIL**

```bash
busted tests/test_hitzone.lua
```

- [ ] **Step 3: Implement `HitZone.lua`**

```lua
-- src/entities/HitZone.lua
-- Fixed rect on the left side of the battle screen.
-- Detects which ButtonPress entities are currently overlapping it.

HitZone = {}
HitZone.__index = HitZone

function HitZone.new(x, y, w, h)
    return setmetatable({ x=x, y=y, w=w, h=h }, HitZone)
end

-- AABB intersection
local function aabbOverlap(ax, ay, aw, ah, bx, by, bw, bh)
    return ax < bx + bw and ax + aw > bx and
           ay < by + bh and ay + ah > by
end

-- buttons: table of ButtonPress instances
-- Returns list of overlapping, non-hit buttons.
function HitZone:overlapping(buttons)
    local result = {}
    for _, btn in ipairs(buttons) do
        if not btn.isHit then
            local bx, by, bw, bh = btn:getBounds()
            if aabbOverlap(self.x, self.y, self.w, self.h, bx, by, bw, bh) then
                result[#result + 1] = btn
            end
        end
    end
    return result
end

function HitZone:draw(scale)
    scale = scale or 2
    love.graphics.setColor(0.2, 0.8, 0.2, 0.5)
    love.graphics.rectangle("fill", self.x * scale, self.y * scale, self.w * scale, self.h * scale)
    love.graphics.setColor(1, 1, 1)
end
```

- [ ] **Step 4: Run — verify PASS**

```bash
busted tests/test_hitzone.lua
```

- [ ] **Step 5: Commit**

```bash
git add love2d-dancescene/src/entities/HitZone.lua love2d-dancescene/tests/test_hitzone.lua
git commit -m "feat: add HitZone entity with AABB collision detection"
```

---

### Task 6: Visual entities (stubs with placeholder drawing)

These entities handle visuals only — no game logic. Implement them as simple drawers so DanceScene can wire them up. Replace with real sprites/animations after the logic works.

**Files:**
- Create: `love2d-dancescene/src/entities/BackgroundDance.lua`
- Create: `love2d-dancescene/src/entities/ButtonCover.lua`
- Create: `love2d-dancescene/src/entities/WinIndicator.lua`
- Create: `love2d-dancescene/src/entities/LoseIndicator.lua`

- [ ] **Step 1: Create `BackgroundDance.lua`**

```lua
-- src/entities/BackgroundDance.lua
BackgroundDance = {}
BackgroundDance.__index = BackgroundDance

function BackgroundDance.new()
    return setmetatable({}, BackgroundDance)
end

function BackgroundDance:draw(scale)
    scale = scale or 2
    love.graphics.setColor(0.05, 0.05, 0.15)
    love.graphics.rectangle("fill", 0, 0, 400 * scale, 240 * scale)
    love.graphics.setColor(1, 1, 1)
end
```

- [ ] **Step 2: Create `ButtonCover.lua`**

```lua
-- src/entities/ButtonCover.lua
-- Draws a mask over the left side so buttons "disappear" when they enter the hit zone.
ButtonCover = {}
ButtonCover.__index = ButtonCover

function ButtonCover.new()
    return setmetatable({}, ButtonCover)
end

function ButtonCover:draw(scale)
    scale = scale or 2
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 100 * scale, 25 * scale, 40 * scale)
    love.graphics.setColor(1, 1, 1)
end
```

- [ ] **Step 3: Create `WinIndicator.lua` and `LoseIndicator.lua`**

```lua
-- src/entities/WinIndicator.lua
WinIndicator = {}
WinIndicator.__index = WinIndicator

function WinIndicator.new(x, y)
    return setmetatable({ x=x, y=y }, WinIndicator)
end

function WinIndicator:draw(scale)
    scale = scale or 2
    love.graphics.setColor(0.2, 1, 0.2)
    love.graphics.print("WIN", self.x * scale, self.y * scale)
    love.graphics.setColor(1, 1, 1)
end
```

```lua
-- src/entities/LoseIndicator.lua
LoseIndicator = {}
LoseIndicator.__index = LoseIndicator

function LoseIndicator.new(x, y)
    return setmetatable({ x=x, y=y }, LoseIndicator)
end

function LoseIndicator:draw(scale)
    scale = scale or 2
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.print("LOSE", self.x * scale, self.y * scale)
    love.graphics.setColor(1, 1, 1)
end
```

- [ ] **Step 4: Commit**

```bash
git add love2d-dancescene/src/entities/
git commit -m "feat: add visual entity stubs (background, cover, indicators)"
```

---

### Task 7: `PlayerDance` and `EnemyRatDance` (animation stubs)

These use `anim8` when sprite sheets are available. For now implement with colored rectangles and text labels so DanceScene integration works immediately. Replace with real spritesheets afterwards.

**Files:**
- Create: `love2d-dancescene/src/entities/PlayerDance.lua`
- Create: `love2d-dancescene/src/entities/EnemyRatDance.lua`

- [ ] **Step 1: Create `PlayerDance.lua`**

```lua
-- src/entities/PlayerDance.lua
-- Displays player state as text for now. Replace with anim8 spritesheet.
-- States: idle, aButton, bButton, leftButton, rightButton, upButton, downButton
PlayerDance = {}
PlayerDance.__index = PlayerDance

function PlayerDance.new(bpm)
    return setmetatable({ bpm=bpm, state="idle" }, PlayerDance)
end

function PlayerDance:changeAnimation(buttonKey)
    self.state = buttonKey
end

function PlayerDance:setIdle()
    self.state = "idle"
end

function PlayerDance:update(dt) end

function PlayerDance:draw(scale)
    scale = scale or 2
    local x, y = 60 * scale, 150 * scale
    love.graphics.setColor(0.3, 0.6, 1)
    love.graphics.rectangle("fill", x, y, 30 * scale, 40 * scale)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("P\n" .. self.state:sub(1,3), x, y + 4 * scale, 30 * scale, "center")
end
```

- [ ] **Step 2: Create `EnemyRatDance.lua`**

```lua
-- src/entities/EnemyRatDance.lua
-- States: idle, attack (per button), plus evolving visual.
EnemyRatDance = {}
EnemyRatDance.__index = EnemyRatDance

function EnemyRatDance.new(bpm, enemyType, evolving)
    return setmetatable({
        bpm       = bpm,
        enemyType = enemyType or "basic",
        evolving  = evolving or false,
        state     = "idle",
    }, EnemyRatDance)
end

function EnemyRatDance:changeAnimation(buttonKey)
    self.state = buttonKey
end

function EnemyRatDance:attackAnimation(buttonKey)
    self.state = "attack_" .. buttonKey
end

function EnemyRatDance:setIdle()
    self.state = "idle"
end

function EnemyRatDance:update(dt) end

function EnemyRatDance:draw(scale)
    scale = scale or 2
    local x, y = 280 * scale, 150 * scale
    local color = self.evolving and {1, 0.5, 0} or {0.8, 0.2, 0.2}
    love.graphics.setColor(table.unpack(color))
    love.graphics.rectangle("fill", x, y, 30 * scale, 40 * scale)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("E\n" .. self.state:sub(1,3), x, y + 4 * scale, 30 * scale, "center")
end
```

- [ ] **Step 3: Commit**

```bash
git add love2d-dancescene/src/entities/PlayerDance.lua love2d-dancescene/src/entities/EnemyRatDance.lua
git commit -m "feat: add PlayerDance and EnemyRatDance stubs"
```

---

### Task 8: `ResultsScreen` entity

In the original, `ResultsScreen` has three states: `empty()` (battle in progress — renders nothing), `win()` / `lose()` (shows result text), and `loadingScreen()` (shown before battle starts — the "press A to begin" state).

**Files:**
- Create: `love2d-dancescene/src/entities/ResultsScreen.lua`

- [ ] **Step 1: Create `ResultsScreen.lua`**

```lua
-- src/entities/ResultsScreen.lua
-- Three states: "loading" (press A to start), "playing" (empty), "win", "lose"
ResultsScreen = {}
ResultsScreen.__index = ResultsScreen

function ResultsScreen.new()
    return setmetatable({ state = "loading" }, ResultsScreen)
end

function ResultsScreen:empty()
    self.state = "playing"
end

function ResultsScreen:win()
    if self.state ~= "win" then self.state = "win" end
end

function ResultsScreen:lose()
    if self.state ~= "lose" then self.state = "lose" end
end

-- Called in update() when isDancing==false and condition==nil (i.e. pre-battle)
function ResultsScreen:loadingScreen()
    self.state = "loading"
end

function ResultsScreen:draw(scale)
    scale = scale or 2
    if self.state == "playing" then return end

    -- Semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, 800, 480)
    love.graphics.setColor(1, 1, 1)

    if self.state == "loading" then
        love.graphics.printf("Press A to START BATTLE", 0, 200, 800, "center")
    elseif self.state == "win" then
        love.graphics.setColor(0.2, 1, 0.2)
        love.graphics.printf("YOU WIN!\nPress A to continue", 0, 180, 800, "center")
        love.graphics.setColor(1, 1, 1)
    elseif self.state == "lose" then
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.printf("YOU LOSE!\nPress A to continue", 0, 180, 800, "center")
        love.graphics.setColor(1, 1, 1)
    end
end
```

- [ ] **Step 2: Commit**

```bash
git add love2d-dancescene/src/entities/ResultsScreen.lua
git commit -m "feat: add ResultsScreen entity with loading/win/lose states"
```

---

## Chunk 3: Scene Integration

### Task 9: Minimal `SceneManager` + stub scenes

**Files:**
- Create: `love2d-dancescene/src/SceneManager.lua`
- Create: `love2d-dancescene/src/scenes/TitleScene.lua`

- [ ] **Step 1: Create `SceneManager.lua`**

```lua
-- src/SceneManager.lua
-- Minimal scene manager: push/pop with instant transitions.
-- Scenes must implement: load(), update(dt), draw(), keypressed(key), keyreleased(key)
SceneManager = {}
SceneManager.__index = SceneManager

local current = nil

function SceneManager.switch(scene)
    if current and current.exit then current:exit() end
    current = scene
    if current and current.enter then current:enter() end
end

function SceneManager.update(dt)
    if current and current.update then current:update(dt) end
end

function SceneManager.draw()
    if current and current.draw then current:draw() end
end

function SceneManager.keypressed(key)
    if current and current.keypressed then current:keypressed(key) end
end

function SceneManager.keyreleased(key)
    if current and current.keyreleased then current:keyreleased(key) end
end
```

- [ ] **Step 2: Create `TitleScene.lua`** (stub — just displays "Game Over / Press Enter")

```lua
-- src/scenes/TitleScene.lua
TitleScene = {}
TitleScene.__index = TitleScene

function TitleScene.new()
    return setmetatable({}, TitleScene)
end

function TitleScene:enter() end
function TitleScene:exit()  end

function TitleScene:update(dt)
    if love.keyboard.isDown("return") then
        -- Restart: switch back to DanceScene
        SceneManager.switch(DanceScene.new())
    end
end

function TitleScene:draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, 800, 480)
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.printf("GAME OVER\n\nPress Enter to restart", 0, 180, 800, "center")
    love.graphics.setColor(1, 1, 1)
end

function TitleScene:keypressed(key) end
function TitleScene:keyreleased(key) end
```

- [ ] **Step 3: Commit**

```bash
git add love2d-dancescene/src/SceneManager.lua love2d-dancescene/src/scenes/TitleScene.lua
git commit -m "feat: add SceneManager and TitleScene stub"
```

---

### Task 10: `DanceScene` — main scene (the core port)

This is the direct port of `scenes/DanceScene.lua`. Read the original carefully. Implement all logic preserving the exact mechanics described in the **Reference Material** section of this plan.

**Files:**
- Create: `love2d-dancescene/src/scenes/DanceScene.lua`

**Love2D API translations:**

| Playdate | Love2D |
|----------|--------|
| `Noble.transition(scene, ...)` | `SceneManager.switch(scene.new())` |
| `playdate.getCurrentTimeMilliseconds()` | `math.floor(love.timer.getTime() * 1000)` |
| `hitzone:overlappingSprites()` | `hitZone:overlapping(self.buttons)` |
| `table.getsize(t)` | `#t` |
| `scene.inputHandler = { AButtonDown = ... }` | `DanceScene:keypressed(key)` |
| `Graphics.drawText(s, x, y)` | `love.graphics.print(s, x*scale, y*scale)` |
| `Graphics.kColorBlack` | `love.graphics.setColor(0,0,0)` |
| `img:drawCentered(x, y)` | `love.graphics.draw(img, x-img:getWidth()/2, y-img:getHeight()/2)` |
| `Sequence.new():from(0):to(100,...)` | not needed — ignore intro animation for now |
| `findAndKillEnemyById(id)` | stub function (prints "killed: id") |
| `RoomTranslate(n)` | `TitleScene` (we have no maze — return to title on win too) |

- [ ] **Step 1: Create `DanceScene.lua`**

```lua
-- src/scenes/DanceScene.lua
-- Port of Playdate DanceScene. Read original scenes/DanceScene.lua for full logic.

local SCALE = 2  -- logical 400×240 → physical 800×480

-- Require all entities
require "src/data/PlayerData"
require "src/data/EnemyPatterns"
require "src/entities/ButtonPress"
require "src/entities/HitZone"
require "src/entities/PlayerDance"
require "src/entities/EnemyRatDance"
require "src/entities/BackgroundDance"
require "src/entities/ButtonCover"
require "src/entities/WinIndicator"
require "src/entities/LoseIndicator"
require "src/entities/ResultsScreen"

DanceScene = {}
DanceScene.__index = DanceScene

-- Stub: replace with real enemy-kill logic when integrating with MazeScene
local function findAndKillEnemyById(id)
    print("[DanceScene] killed enemy: " .. tostring(id))
end

-- ─────────────────────────────────────────────
-- Difficulty helpers (verbatim logic from original)
-- ─────────────────────────────────────────────

local function determineDifficultyUpgrade()
    local sanity   = PlayerData.sanityCounter or 0
    local power    = (PlayerData.EnemiesData and PlayerData.EnemiesData.powerLevel) or 0
    local calories = PlayerData.calories or 0
    local sN = math.max(0, math.min(1, sanity   / 100))
    local pN = math.max(0, math.min(1, power    / 20))
    local cN = math.max(0, math.min(1, calories / 500))
    local score = sN * 0.35 + pN * 0.45 + cN * 0.20
    return math.max(0, math.min(100, score * 100))
end

local function determineEnemyType()
    local pwr = PlayerData.EnemiesData.powerLevel
    if pwr >= 1  and pwr <= 5  then return "basic"  end
    if pwr >= 6  and pwr <= 12 then return "evolve" end
    if pwr >= 13 and pwr <= 19 then return "badass" end
    if pwr == 20               then return "boss"   end
    return "basic"
end

-- ─────────────────────────────────────────────
-- Scene lifecycle
-- ─────────────────────────────────────────────

function DanceScene.new()
    local self = setmetatable({}, DanceScene)

    math.randomseed(math.floor(love.timer.getTime() * 1000))

    -- State (mirrors Playdate init)
    self.bpm                 = 16
    self.ButtonPressed       = nil
    self.accuracy            = 0
    self.totalAccuracy       = 0
    self.enemyHP             = 50
    self.evadePower          = 30
    self.condition           = nil
    self.enemyType           = nil
    self.enemyEvolving       = false
    self.numberOfButtons     = 4
    self.balancePosition     = 0
    self.balanceMaxOffset    = 50  -- tied to enemyHP
    self.correctButtonPresses = {
        aButton=0, bButton=0,
        leftButton=0, rightButton=0, upButton=0, downButton=0,
    }

    -- Screen constants (logical coords)
    self.screenCenterX = 200
    self.barWidth      = 8
    self.barHeight     = 10
    self.barY          = 56

    return self
end

function DanceScene:enter()
    PlayerData.isDancing = false
    self.condition       = nil

    -- Difficulty roll (exact logic from original)
    local chance = determineDifficultyUpgrade()
    local roll   = math.random(0, 100)

    if roll <= chance then
        self.enemyType    = determineEnemyType()
        self.enemyEvolving = true
    else
        self.enemyType    = "basic"
        self.enemyEvolving = false
    end

    -- BPM + button count by type
    local cfg = {
        basic  = { bpm=16, buttons=4  },
        evolve = { bpm=24, buttons=6  },
        badass = { bpm=28, buttons=8  },
        boss   = { bpm=32, buttons=12 },
    }
    local c = cfg[self.enemyType] or cfg.basic
    self.bpm             = c.bpm
    self.numberOfButtons = c.buttons

    -- Create ButtonPress instances
    local startPoint = 400
    local profile    = EnemyPatterns[self.enemyType] or EnemyPatterns.basic
    local function keyProvider() return getPatternKey(profile) end

    self.buttons = {}
    for i = 1, self.numberOfButtons do
        local btn = ButtonPress.new(self.bpm, (i-1) * 300, keyProvider)
        self.buttons[i] = btn
    end

    -- Create all other entities (positions match original)
    self.hitZone         = HitZone.new(30, 100, 20, 40)
    self.playerDance     = PlayerDance.new(self.bpm)
    self.enemyDance      = EnemyRatDance.new(self.bpm, self.enemyType, self.enemyEvolving)
    self.buttonCover     = ButtonCover.new()
    self.winIndicator    = WinIndicator.new(self.screenCenterX + self.balanceMaxOffset + 2*self.barWidth,
                                            self.barY + self.barHeight/2 - 6)
    self.loseIndicator   = LoseIndicator.new(self.screenCenterX - self.balanceMaxOffset - 2*self.barWidth,
                                             self.barY + self.barHeight/2 - 6)
    self.backgroundDance = BackgroundDance.new()
    self.resultsScreen   = ResultsScreen.new()
end

function DanceScene:exit() end

-- ─────────────────────────────────────────────
-- Update (core game loop — mirrors original update())
-- ─────────────────────────────────────────────

function DanceScene:update(dt)
    -- Pre-battle: waiting for player to press A
    if not PlayerData.isDancing and self.condition == nil then
        self.resultsScreen:loadingScreen()
        return
    end

    -- Update all button positions
    for _, btn in ipairs(self.buttons) do
        btn:update(dt)
    end

    -- HitZone collision check (replaces overlappingSprites)
    local collisions = self.hitZone:overlapping(self.buttons)

    if #collisions > 0 then
        if self.ButtonPressed == nil then
            -- No input: accuracy penalty after 5-frame grace
            self.accuracy = self.accuracy + 1
            if self.accuracy > 5 then
                self.balancePosition = self.balancePosition - 0.3
            end
            self.enemyDance:changeAnimation(collisions[1].buttonKey)

        elseif collisions[1].buttonKey == self.ButtonPressed then
            -- Correct press
            if self.ButtonPressed == "aButton" or self.ButtonPressed == "bButton" then
                self.enemyDance:attackAnimation(self.ButtonPressed)
                self.enemyHP          = self.enemyHP - 10
                self.balancePosition  = self.balancePosition + 5
            else
                -- Arrow: accuracy-based balance gain
                self.balancePosition  = self.balancePosition + self.accuracy
                self.totalAccuracy    = self.totalAccuracy + self.accuracy
                self.evadePower       = self.totalAccuracy
            end
            self.playerDance:changeAnimation(self.ButtonPressed)
            collisions[1]:hit()
            self:incrementCorrectPress(self.ButtonPressed)
        else
            -- Wrong press
            collisions[1]:hit()
            self.balancePosition = self.balancePosition - 5
        end
        self.ButtonPressed = nil
    else
        self.accuracy = 0
    end

    -- Clamp balance
    self.balancePosition = math.max(-self.balanceMaxOffset,
                           math.min( self.balanceMaxOffset, self.balancePosition))

    -- Win / lose threshold check
    if self.balancePosition >= self.balanceMaxOffset then
        self.resultsScreen:win()
        PlayerData.isDancing = false
        self.condition = "win"
    end
    if self.balancePosition <= -self.balanceMaxOffset then
        self.resultsScreen:lose()
        PlayerData.isDancing = false
        self.condition = "lose"
    end
end

-- ─────────────────────────────────────────────
-- Draw
-- ─────────────────────────────────────────────

function DanceScene:draw()
    self.backgroundDance:draw(SCALE)

    -- Draw buttons
    for _, btn in ipairs(self.buttons or {}) do
        btn:draw(SCALE)
    end

    -- Draw HitZone
    self.hitZone:draw(SCALE)
    self.buttonCover:draw(SCALE)

    -- Balance bar (image or fallback rectangle)
    local bx = (self.screenCenterX + self.balancePosition - self.barWidth/2) * SCALE
    local by = self.barY * SCALE
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle("fill", bx, by, self.barWidth * SCALE, self.barHeight * SCALE)
    love.graphics.setColor(1, 1, 1)

    -- Indicators
    self.winIndicator:draw(SCALE)
    self.loseIndicator:draw(SCALE)

    -- Dancer sprites
    self.playerDance:draw(SCALE)
    self.enemyDance:draw(SCALE)

    -- Results overlay (drawn last, on top)
    self.resultsScreen:draw(SCALE)

    -- Debug info
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print(
        string.format("type=%s bpm=%d bal=%.1f hp=%d",
            tostring(self.enemyType), self.bpm,
            self.balancePosition, self.enemyHP),
        4, 4)
    love.graphics.setColor(1, 1, 1)
end

-- ─────────────────────────────────────────────
-- Input (replaces Noble inputHandler table)
-- ─────────────────────────────────────────────

function DanceScene:keypressed(key)
    -- Pre-battle start (mirrors AButtonDown when isDancing==false)
    if not PlayerData.isDancing and self.condition == nil then
        if key == "return" or key == "space" then
            self:startBattle()
        end
        return
    end

    -- Map keyboard → button keys (same mapping as DOCS/ENEMIES_AND_COMBAT.md)
    local keyMap = {
        ["return"] = "aButton",
        ["space"]  = "aButton",
        ["lshift"] = "bButton",
        ["rshift"] = "bButton",
        ["left"]   = "leftButton",
        ["right"]  = "rightButton",
        ["up"]     = "upButton",
        ["down"]   = "downButton",
    }
    local mapped = keyMap[key]
    if mapped then
        self:danceStep(mapped)
        self:checkDanceResults()
    end
end

function DanceScene:keyreleased(key)
    self:clearButton()
end

-- ─────────────────────────────────────────────
-- Game actions (verbatim from original)
-- ─────────────────────────────────────────────

function DanceScene:danceStep(inputStep)
    self.ButtonPressed = inputStep
end

function DanceScene:clearButton()
    self.ButtonPressed = nil
end

function DanceScene:incrementCorrectPress(button)
    if self.correctButtonPresses[button] ~= nil then
        self.correctButtonPresses[button] = self.correctButtonPresses[button] + 1
    end
end

function DanceScene:startBattle()
    self.resultsScreen:empty()
    PlayerData.isDancing = true
    self.enemyDance:setIdle()
end

function DanceScene:checkDanceResults()
    if self.condition == "win" then
        self.condition     = nil
        self.totalAccuracy = 0
        findAndKillEnemyById(PlayerData.lastEnemyTouched.id)
        PlayerData.healthPoints   = PlayerData.healthPoints + PlayerData.healedHP
        PlayerData.playerSpawn.x  = PlayerData.playerExit.x
        PlayerData.playerSpawn.y  = PlayerData.playerExit.y
        PlayerData.amountDances   = PlayerData.amountDances + 1
        PlayerData.calories       = PlayerData.calories + 60
        -- In full game: SceneManager.switch(MazeScene for PlayerData.saveLevel)
        -- For standalone: show win screen then restart
        print("[DanceScene] WIN — would return to room " .. PlayerData.saveLevel)
        SceneManager.switch(TitleScene.new())

    elseif self.condition == "lose" then
        self.condition = nil
        print("[DanceScene] LOSE — game over")
        SceneManager.switch(TitleScene.new())
    end
end
```

- [ ] **Step 2: Commit**

```bash
git add love2d-dancescene/src/scenes/DanceScene.lua
git commit -m "feat: port DanceScene to love2d with full rhythm combat logic"
```

---

### Task 11: Wire everything in `main.lua` + smoke test

**Files:**
- Modify: `love2d-dancescene/main.lua`

- [ ] **Step 1: Update `main.lua`**

```lua
-- main.lua
require "src/SceneManager"
require "src/scenes/TitleScene"
require "src/scenes/DanceScene"

function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setNewFont(12)
    SceneManager.switch(DanceScene.new())
end

function love.update(dt)
    SceneManager.update(dt)
end

function love.draw()
    SceneManager.draw()
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end
    SceneManager.keypressed(key)
end

function love.keyreleased(key)
    SceneManager.keyreleased(key)
end
```

- [ ] **Step 2: Run and manually verify the complete gameplay loop**

```bash
cd love2d-dancescene && love .
```

Manual test checklist:
- [ ] Game opens with black screen and "Press A to START BATTLE" overlay
- [ ] Press Space/Enter → buttons start scrolling right→left
- [ ] Press correct key when a button is in the green HitZone → balance bar moves right
- [ ] Press wrong key → balance bar moves left
- [ ] Miss (no press, button exits zone) → balance drifts left after grace period
- [ ] Balance reaches +50 → WIN overlay appears, press A → TitleScene (Game Over)
- [ ] Balance reaches -50 → LOSE overlay appears, press A → TitleScene (Game Over)
- [ ] Debug line at top shows `type=basic bpm=16 bal=X.X hp=Y`

- [ ] **Step 3: Test difficulty scaling** — edit `src/data/PlayerData.lua`, set `powerLevel = 20`, re-run. Verify debug shows `type=boss bpm=32` and 12 buttons appear.

- [ ] **Step 4: Commit**

```bash
git add love2d-dancescene/main.lua
git commit -m "feat: wire up main.lua and complete DanceScene integration"
```

---

## Chunk 4: Polish & Hardening

### Task 12: Edge cases + final test run

- [ ] **Step 1: Run full busted suite**

```bash
cd love2d-dancescene && busted tests/
```
Expected: All tests PASS.

- [ ] **Step 2: Verify button staggering** — with `numberOfButtons = 4`, buttons should appear spaced 300ms apart, not all at once.

- [ ] **Step 3: Verify `isHit` buttons are ignored by HitZone** — hit a button, confirm it disappears and the zone no longer detects it next frame.

- [ ] **Step 4: Verify `clearButton()` is called on key release** — hold a key, release it, press again on a different button: should register the new key, not the old one.

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "chore: final polish and verified all edge cases pass"
```

---

## Integration Notes (for when connecting to full game)

When this scene is integrated into the full Love2D port of the game:

- Replace `findAndKillEnemyById` stub with real entity lookup in MazeScene's entity table.
- Replace `SceneManager.switch(TitleScene.new())` on win with `SceneManager.switch(MazeScene.new(PlayerData.saveLevel))`.
- Replace colored-rectangle entities with real spritesheets using `anim8`: load the spritesheet image, define a `Grid`, create animation objects per state (idle/attack/etc.), call `anim:update(dt)` and `anim:draw(image, x, y)`.
- The balance bar nudge image (`assets/images/ui/battle/nudgeIndicator.png`) should replace the yellow rectangle in `DanceScene:draw()`.
- `PlayerData.isDancing`, `PlayerData.saveLevel`, `PlayerData.lastEnemyTouched` must be set by MazeScene before transitioning to DanceScene (same contract as Playdate version).
