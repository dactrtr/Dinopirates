import 'entities/space/Ship'
import 'entities/space/Crosshair'
import 'entities/space/FXspeed'
import 'entities/space/Meteorite'
import 'entities/space/Laser'
import 'entities/space/EnergyMeter'
import 'entities/space/DangerBar'
import 'entities/space/HealthDisplay'

SpaceScene = {}
class('SpaceScene').extends(NobleScene)
local scene = SpaceScene

scene.backgroundColor = Graphics.kColorBlack

local ship          = nil
local crosshair     = nil
local fxspeed       = nil
local laser         = nil
local energy        = nil
local dangerBar     = nil
local healthDisplay = nil

local meteoritesNear = {}
local meteoritesFar  = {}

local cursorX    = 200
local cursorY    = 120
local baseAx     = 0
local baseAy     = 0
local calibrated = false
local prevAx     = 0
local prevAy     = 0
local idleFrames = 0

local danger     = 0
local health     = 3
local invFrames  = 0
local shakeFrames = 0

local shipX = 200
local shipY = 150

function scene:init()
    scene.super.init(self)
end

function scene:enter()
    scene.super.enter(self)

    cursorX    = 200
    cursorY    = 120
    baseAx     = 0
    baseAy     = 0
    calibrated = false
    prevAx     = 0
    prevAy     = 0
    idleFrames = 0
    danger      = 0
    health      = 3
    invFrames   = 0
    shakeFrames = 0

    ship      = Ship(shipX, shipY, 4, 0, ZIndex.player)
    crosshair = Crosshair(200, 134)
    fxspeed   = FXspeed()
    laser     = Laser()
    energy    = EnergyMeter(ship)

    for i = 1, Config.Space.meteoriteNearCount do
        meteoritesNear[i] = Meteorite(math.random(0, 400), math.random(8, 232), Config.Space.meteoriteNearSpeed)
    end
    for i = 1, Config.Space.meteoriteFarCount do
        local m = Meteorite(math.random(0, 400), math.random(8, 232), Config.Space.meteoriteFarSpeed)
        m:setScale(Config.Space.meteoriteFarScale)
        meteoritesFar[i] = m
    end

    dangerBar     = DangerBar()
    healthDisplay = HealthDisplay(energy.xPos - 28, energy.yPos)

    playdate.startAccelerometer()
end

function scene:start()
    scene.super.start(self)
end

