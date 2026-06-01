# Config.lua — Complete Reference

`source/assets/data/Config.lua` is the **single source of truth** for all tunable game constants. No magic numbers should appear in gameplay code — every value that controls behavior lives here.

Available globally as `Config`. Aliased in `main.lua`:
```lua
ZIndex = Config.ZIndex
CollideGroups = Config.CollideGroups
```

---

## Config.ZIndex — Render Layers

Controls draw order. Higher value = drawn on top. Used in every entity's `:setZIndex()` call.

| Section | Name | Value | Unit | Usage Description |
|---|---|---|---|---|
| ZIndex | `player` | 4 | layer | Main player |
| ZIndex | `enemy` | 3 | layer | Brocorat, Bosscolli |
| ZIndex | `props` | 2 | layer | PropItem, Door sprites |
| ZIndex | `items` | 4 | layer | Items (pickups) — same layer as player |
| ZIndex | `foreground` | 300 | layer | Room foreground sprite |
| ZIndex | `fx` | 1999 | layer | FXshadow (darkness mask) |
| ZIndex | `ui` | 2000 | layer | UIHud (interaction indicator) |
| ZIndex | `hud` | 2000 | layer | playerHud, Battery, HealthIndicator |
| ZIndex | `menu` | 2100 | layer | inGameMenu (map + crew hats) |
| ZIndex | `alert` | 2200 | layer | Achievement notification toasts |

---

## Config.CollideGroups — Collision Groups

Numeric IDs for the Playdate sprite collision system. Each sprite calls `:setGroups(id)` and `:setCollidesWithGroups({ids})`.

| Section | Name | Value | Entity That Uses It |
|---|---|---|---|
| CollideGroups | `player` | 1 | `Player` |
| CollideGroups | `enemy` | 2 | `Brocorat`, `Bosscolli` |
| CollideGroups | `props` | 3 | `PropItem`, `Door` |
| CollideGroups | `items` | 4 | `Items` (pickups), `Projectile` |
| CollideGroups | `wall` | 5 | `Box` (tile colliders) |
| CollideGroups | `noCollide` | 6 | Decorative/pass-through objects |
| CollideGroups | `crewMember` | 7 | `CrewMember` |

---

## Config.Tiles — Tilemap

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Tiles | `size` | 16 | px | Size of each tile; used in `GetTileUnderPlayer` and `CreateTileColliders` |
| Tiles.IntGrid | `wall` | 1 | id | Non-walkable tile; generates a `Box` collider |
| Tiles.IntGrid | `slime` | 2 | id | Walkable; activates `IsPlayerOnSlime`, reduces speed |
| Tiles.IntGrid | `hole` | 3 | id | Walkable; activates `IsPlayerOnHole`, drains battery |
| Tiles.IntGrid | `floor` | 4 | id | Walkable; no special effect |
| Tiles.IntGrid | `tinyHole` | 32 | id | Walkable; only accessible in `isTiny` mode |

---

## Config.Player — Player Movement

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Player | `speed` | 2 | px/frame | Base movement speed at 50fps |
| Player | `speedDarkNoLamp` | 0.7 | multiplier | Speed in darkness without lamp |
| Player | `speedLowBattery` | 0.8 | multiplier | Speed when `battery < thresholdLow` with lamp |
| Player | `collideRect` | `{x=8,y=24,w=30,h=24}` | px | Collision rect in normal size |
| Player | `collideRectTiny` | `{x=19,y=32,w=10,h=10}` | px | Collision rect in tiny mode |
| Player | `collideRectHead` | `{x=8,y=8,w=16,h=16}` | px | Head rect for depth check |
| Player | `uiOffsetX` | 30 | px | HUD X offset relative to player |
| Player | `uiOffsetY` | 30 | px | HUD Y offset relative to player |
| Player | `hudOffsetY` | -40 | px | playerHud Y offset (normal size) |
| Player | `hudOffsetYTiny` | -17 | px | playerHud Y offset (tiny mode) |
| Player | `triggerCheckDist` | 5 | px | Pixels moved before re-checking trigger overlap |
| Player | `movementFramesPerAction` | 3 | frames | Movement frames distributed to NPCs/enemies per move |
| Player | `knockbackDistance` | 2 | px | Push distance when colliding with an enemy |
| Player | `maxHealthPoints` | 10 | HP | Hard cap on `healthPoints`; HUD draws up to 10 dots. Enforced in `Player:update()`, the cook loop, and the DanceScene win heal |

