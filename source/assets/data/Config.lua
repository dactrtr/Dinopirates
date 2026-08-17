Config = {}

-- Rendering layers
Config.ZIndex = {
    player     = 4,
    enemy      = 3,
    props      = 2,
    items      = 4,
    foreground = 300,
    fx         = 1999,
    ui         = 2000,
    hud        = 2000,
    menu       = 2100,
    alert      = 2200,
}

-- Collision groups
Config.CollideGroups = {
    player     = 1,
    enemy      = 2,
    props      = 3,
    items      = 4,
    wall       = 5,
    noCollide  = 6,
    crewMember = 7,
}

-- Tilemap
Config.Tiles = {
    size    = 16,
    IntGrid = {
        wall        = 1,
        slime       = 2,
        hole        = 3,
        floor       = 4,
        tinyHole    = 32,
        grapplePoint = 33,   -- hookable + walkable tile for the grappling hook
    }
}

-- Player movement
Config.Player = {
    speed            = 2,
    speedDarkNoLamp  = 0.7,   -- multiplier when in darkness without lamp
    speedLowBattery  = 0.8,   -- multiplier when battery < batteryThresholdLow with lamp
    collideRect      = {x=8,  y=24, w=30, h=24},
    collideRectTiny  = {x=19, y=32, w=10, h=10},
    collideRectHead  = {x=8,  y=8, w=16, h=16},
    uiOffsetX        = 30,
    uiOffsetY        = 30,
    feetOffsetY      = 12,   -- px from sprite position down to the player's feet (tile sampling / grapple landing)
    hudOffsetY       = -40,
    hudOffsetYTiny   = -17,
    triggerCheckDist        = 5,   -- px moved before re-checking triggers
    movementFramesPerAction = 3,   -- movement frames distributed to NPCs/enemies per player move
    movementTokensPerAction = 5,   -- movement tokens granted to enemies/crew when a B-ability actually fires
    knockbackDistance       = 2,   -- px pushed on enemy hit
    maxHealthPoints         = 10,  -- hard cap on healthPoints (HUD draws up to 10 dots)
    enemyContactDamage      = 1,   -- fallback HP lost on enemy contact when the enemy has no .damage
    danceThresholdHP        = 1,   -- fallback for PlayerData.danceThresholdHP (HP at/below which a hit triggers DanceScene)
    deathScreenDelay        = 1000,-- ms before the death screen transition fires
    wakeupPressesRequired   = 2,   -- A-button presses needed to wake the player
    hudEdgeTop              = 60,  -- px from top; below this the floating HUD flips under the player
    hudEdgeRight            = 350, -- px from left; past this the floating HUD flips to the player's left
    balancingSprite         = true,  -- swap the player sprite to 'balancing' while on hole/slime grace (false = keep walk sprite)
}

-- Dash ability (double-tap a D-pad direction to trigger)
Config.Dash = {
    speed          = 6,
    totalDistance  = 56,
    bounceDistance = 16,
    cooldown       = 500,   -- ms, dash-to-dash
    tapWindow      = 250,   -- ms, double-tap detection window
}

-- Microwave + Food healing
Config.Microwave = {
    hpPerFood       = 1,   -- HP restored per food cooked (1:1 for now; tune later)
    caloriesPerFood = 1,   -- calories gained per food cooked (byproduct; tune later)
    carryMax        = 10,  -- max food the player can carry
    perPickup       = 1,   -- food granted per food item picked up
    crankPerFood    = 1,   -- crank ticks (getCrankTicks(4)) accumulated to cook 1 food (~90 deg)
}

-- Procedural map generation (roguelike run graph)
Config.MapGen = {
    roomsBase         = 6,    -- minimum run size (rooms in the smallest run)
    crewPerExtraRoom  = 2,    -- recruit this many crew to grow the run by +1 room (lower = faster growth)
    roomsMax          = 20,   -- run size cap
    roomsPerCrewSpawn = 4,    -- spawn ~1 crew per this many rooms in a run (crew density)
    utilityChance     = 0.4,  -- prob. of populating a FeatureSlot with a microwave/minifier
    totalCrew         = 21,   -- full crew roster; recruiting all of them reveals the final room
    enemyChance       = 0.6,  -- prob. of populating an enemy marker
}

