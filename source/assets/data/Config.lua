Config = {}

-- Rendering layers
Config.ZIndex = {
    player = 4,
    enemy  = 3,
    props  = 2,
    items  = 4,
    fx     = 1999,
    ui     = 2000,
    hud    = 2000,
    menu   = 2100,
    alert  = 2200,
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
    size     = 16,
    walkable = {1,2,3,5,6,50,66,67,68,69,72,73,74,75,77,79,80,81,82,89,90,91,92,93,94,95,96,97,98},
    slime    = {89,90,91,92,93,94,95,96,97,98},
}

-- Player movement
Config.Player = {
    speed            = 1.5,
    speedDarkNoLamp  = 0.7,   -- multiplier when in darkness without lamp
    speedLowBattery  = 0.8,   -- multiplier when battery < batteryThresholdLow with lamp
    collideRect      = {x=8,  y=24, w=30, h=24},
    collideRectTiny  = {x=19, y=32, w=10, h=10},
    uiOffsetX        = 30,
    uiOffsetY        = 30,
    hudOffsetY       = -40,
    hudOffsetYTiny   = -17,
    triggerCheckDist = 5,     -- px moved before re-checking triggers
}

-- Dash ability
Config.Dash = {
    speed          = 6,
    totalDistance  = 56,
    bounceDistance = 16,
    batteryCost    = 10,
    cooldown       = 500,   -- ms
}

-- Slide (slime)
Config.Slide = {
    speed = 4,
}

-- Invincibility
Config.Invincibility = {
    duration    = 1000,  -- ms after being hit
    flickerRate = 100,   -- divides timer for blink effect
}

-- Battery
Config.Battery = {
    drainMovementDark = 0.5,   -- per frame moving in darkness
    drainHoleNormal   = 0.5,   -- per frame crossing a hole (normal size)
    drainHoleTiny     = 0.2,   -- per frame crossing a hole (tiny)
}

-- Sanity
Config.Sanity = {
    tickInterval         = 2000,  -- ms between checks
    lossLowBattery       = 2,     -- multiplier per tick when battery < batteryThresholdLow
    lossMidBattery       = 1,     -- multiplier per tick when battery < batteryThresholdMid
    gainHighBattery      = 2,     -- multiplier per tick when battery > batteryThresholdHigh or not dark
    batteryThresholdLow  = 20,
    batteryThresholdMid  = 40,
    batteryThresholdHigh = 50,
    focusCost            = 20,    -- sanity consumed by focus ability
}

-- Light Burst (lamp ability)
Config.LightBurst = {
    batteryCost   = 10,
    cooldown      = 1000,   -- ms
    displayTime   = 1000,   -- ms the cone stays visible
    coneDistance  = 200,    -- px forward
    coneHeight    = 12,     -- scaling factor
    blindDuration = 60,     -- frames enemies stay blinded
}

-- Projectile (plungerang)
Config.Projectile = {
    maxDistance   = 100,   -- px before returning
    speed         = 8,     -- px per frame
    blindDuration = 60,    -- frames enemies stay blinded on hit
}

-- Doors (screen positions and spawn offsets)
Config.Doors = {
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
}

-- CrewMember AI
Config.CrewMember = {
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
    batteryThresholdStop     = 10,   -- stops moving
    batteryThresholdRestore  = 60,   -- restores speed
    collideRect              = {x=12, y=24, w=24, h=24},
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
}

return Config
