inGameMenu = {}
class('inGameMenu').extends(Graphics.sprite)
import "entities/props/hats"
import 'utilities/MapDrawer'

local shadow = Graphics.image.new(400,240)
local menuImage = Graphics.image.new('assets/images/ui/menu/ingame-menu')
local menuSprite = nil

-- Crew member hat images
local hatImages = {}
local hatSpriteSheet = Graphics.imagetable.new('assets/images/props/hats') 

function inGameMenu:init()
  self:moveTo(200,120)
  self:setZIndex(ZIndex.menu)
  self:setImage(shadow)

  -- Crear sprite para el menú
  menuSprite = Graphics.sprite.new()
  menuSprite:setImage(menuImage)
  menuSprite:setCenter(0.5, 0.5)
  menuSprite:moveTo(200, 120)
  menuSprite:setZIndex(ZIndex.menu + 2)

  self:add()
end

function inGameMenu:displayMenu()
    if not PlayerData.items.hasDWatch then return end
    PlayerData.isGaming = false
    PlayerData.isEquiping = true
    
    self:drawMapOnMenu()
    
    -- Create hat sprites when menu opens
    if PlayerData.CrewMemberData.amountTaken > 0 then
        self:drawCrewHats()
    end
end

function inGameMenu:drawMapOnMenu()
    -- Draw the map on the menu image
    MapDrawer.drawMap(menuImage)
end

function inGameMenu:drawCrewHats()
    -- Create sprites for captured crew member hats in the menu
    local hatX = 43  -- Starting X position for hats
    local hatY = 108  -- Starting Y position for hats
    local hatSpacing = 20  -- Space between hats
    local rowSpacing = 20  -- Space between rows
    local maxHatsPerRow = 7 -- Max hats before starting a new row
    
    -- Remove any existing hat sprites first
    if self.hatSprites then
        for _, hatSprite in ipairs(self.hatSprites) do
            if hatSprite then
                hatSprite:remove()
            end
        end
    end
    self.hatSprites = {}
    
    -- Check each crew member and create a sprite for their hat if captured
    if PlayerData.CrewMemberData and PlayerData.CrewMemberData.idNumbers then
        -- Iterate through a fixed range of possible IDs to ensure order and filtering
        -- There are 21 states defined in Hats.lua
        for i = 1, 21 do
            local crewId = string.format("CM%03d", i)
            local isCaptured = PlayerData.CrewMemberData.idNumbers[crewId]
            
            -- Explicitly check if the value is TRUE
            if isCaptured == true then
                -- Get the slot index from the ID (CM001 -> 0, CM002 -> 1, ...)
                local slotIndex = i - 1
                
                -- Create a sprite for this hat using its ID as the frame index
                local hatImage = hatSpriteSheet:getImage(i)
                if hatImage then
                    local hatSprite = Graphics.sprite.new(hatImage)
                    hatSprite:setCenter(0, 0)
                    local row = math.floor(slotIndex / maxHatsPerRow)
                    local col = slotIndex % maxHatsPerRow
                    hatSprite:moveTo(hatX + (col * hatSpacing), hatY + (row * rowSpacing))
                    hatSprite:setZIndex(ZIndex.menu + 9)
                    hatSprite:add()
                    table.insert(self.hatSprites, hatSprite)
                end
            end
        end
    end
end

function inGameMenu:closeMenu()
    shadow:clear(Graphics.kColorClear)
    if menuSprite then
        menuSprite:remove()
    end
    -- Remove hat sprites
    if self.hatSprites then
        for _, hatSprite in ipairs(self.hatSprites) do
            if hatSprite then
                hatSprite:remove()
            end
        end
        self.hatSprites = nil
    end
end

-- The menu is purely visual: it shows the map and the captured crew hats.
-- There is no skill/item selection — abilities fire from the B button directly.
function inGameMenu:update()
  if PlayerData.isEquiping == true then
    if menuSprite then
        menuSprite:add()
    end
  end
end