-- Dark Reveal skill (hold B + crank in darkness)
Config.DarkReveal = {
    minBattery            = 80,    -- minimum battery % required to start the crank charge
    holdDelay             = 400,   -- ms holding B before the crank charge starts (custom; SDK Held is fixed at 1000)
    crankThreshold        = 720,   -- degrees of total crank rotation required
    revealDuration        = 3000,  -- ms the full light lasts after activation
    rechargeBlockDuration = 3000,  -- ms recharge is blocked after reveal ends
    selfDamage            = 1,     -- HP the player loses each time the reveal fires (0 = no self-damage)
    shockDuration         = 1000,  -- ms the 'shock' animation plays on activation before reverting to idle
}

-- Grappling Hook (charged plungerang in lit rooms)
Config.Grapple = {
    holdDelay       = 400,   -- ms holding B before the crank charge starts
    minDistance     = 64,    -- px guaranteed on any release (~4 tiles)
    maxDistance     = 320,   -- px cap (~20 tiles)
    pixelsPerDegree = 0.4,   -- crank degrees -> launch distance
    projectileSpeed = 8,     -- px/frame the hook flies out
    pullSpeed       = 8,     -- px/frame the player slides toward the tile
    cooldown        = 500,   -- ms between uses (reserved; not yet enforced)
    ropeWidth       = 2,     -- px width of the black rope drawn from player to hook
}

-- Slide (slime). Two thresholds: the warning (HUD + balancing sprite) shows first, the slide
-- triggers later. Both measured in px of movement while the feet are over slime.
Config.Slide = {
    speed          = 4,
    warningPixels  = 0,     -- px before the warning shows (0 = the moment the player steps on)
    slidePixels    = 8,     -- px before the slide actually starts (~4 walk-frames of visible warning)
    warningEnabled = false,  -- false → slime slides immediately on contact (no grace/warning)
}

-- Hole fall grace ("balancing"). Two thresholds: the warning (HUD + balancing sprite) shows
-- first, the fall triggers later. Both measured in px of movement while over the hole.
Config.Hole = {
    warningPixels  = 0,  -- px before the warning shows (0 = the moment the player steps on)
    fallPixels     = 10,  -- px over a normal hole before the player falls (~4 walk-frames of warning)
    fallPixelsTiny = 8,  -- px over a tiny hole before falling (smaller player, smaller grace)
}

-- Invincibility
Config.Invincibility = {
    duration    = 1000,  -- ms after being hit
    flickerRate = 100,   -- divides timer for blink effect
}

-- Battery
Config.Battery = {
    max               = 100,   -- full charge cap (and HUD ceiling)
    chargePerCrankTick = 3,    -- battery gained per crank tick while charging in the maze
    chargeWhileTiny   = true, -- if false, the crank can't recharge the battery while the player is mini
    crankTicksPerRev  = 4,     -- getCrankTicks() resolution: ticks reported per full crank revolution
    drainMovementDark = 0.5,   -- per frame moving in darkness
    drainDWatchWalk   = 0.5,   -- per frame walking while carrying the DWatch (gated by movement.DRAIN_BATTERY_ON_WALK)

    -- Shared battery level thresholds used across Sanity, Enemy, and CrewMember systems
    thresholdCritical = 10,    -- critically low; enemies override speed, crew stops moving
    thresholdLow      = 20,    -- low; sanity drains faster, enemies slow down
    thresholdMid      = 60,    -- mid; enemies use reduced speed, crew restores movement
}

-- Sanity
Config.Sanity = {
    max                  = 100,   -- sanity cap (floor is always 0)
    baseLoss             = 1,     -- base multiplier applied to every gain/loss tick (read by checkSanityGlobal)
    tickInterval         = 2000,  -- ms between checks
    lossLowBattery       = 2,     -- multiplier per tick when battery < batteryThresholdLow
    lossMidBattery       = 1,     -- multiplier per tick when battery < batteryThresholdMid
    gainHighBattery      = 2,     -- multiplier per tick when battery > batteryThresholdHigh or not dark
    batteryThresholdLow  = Config.Battery.thresholdLow,  -- shared with Enemy
    batteryThresholdMid  = 40,
    batteryThresholdHigh = 50,
    focusCost            = 20,    -- sanity consumed by focus ability

    -- HUD face animation (sanityHud, 4 states) — switch when sanity drops below each value
    hudFace = {
        insane   = 30,   -- sanity < 30
        mediocre = 50,   -- sanity < 50
        normal   = 80,   -- sanity < 80
        good     = 100,  -- sanity < 100
    },
    -- HUD portrait animation (playerHud, 6 states) — switch when sanity is above each value
    hudPortrait = {
        s100 = 80,   -- sanity > 80
        s80  = 60,   -- sanity > 60
        s60  = 40,   -- sanity > 40
        s40  = 20,   -- sanity > 20
        s20  = 0,    -- sanity > 0 (else sanity0)
    },
}

