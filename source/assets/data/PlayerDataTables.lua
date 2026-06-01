-- Helper function for deep copying tables
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Define the default state (Single Source of Truth)
local DefaultPlayerData = {
	x = 200,
	y = 200, 
	speed = Config.Player.speed,
	healthPoints = 3,
	danceThresholdHP = 1,
	healedHP = 2,
	battery = 100, 
	sanity = 100,
	calories = 100, -- top 500
	food = 0, -- raw food carried; cooked at a microwave to heal
	steps = 0,
	totalSteps = 1000,
	sanityCounter = 0, -- top 100
	mapPercent = 0, -- Percentage of map explored (0-100)
	keys = {}, -- Table to store collected keys by number: {[1] = true, [2] = true, ...}
	canDance = false,
	readyToShrink = false,
	readyToCook = false,
	isTiny = false,
	isBig = false,
	playerSize = 10 ,
	actualPlayerSize = 10,
	sonarActive = false,
	storyCounter = 0,
	isActive = false, -- makes npc moves while charges the battery
	isTalking = false,
	isCutscene = false,
	isFocused = false,
	isCharging = false,
	isEquiping = false,
	floor = 1,
	room = 1,
	isGaming = false,
	fromTitle = false,
	isDancing = false,
	amountDances = 0,
	isInDarkness = false,
	showLightCone = false,
	showFullLight    = false,  -- Dark Reveal skill active
	rechargeBlocked  = false,  -- blocks crank battery recharge after Dark Reveal
	direction = "idle",
	lastRoom = nil,
	actualLevel = nil,
	actualRoom = nil,
	actualTilemap = nil,
	saveLevel= nil,
	playerSpawn ={
		x = 200,
		y = 200,
	},
	playerExit ={
		x = nil,
		y = nil,
	},
	lastEnemyTouched ={
		type = nil,
		id = nil,
		x = nil,
		y = nil
	},
	items={
		hasLamp = false,
		hasRadio = true,
		hasDWatch = false,
		hasNotes = true,
		hasBoots = false,
		hasPlunger = false,
	},
	skills ={
		canFlash = false,
		canPlungerang = false,
	},
	EnemiesData ={
		powerLevel = 1, -- max 20
		sightRadius = Config.Enemy.sightRadiusBase,
		isEvolved = false,
	},
	CrewMemberData ={
		amountTaken = 0,
		idNumbers={
			
		}
	}
}

-- Initialize PlayerData with a copy of the default
PlayerData = deepcopy(DefaultPlayerData)

-- Global function to reset PlayerData to default state
function ResetPlayerData()
	PlayerData = deepcopy(DefaultPlayerData)
	printDebug("🔄 PlayerData has been reset to defaults")
end