---

## Config.Microwave — Food Healing

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Microwave | `hpPerFood` | 1 | HP | HP restored per food cooked (1:1 for now; tune later) |
| Microwave | `caloriesPerFood` | 1 | calories | Calories gained per food cooked (byproduct; tune later) |
| Microwave | `carryMax` | 10 | food | Max food the player can carry (`grabFood` clamp) |
| Microwave | `perPickup` | 1 | food | Food granted per food item picked up |
| Microwave | `crankPerFood` | 1 | crank ticks | Crank ticks (`getCrankTicks(4)`, ~90° each) to cook 1 food — NOT degrees |

See `MICROWAVE_AND_FOOD.md` for the full system.

---

## Config.Slide — Slime Sliding

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Slide | `speed` | 4 | px/frame | Sliding speed on slime tiles |

---

## Config.Invincibility — Post-Hit Invincibility

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Invincibility | `duration` | 1000 | ms | Invincibility duration after taking damage |
| Invincibility | `flickerRate` | 100 | divisor | Divides the timer for the visual flicker effect |

---

## Config.Battery — Battery

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Battery | `drainMovementDark` | 0.5 | units/frame | Drain per frame when moving in darkness |
| Battery | `drainHoleNormal` | 0.5 | units/frame | Drain per frame when crossing a hole (normal size) |
| Battery | `drainHoleTiny` | 0.2 | units/frame | Drain per frame when crossing a hole (tiny mode) |
| Battery | `thresholdCritical` | 10 | % | Critical level; enemies override speed, crew stops |
| Battery | `thresholdLow` | 20 | % | Low level; sanity drains faster, enemies slow down |
| Battery | `thresholdMid` | 60 | % | Mid level; enemies use reduced speed, crew restores movement |

---

## Config.Sanity — Sanity

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Sanity | `tickInterval` | 2000 | ms | Interval between sanity checks |
| Sanity | `lossLowBattery` | 2 | pts/tick | Loss per tick when `battery < batteryThresholdLow` |
| Sanity | `lossMidBattery` | 1 | pts/tick | Loss per tick when `battery < batteryThresholdMid` |
| Sanity | `gainHighBattery` | 2 | pts/tick | Gain per tick when `battery > batteryThresholdHigh` or not dark |
| Sanity | `batteryThresholdLow` | 20 | % | Shared with `Battery.thresholdLow` |
| Sanity | `batteryThresholdMid` | 40 | % | Mid battery level for sanity |
| Sanity | `batteryThresholdHigh` | 50 | % | High battery level for sanity recovery |
| Sanity | `focusCost` | 20 | pts | Sanity consumed by the focus ability (legacy) |

---

## Config.LightBurst — Lamp Flash Ability

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| LightBurst | `batteryCost` | 10 | units | Battery consumed on flash activation |
| LightBurst | `cooldown` | 1000 | ms | Minimum time between flashes |
| LightBurst | `displayTime` | 1000 | ms | Duration of the visible light cone |
| LightBurst | `coneDistance` | 200 | px | Depth of the light cone polygon |
| LightBurst | `coneHeight` | 12 | factor | Lateral scale factor of the cone |
| LightBurst | `blindDuration` | 60 | frames | Frames enemies remain blinded |
| LightBurst | `selfDamage` | 1 | HP | HP the player loses each time the flash fires (0 = off) |

---

## Config.Projectile — Plungerang

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Projectile | `maxDistance` | 100 | px | Distance traveled before automatic return begins |
| Projectile | `speed` | 8 | px/frame | Linear outgoing speed and homing return speed |
| Projectile | `blindDuration` | 60 | frames | Blindness frames when hitting an enemy |

---

## Config.Doors — Doors

### Sprite Positions (fallback without LDTK coordinates)

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Doors.positions | `right` | `{x=393, y=122}` | px | Right door sprite position |
| Doors.positions | `left` | `{x=4, y=122}` | px | Left door sprite position |
| Doors.positions | `down` | `{x=203, y=228}` | px | Bottom door sprite position |
| Doors.positions | `top` | `{x=203, y=2}` | px | Top door sprite position |