-- Light Burst (lamp ability)
Config.LightBurst = {
    batteryCost   = 10,
    minBattery    = 10,     -- minimum battery % required to use (just enough to cover batteryCost)
    cooldown      = 1000,   -- ms
    displayTime   = 1000,   -- ms the cone stays visible
    coneDistance  = 200,    -- px forward
    coneHeight    = 12,     -- scaling factor
    blindDuration = 60,     -- frames enemies stay blinded
    selfDamage    = 0,      -- HP the player loses each time the flash fires (0 = no self-damage)
}

-- Projectile (plungerang)
Config.Projectile = {
    maxDistance   = 100,   -- px before returning
    speed         = 8,     -- px per frame
    blindDuration = 60,    -- frames enemies stay blinded on hit
}

-- Doors (screen positions and spawn offsets)
Config.Doors = {
    thickness = 8,   -- thin axis of a door's collide rect (px) — keeps doors from grabbing the player early
    span      = 48,  -- long axis of a door's collide rect (px) — width of the doorway opening
    spawnInsetTiny   = 16, -- px spawned inward from the entry door when tiny (smaller collider → spawns closer)
    spawnInsetNormal = 24, -- px spawned inward from the entry door at normal size (clears the door rect)
    positions = {
        right = {x=393, y=122},
        left  = {x=4,   y=122},
        down  = {x=203, y=228},
        top   = {x=203, y=2  },
    },
    spawnCoords = {
        top   = {x=196, y=196},
        down  = {x=196, y=32 },
        right = {x=32,  y=116},
        left  = {x=364, y=116},
    },
    -- Wall plug: when the graph leaves a door side unconnected, its opening is covered
    -- with wall brick stamped from the tilesheet, plus a collider so the player can't
    -- walk into the void. Tune these to your wall art.
    plug = {
        tilesheet  = 'assets/images/tile/tile-table-16-16',
        depthTiles = 1,    -- 16px tiles of cover depth from the screen edge (wall thickness)
        trimTiles  = 1,    -- extra tiles beyond the door span: up for side doors, each side for top/down
        tiles = {          -- tilesheet frame used as the wall fill, per side
            top   = 44,
            down  = 38,
            left  = 42,
            right = 40,
        },
    },
}

-- Portal Doors
Config.Portals = {
    collideRect = {x=0, y=0, w=24, h=24},
}

-- CrewMember AI
Config.CrewMember = {
    defaultSpeed             = 1.5,  -- escape/flee move speed
    hatDelta                 = 15,
    hidingTokensRequired     = 3,
    hidingVisionRange        = 80,   -- px
    cornerDetectionThreshold = 0.5,  -- px
    bounceFrames             = 20,
    bounceCountDecayRate     = 30,   -- frames
    bouncesRequiredToHide    = 2,
    blindDuration            = 60,   -- frames
    framesPerToken           = 30,
    movementFramesCap        = 90,
    batteryThresholdStop     = Config.Battery.thresholdCritical,  -- shared with Enemy.batteryThresholdCritical
    batteryThresholdRestore  = Config.Battery.thresholdMid,       -- shared with Enemy.batteryThresholdMid
    collideRect              = {x=12, y=24, w=24, h=24},
}

-- Ghost (CrewMember subclass; visible/touchable only when sanity is low)
Config.Ghost = {
    revealThreshold  = 30,   -- ghost visible/touchable when PlayerData.sanity < this
    defaultSpeed     = 1.5,   -- flee speed
    collideRect      = { x = 12, y = 12, w = 24, h = 24 }, -- tune to sprite
    achievementId    = "ghostbuster",
    achievementCount = 5,     -- banish this many to grant the achievement
    banishWhileTiny  = true,  -- if false, tiny contact does NOT banish (crew-like
                              -- pass-through instead). Currently true → banishes at any size.
}