function scene:update()
    scene.super.update(self)

    if ship == nil then return end

    -- crosshair: fighter mode only
    if ship.mode == 'fighter' then
        local ax, ay = playdate.readAccelerometer()
        ax = ax or 0
        ay = ay or 0

        if not calibrated and (ax ~= 0 or ay ~= 0) then
            baseAx     = ax
            baseAy     = ay
            calibrated = true
        end

        local accelMoving = math.abs(ax - prevAx) >= Config.Space.accelIdleThreshold
                         or math.abs(ay - prevAy) >= Config.Space.accelIdleThreshold

        local spd   = Config.Space.crosshairSpeed
        local moved = false
        if playdate.buttonIsPressed(playdate.kButtonUp)    then cursorY = math.max(0,   cursorY - spd) moved = true end
        if playdate.buttonIsPressed(playdate.kButtonDown)  then cursorY = math.min(Config.Screen.height, cursorY + spd) moved = true end
        if playdate.buttonIsPressed(playdate.kButtonLeft)  then cursorX = math.max(0,                    cursorX - spd) moved = true end
        if playdate.buttonIsPressed(playdate.kButtonRight) then cursorX = math.min(Config.Screen.width,  cursorX + spd) moved = true end

        local sens  = Config.Space.accelSensitivity
        local halfW = Config.Screen.width  / 2
        local halfH = Config.Screen.height / 2
        if moved then
            baseAx = ax - (cursorX - halfW) / (halfW * sens)
            baseAy = ay - (cursorY - halfH) / (halfH * sens)
            calibrated = true
        end

        if accelMoving or moved then
            idleFrames = 0
        else
            idleFrames = idleFrames + 1
            if idleFrames >= Config.Space.accelIdleFrames and calibrated then
                local lr = Config.Space.accelCenterReturnLerp
                baseAx = baseAx + (ax - baseAx) * lr
                baseAy = baseAy + (ay - baseAy) * lr
            end
        end
        prevAx = ax
        prevAy = ay

        local targetX = math.max(0, math.min(Config.Screen.width,  halfW + (ax - baseAx) * halfW * sens))
        local targetY = math.max(0, math.min(Config.Screen.height, halfH + (ay - baseAy) * halfH * sens))
        local lf      = Config.Space.lerpFactor
        cursorX = cursorX + (targetX - cursorX) * lf
        cursorY = cursorY + (targetY - cursorY) * lf

        crosshair:moveTo(cursorX, cursorY)
    end

    -- speed decay: fighter mode only; travel mode holds speed
    if ship.mode == 'fighter' then
        ship.speed = math.max(0, ship.speed - Config.Space.speedDecay)
    end

    -- danger bar
    if ship.mode == 'fighter' and ship.speed < Config.Space.minSpeed then
        danger = math.min(1, danger + Config.Space.dangerFillRate)
    elseif ship.speed >= Config.Space.minSpeed then
        danger = math.max(0, danger - Config.Space.dangerDrainRate)
    end
    dangerBar:setDanger(danger)
    if danger >= 1 then
        Noble.transition(TitleScene)
        return
    end

    -- meteorite zoom + d-pad parallax
    local py, px = 0, 0
    if playdate.buttonIsPressed(playdate.kButtonUp)    then py =  Config.Space.parallaxSpeed end
    if playdate.buttonIsPressed(playdate.kButtonDown)  then py = -Config.Space.parallaxSpeed end
    if playdate.buttonIsPressed(playdate.kButtonLeft)  then px =  Config.Space.parallaxSpeed end
    if playdate.buttonIsPressed(playdate.kButtonRight) then px = -Config.Space.parallaxSpeed end

    local shipBonus = ship.speed * Config.Space.meteoriteSpeedMult
    local farMult   = Config.Space.meteoriteFarParallax

    for i = 1, #meteoritesNear do
        meteoritesNear[i]:step(shipBonus)
        if px ~= 0 or py ~= 0 then meteoritesNear[i]:scrollBy(px, py) end
    end
    for i = 1, #meteoritesFar do
        meteoritesFar[i]:step(shipBonus)
        if px ~= 0 or py ~= 0 then meteoritesFar[i]:scrollBy(px * farMult, py * farMult) end
    end

    -- collision detection (Z-gated: only meteorites past collisionZoneStart depth can hit)
    if invFrames > 0 then
        invFrames -= 1
    else
        local overlapping = ship:overlappingSprites()
        local hit = false
        for _, s in ipairs(overlapping) do
            for j = 1, #meteoritesNear do
                local m = meteoritesNear[j]
                if s == m then
                    local z = m:getZDepth()
                    print("OVERLAP near["..j.."] z="..string.format("%.2f",z).." counter="..math.floor(m.counter).." frame="..m.imgTable:getLength())
                    if z >= Config.Space.collisionZoneStart then
                        print("  -> HIT near["..j.."]")
                        hit = true
                    else
                        print("  -> too far, skip")
                    end
                    break
                end
            end
            if not hit then
                for j = 1, #meteoritesFar do
                    local m = meteoritesFar[j]
                    if s == m then
                        local z = m:getZDepth()
                        print("OVERLAP far["..j.."] z="..string.format("%.2f",z).." counter="..math.floor(m.counter))
                        if z >= Config.Space.collisionZoneStart then
                            print("  -> HIT far["..j.."]")
                            hit = true
                        else
                            print("  -> too far, skip")
                        end
                        break
                    end
                end
            end
            if hit then break end
        end
        if hit then
            health       -= 1
            invFrames     = Config.Space.invincibilityFrames
            shakeFrames   = Config.Space.shakeFrames
            healthDisplay:setHealth(health)
            if health <= 0 then
                Noble.transition(TitleScene)
                return
            end
        end
    end

    -- ship shake on hit: random offset that decays with remaining frames
    if shakeFrames > 0 then
        shakeFrames -= 1
        local mag = math.ceil(shakeFrames / Config.Space.shakeFrames * Config.Space.shakeMagnitude)
        ship:moveTo(ship.x + math.random(-mag, mag), ship.y + math.random(-mag, mag))
    end