### Player Spawn Coordinates in Destination Room

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Doors.spawnCoords | `top` | `{x=196, y=196}` | px | Spawn when entering from top door (appears at bottom) |
| Doors.spawnCoords | `down` | `{x=196, y=32}` | px | Spawn when entering from bottom door (appears at top) |
| Doors.spawnCoords | `right` | `{x=32, y=116}` | px | Spawn when entering from right door (appears at left) |
| Doors.spawnCoords | `left` | `{x=364, y=116}` | px | Spawn when entering from left door (appears at right) |

---

## Config.Portals — Portal Doors

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Portals | `collideRect` | `{x=0,y=0,w=24,h=24}` | px | Default collision rect when LDTK provides no size |

---

## Config.CrewMember — Crew AI

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| CrewMember | `hatDelta` | 15 | px | Hat position delta relative to crew member |
| CrewMember | `hidingTokensRequired` | 3 | tokens | Movement tokens needed to leave hiding spot |
| CrewMember | `hidingVisionRange` | 80 | px | Maximum player distance for crew member to leave hiding |
| CrewMember | `cornerDetectionThreshold` | 0.5 | px | Corner detection threshold |
| CrewMember | `bounceFrames` | 20 | frames | Frames of bounce in redirected direction |
| CrewMember | `bounceCountDecayRate` | 30 | frames | Frames before bounce counter decays |
| CrewMember | `bouncesRequiredToHide` | 2 | bounces | Consecutive bounces needed to trigger hiding |
| CrewMember | `blindDuration` | 60 | frames | Frames stunned when hit by plungerang |
| CrewMember | `framesPerToken` | 30 | frames | Movement frames per token received |
| CrewMember | `movementFramesCap` | 90 | frames | Maximum accumulated movement frames |
| CrewMember | `batteryThresholdStop` | 10 | % | Battery level where crew member stops moving (= `Battery.thresholdCritical`) |
| CrewMember | `batteryThresholdRestore` | 60 | % | Battery level where crew member restores movement (= `Battery.thresholdMid`) |
| CrewMember | `collideRect` | `{x=12,y=24,w=24,h=24}` | px | Crew member collision rect |

---

## Config.Screen — Screen Dimensions

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Screen | `width` | 400 | px | Canvas width (Playdate screen) |
| Screen | `height` | 240 | px | Canvas height |
| Screen | `randomBoundsX.min` | 20 | px | Minimum X bound for random entity spawning |
| Screen | `randomBoundsX.max` | 380 | px | Maximum X bound for random spawning |
| Screen | `randomBoundsY.min` | 20 | px | Minimum Y bound for random spawning |
| Screen | `randomBoundsY.max` | 220 | px | Maximum Y bound for random spawning |

---

## Config.Pedometer — Pedometer

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Pedometer | `stepsPerMovement` | 0.5 | steps | Steps added per `player:move()` call |
| Pedometer | `stepsToTrigger` | 200 | steps | Accumulated steps before burning calories |
| Pedometer | `caloriesPerBurn` | 10 | calories | Calories burned when threshold is reached |

---

## Config.Input — General Input

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Input | `crankMenuThreshold` | 30 | degrees | Crank rotation degrees to navigate menu |

---

## Config.Enemy — Enemy AI

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Enemy | `sightRadiusBase` | 150 | px | Base detection radius (minimum 50) |
| Enemy | `sightRadiusMin` | 50 | px | Minimum detection radius |
| Enemy | `sightRadiusPerPowerLevel` | 3 | px/level | Added to radius per powerLevel point |
| Enemy | `moveSpeedBatteryEmpty` | 0.2 | px/frame | Absolute speed when player battery == 0 in darkness |
| Enemy | `moveSpeedBatteryLow` | 0.5 | multiplier | Speed when `battery <= thresholdLow` in darkness |
| Enemy | `moveSpeedBatteryMid` | 0.7 | multiplier | Speed when `battery <= thresholdMid` in darkness |
| Enemy | `moveSpeedCritical` | 0.5 | px/frame | Absolute speed when `battery < thresholdCritical` in darkness |
| Enemy | `batteryThresholdLow` | 20 | % | Shared with `Battery.thresholdLow` |
| Enemy | `batteryThresholdMid` | 60 | % | Shared with `Battery.thresholdMid` |
| Enemy | `batteryThresholdCritical` | 10 | % | Shared with `Battery.thresholdCritical` |
| Enemy | `bounceFactor` | 3 | px | Push pixels when colliding with wall/prop/enemy |
| Enemy | `eatPropPowerThreshold` | 25 | level | Minimum powerLevel for an enemy to eat an edible prop |
| Enemy | `eatPropPowerPenalty` | 5 | pts | powerLevel lost after eating a prop |
| Enemy | `stunProcMultiplier` | 20 | factor | Multiplied by moveSpeed to calculate stun threshold |