-- Screen dimensions and random bounds
Config.Screen = {
    width         = 400,
    height        = 240,
    randomBoundsX = {min=20, max=380},
    randomBoundsY = {min=20, max=220},
}

-- Pedometer
Config.Pedometer = {
    stepsPerMovement = 0.5,
    stepsToTrigger   = 200,
    caloriesPerBurn  = 10,
    crankCalorieBurn = 1,   -- calories burned per crank tick while charging the battery
}

-- Input
Config.Input = {
    crankMenuThreshold = 30,   -- degrees of crank rotation to navigate menu
}

-- Map (in-game run graph map drawn in the menu)
Config.Map = {
    panel        = { x = 32, y = 18, w = 140, h = 75 }, -- rectangle on the menu image the map fits into
    maxCellSize  = 8,    -- cap on per-room box size (small runs stay small)
    cellGap      = 1,    -- gap between a box and its grid cell edge
    lineWidth    = 1,    -- connection line width
    ditherAlpha  = 0,  -- dither alpha for unvisited boxes/edges
    secretOffset = { col = 1, row = 0 }, -- cell offset for a visited secret node off its portal host
    roomColor    = Graphics.kColorWhite, -- fill color for room boxes and connection lines
    markerColor  = Graphics.kColorBlack, -- center of the current-room box (must contrast roomColor)
}

-- Enemy AI
Config.Enemy = {
    sightRadiusBase         = 150,  -- min 50; base detection radius stored in PlayerData.EnemiesData.sightRadius
    sightRadiusMin          = 50,
    sightRadiusPerPowerLevel = 3,   -- added to sightRadius per powerLevel point

    -- Move speed in darkness depending on player battery level
    moveSpeedBatteryEmpty   = 0.2,  -- absolute speed when player battery == 0 in darkness
    moveSpeedBatteryLow     = 0.5,  -- multiplier when battery <= batteryThresholdLow in darkness
    moveSpeedBatteryMid     = 0.7,  -- multiplier when battery <= batteryThresholdMid in darkness
    moveSpeedCritical       = 0.5,  -- absolute speed when battery < batteryThresholdCritical in darkness
    batteryThresholdLow      = Config.Battery.thresholdLow,      -- shared with Sanity.batteryThresholdLow
    batteryThresholdMid      = Config.Battery.thresholdMid,      -- shared with CrewMember.batteryThresholdRestore
    batteryThresholdCritical = Config.Battery.thresholdCritical, -- shared with CrewMember.batteryThresholdStop

    bounceFactor            = 3,    -- px pushed back on wall/prop/enemy collision
    eatPropPowerThreshold   = 25,   -- min powerLevel required for an enemy to eat an edible prop
    eatPropPowerPenalty     = 5,    -- powerLevel lost after eating a prop (cost of feeding)
    stunProcMultiplier      = 20,   -- multiplied by moveSpeed to compute stun threshold (enemy stops if below result)
}

-- Stealth-hunter perception (sight cone + light-scaled range, omnidirectional hearing).
-- Consumed by Enemy:perceive / Enemy:tick. All tunables live here — no magic numbers.
Config.Enemy.Perception = {
    coneHalfAngle      = 30,    -- degrees each side of the enemy heading for the sight cone
    lightFactorLit     = 2.0,   -- sight-range multiplier when the player is lit (lamp on)
    lightFactorDim     = 1,   -- darkness + mid battery
    lightFactorDark    = 0.5,   -- darkness + battery ~0 (nearly blind)
    hearDash           = 120,    -- px, omnidirectional hearing radius while the player dashes
    hearWalk           = 100,    -- px, hearing radius while the player walks
    hearIdle           = 0,     -- px, hearing radius while the player is still (inaudible)
    investigateTimeout = 120,   -- frames looking at lastKnownTile before giving up (-> PATROL)
}