end

function scene:exit()
    scene.super.exit(self)

    playdate.stopAccelerometer()

    if ship          then ship:remove()          ship          = nil end
    if crosshair     then crosshair:remove()     crosshair     = nil end
    if fxspeed       then fxspeed:remove()       fxspeed       = nil end
    if laser         then laser:remove()         laser         = nil end
    if energy        then energy:remove()        energy        = nil end
    if dangerBar     then dangerBar:remove()     dangerBar     = nil end
    if healthDisplay then healthDisplay:remove() healthDisplay = nil end

    for i = 1, #meteoritesNear do meteoritesNear[i]:remove() end
    for i = 1, #meteoritesFar  do meteoritesFar[i]:remove()  end
    meteoritesNear = {}
    meteoritesFar  = {}
end

function scene:finish()
    scene.super.finish(self)
    Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
end

scene.inputHandler = {
    AButtonDown = function()
        if ship and ship.mode == 'fighter' then
            laser:draw(ship, crosshair, energy)
        end
    end,

    BButtonDown = function()
        if ship and ship.mode == 'fighter' and ship.energy > 0 then
            fxspeed.animation:setState('startSpeed')
        end
    end,
    BButtonHeld = function()
        if ship == nil or ship.mode ~= 'fighter' then return end
        if ship.energy > 0 then
            fxspeed.animation:setState('loopSpeed')
        else
            fxspeed.animation:setState('stopSpeed')
        end
    end,
    BButtonHold = function()
        if ship == nil or ship.mode ~= 'fighter' then return end
        if ship.energy > 0 then
            ship:boost('fighter')
            energy:drain(ship)
        end
        if ship.energy == 0 then
            fxspeed.animation:setState('stopSpeed')
        end
    end,
    BButtonUp = function()
        if ship == nil or ship.mode ~= 'fighter' then return end
        if ship.energy > 0 and ship.speed > 0 then
            fxspeed.animation:setState('stopSpeed')
        elseif ship.energy == 0 then
            fxspeed.animation:setState('initial')
        end
    end,

    leftButtonDown  = function() if ship then ship:move('left')    end end,
    leftButtonUp    = function() if ship then ship:move('default') end end,
    rightButtonDown = function() if ship then ship:move('right')   end end,
    rightButtonUp   = function() if ship then ship:move('default') end end,
    upButtonDown    = function() if ship then ship:move('up')      end end,
    upButtonUp      = function() if ship then ship:move('default') end end,
    downButtonDown  = function() if ship then ship:move('down')    end end,
    downButtonUp    = function() if ship then ship:move('default') end end,

    cranked = function(change, _)
        if ship and ship.mode == 'travel' and ship.energy <= 100 and playdate.getCrankTicks(3) > 0 then
            energy:fill(ship, 1)
        end
    end,

    crankDocked = function()
        if ship == nil then return end
        ship.changeMode = true
        ship.mode       = 'fighter'
        ship.animation:setState('travelToFighter')
        ship:setTarget(shipX, shipY)
        energy:resetPosition(shipX, shipY)
        if healthDisplay then healthDisplay:moveTo(energy.xPos - 28, energy.yPos) end
        calibrated = false
    end,

    crankUndocked = function()
        if ship == nil then return end
        ship.changeMode = true
        ship.mode       = 'travel'
        ship.animation:setState('fighterToTravel')
        ship:setTarget(shipX, shipY + 20)
        energy:resetPosition(shipX, shipY + 20)
        if healthDisplay then healthDisplay:moveTo(energy.xPos - 28, energy.yPos) end
        cursorX    = 200
        cursorY    = 120
        calibrated = false
        if crosshair then crosshair:moveTo(200, 120) end
    end,
}