---

## Config.Dance — Rhythm Combat

### Difficulties

| Section | Name | bpm | buttons | Description |
|---|---|---|---|---|
| Dance | `basic` | 16 | 4 | Basic difficulty |
| Dance | `evolve` | 24 | 6 | Medium difficulty |
| Dance | `badass` | 28 | 8 | Hard difficulty |
| Dance | `boss` | 32 | 12 | Boss difficulty |

### Normalization and Weights

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Dance | `sanityMax` | 100 | pts | Assumed sanityCounter ceiling for normalization |
| Dance | `powerMax` | 20 | pts | Assumed powerLevel ceiling for normalization |
| Dance | `caloriesMax` | 500 | pts | Assumed calorie ceiling for normalization |
| Dance | `weightSanity` | 0.35 | weight (0–1) | sanityCounter contribution to upgrade probability |
| Dance | `weightPower` | 0.45 | weight (0–1) | powerLevel contribution to upgrade probability |
| Dance | `weightCalories` | 0.20 | weight (0–1) | Calorie contribution to upgrade probability |

Weights sum to exactly 1.0.

---

## Config.Cockpit — Cockpit Scene

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Cockpit | `lerpFactor` | 0.15 | factor (0–1) | Pointer smoothing (0=frozen, 1=instant) |
| Cockpit | `accelSensitivity` | 2.0 | multiplier | Multiplier over raw accelerometer tilt |
| Cockpit | `pointerRadius` | 6 | px | Cursor circle radius |
| Cockpit | `dpadSpeed` | 3 | px/frame | Pointer speed with D-pad |
| Cockpit | `failLimit` | 10 | presses | Maximum incorrect button presses before returning to TitleScene |

---

## Config.Space — Space Scene

### Movement and Lerp

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Space | `crosshairSpeed` | 4 | px/frame | Crosshair speed |
| Space | `lerpFactor` | 0.08 | factor | Accelerometer smoothing in space |
| Space | `accelSensitivity` | 1.2 | multiplier | Accelerometer sensitivity in space |
| Space | `shipMoveLerp` | 0.12 | factor | Ship movement lerp |
| Space | `accelIdleThreshold` | 0.005 | units | Threshold to consider accelerometer at rest |
| Space | `accelIdleFrames` | 2 | frames | Frames at rest before considering idle |
| Space | `accelCenterReturnLerp` | 0.04 | factor | Return-to-center speed when idle |

### Speed and Danger

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Space | `speedDecay` | 0.05 | units/frame | Speed decay per frame |
| Space | `maxSpeed` | 20 | units | Maximum ship speed |
| Space | `minSpeed` | 3 | units | Minimum speed |
| Space | `dangerFillRate` | 0.002 | units/frame | Danger bar fill rate |
| Space | `dangerDrainRate` | 0.003 | units/frame | Danger bar drain rate |

### Meteorites

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Space | `meteoriteNearCount` | 14 | count | Number of near meteorites in the pool |
| Space | `meteoriteFarCount` | 10 | count | Number of far meteorites in the pool |
| Space | `meteoriteNearSpeed` | 3 | px/frame | Near meteorite speed |
| Space | `meteoriteFarSpeed` | 1.5 | px/frame | Far meteorite speed |
| Space | `meteoriteSpeedMult` | 0.2 | multiplier | Additional speed multiplier |
| Space | `parallaxSpeed` | 3 | px/frame | Base parallax speed |
| Space | `meteoriteFarParallax` | 0.5 | factor | Far meteorite parallax factor |
| Space | `meteoriteFarScale` | 0.6 | scale | Visual scale of far meteorites |

### Collision and Effects

| Section | Name | Value | Unit | Description |
|---|---|---|---|---|
| Space | `invincibilityFrames` | 60 | frames | Invincibility frames after impact |
| Space | `collisionZoneStart` | 0.90 | fraction (0–1) | Meteorite position (0=start, 1=end) at which collision becomes active |
| Space | `shakeFrames` | 25 | frames | Screen shake duration after impact |
| Space | `shakeMagnitude` | 6 | px | Maximum shake offset at start (decays to 0) |