-- Dance (rhythm combat)
Config.Dance = {
    -- Per-tier combat tuning. `sprite` is the enemy spritesheet for that tier (placeholder
    -- art until authored — DanceScene falls back to the base `enemyDance` sheet if the tier
    -- PNG doesn't exist yet, so missing art never crashes).
    basic  = { bpm = 16, buttons = 4,  sprite = 'assets/images/ui/battle/enemyDance'       },
    evolve = { bpm = 24, buttons = 6,  sprite = 'assets/images/ui/battle/enemyDanceEvolve'  },
    badass = { bpm = 28, buttons = 8,  sprite = 'assets/images/ui/battle/enemyDanceBadass'  },
    boss   = { bpm = 32, buttons = 12, sprite = 'assets/images/ui/battle/enemyDanceBoss'    },

    -- Difficulty scales with how many crew members have been recruited
    -- (PlayerData.CrewMemberData.amountTaken, 0..Config.MapGen.totalCrew). These are the
    -- minimum crew captured needed to reach each tier (below crewEvolve = basic). Tune freely.
    crewEvolve = 3,
    crewBadass = 6,
    crewBoss   = 9,

    caloriesMax = 500,  -- calorie clamp ceiling (microwave cooking + dance win gains)

    -- Accuracy pop-up (accuracyIndicator sprite). Each rating is a 6-frame band of the
    -- imagetable; frameDuration = ticks per frame (~0.36s per pop at 50fps).
    accuracyFrameDuration = 3,
    accuracyPerfectMin    = 4,  -- self.accuracy >= this on a correct press = PERFECT, else GOOD
}

-- Cockpit scene
Config.Cockpit = {
    lerpFactor       = 0.15,  -- pointer smoothing (0=frozen, 1=instant)
    accelSensitivity = 2.0,   -- multiplier on raw accelerometer tilt
    pointerRadius    = 6,     -- circle radius in px
    dpadSpeed        = 3,     -- pixels per frame when moving with d-pad
    failLimit        = 10,    -- max wrong button presses before returning to TitleScene
}

Config.Space = {
    crosshairSpeed        = 4,
    lerpFactor            = 0.08,
    accelSensitivity      = 1.2,
    shipMoveLerp          = 0.12,
    accelIdleThreshold    = 0.005,
    accelIdleFrames       = 2,
    accelCenterReturnLerp = 0.04,

    -- speed & danger
    speedDecay            = 0.05,
    maxSpeed              = 20,
    minSpeed              = 3,
    dangerFillRate        = 0.002,
    dangerDrainRate       = 0.003,

    -- meteorite pools
    meteoriteNearCount    = 14,
    meteoriteFarCount     = 10,
    meteoriteNearSpeed    = 3,
    meteoriteFarSpeed     = 1.5,
    meteoriteSpeedMult    = 0.2,
    parallaxSpeed         = 3,
    meteoriteFarParallax  = 0.5,
    meteoriteFarScale     = 0.6,

    -- collision
    invincibilityFrames   = 60,
    collisionZoneStart    = 0.90,  -- 0-1; meteorite must be this far into its approach before collision is live

    -- hit shake
    shakeFrames           = 25,    -- frames the shake lasts
    shakeMagnitude        = 6,     -- max px offset at start of shake (decays to 0)

    -- Animated background (SpaceBackground sprite): ticks per frame.
    backgroundFrameDuration = 6,

    -- Per-"finale" tuning. The finale is chosen in CockpitScene and passed to
    -- SpaceScene via Noble sceneProperties. `background` is an imagetable base path
    -- (SpaceScene probes it and falls back to the black background if the PNG is
    -- missing). `cutscene` is a comics[] key (see assets/comics/spaceFinales.lua).
    -- `maamaa` mirrors the legacy hardcoded values so the debug TitleScene->SpaceScene
    -- path is unchanged.
    finales = {
        good   = { lives = 5, dangerFillRate = 0.0012, nearCount = 10, farCount = 8,  nearSpeed = 2.5, farSpeed = 1.2, background = 'assets/images/space/bg_good',   cutscene = 'space-good'   },
        maamaa = { lives = 3, dangerFillRate = 0.0020, nearCount = 14, farCount = 10, nearSpeed = 3.0, farSpeed = 1.5, background = 'assets/images/space/bg_maamaa', cutscene = 'space-maamaa' },
        shura  = { lives = 2, dangerFillRate = 0.0032, nearCount = 18, farCount = 12, nearSpeed = 3.6, farSpeed = 1.9, background = 'assets/images/space/bg_shura',  cutscene = 'space-shura'  },
    },
}

return Config
