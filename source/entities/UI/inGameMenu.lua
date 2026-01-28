inGameMenu = {}
class('inGameMenu').extends(Graphics.sprite)
import "entities/UI/itemMenu"
import "entities/props/hats"
import 'utilities/MapDrawer'

local shadow = Graphics.image.new(400,240)
local menuImage = Graphics.image.new('assets/images/ui/menu/ingame-menu')
local menuSprite = nil

-- Crew member hat images
local hatImages = {}
local hatSpriteSheet = Graphics.imagetable.new('assets/images/props/hats') 

function inGameMenu:init()
  self.activeItem = PlayerData.activeItem 
  
  self:moveTo(200,120)
  self:setZIndex(ZIndex.menu)
  self:setImage(shadow)
  
  
  -- Crear sprite para el menú
  menuSprite = Graphics.sprite.new()
  menuSprite:setImage(menuImage)
  menuSprite:setCenter(0.5, 0.5)
  menuSprite:moveTo(200, 120)
  menuSprite:setZIndex(ZIndex.menu + 2)
  
  lampItem = itemMenu("lamp",ZIndex.menu+3)
  bootItem = itemMenu("boot",ZIndex.menu+3)
  plungerItem = itemMenu("plunger",ZIndex.menu+3)
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
    lampItem:remove()
    bootItem:remove()
    plungerItem:remove()
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
    
    -- remove all the icons also
end

function inGameMenu:prevItem()
    local activeSkills = self:getActiveSkillsList()
    if #activeSkills == 0 then return end -- No skills available
    
    -- Find current position in active skills list
    local currentIndex = 1
    for i, skillId in ipairs(activeSkills) do
        if PlayerData.activeItem == skillId then
            currentIndex = i
            break
        end
    end
    
    -- Go to previous skill (with wraparound)
    currentIndex = currentIndex - 1
    if currentIndex < 1 then
        currentIndex = #activeSkills
    end
    PlayerData.activeItem = activeSkills[currentIndex]
end

function inGameMenu:nextItem()
    local activeSkills = self:getActiveSkillsList()
    if #activeSkills == 0 then return end -- No skills available
    
    -- Find current position in active skills list
    local currentIndex = 1
    for i, skillId in ipairs(activeSkills) do
        if PlayerData.activeItem == skillId then
            currentIndex = i
            break
        end
    end
    
    -- Go to next skill (with wraparound)
    currentIndex = currentIndex + 1
    if currentIndex > #activeSkills then
        currentIndex = 1
    end
    PlayerData.activeItem = activeSkills[currentIndex]
end

function inGameMenu:selectItem()
    printDebug("Item selected: " .. PlayerData.activeItem)
    -- Aquí puedes agregar la lógica específica para cada item
    if PlayerData.activeItem == 1 and PlayerData.skills.canFlash == true then
        printDebug("flash selected!")
        -- Acción para la lámpara
    elseif PlayerData.activeItem == 2 and PlayerData.skills.canDash == true then
        printDebug("dash selected!")
        -- Acción para las botas
    elseif PlayerData.activeItem == 3 and PlayerData.skills.canPlungerang == true then
        printDebug("plunge selected!")
        -- Acción para el desatascador
    end
end

-- Helper function to count active skills (skills that are true)
function inGameMenu:getActiveSkillsCount()
    local count = 0
    if PlayerData.skills.canFlash == true then count = count + 1 end
    if PlayerData.skills.canDash == true then count = count + 1 end
    if PlayerData.skills.canPlungerang == true then count = count + 1 end
    return count
end

-- Helper function to get list of active skills in order
function inGameMenu:getActiveSkillsList()
    local skills = {}
    if PlayerData.skills.canFlash == true then table.insert(skills, 1) end  -- 1 = Flash/Lamp
    if PlayerData.skills.canDash == true then table.insert(skills, 2) end   -- 2 = Dash/Boot
    if PlayerData.skills.canPlungerang == true then table.insert(skills, 3) end  -- 3 = Plunge/Plunger
    return skills
end

function inGameMenu:update()
  if PlayerData.isEquiping == true then
    -- drawStatusText(menuImage)
    
    local activeSkillsCount = self:getActiveSkillsCount()
    local activeSkills = self:getActiveSkillsList()
    
    -- If no skills are active, reset activeItem to 0 and don't allow selection
    if activeSkillsCount == 0 then
        PlayerData.activeItem = 0
    else
        -- Make sure activeItem is a valid skill
        local isValidItem = false
        for _, skillId in ipairs(activeSkills) do
            if PlayerData.activeItem == skillId then
                isValidItem = true
                break
            end
        end
        
        -- If current activeItem is not valid, set to first available skill
        if not isValidItem then
            PlayerData.activeItem = activeSkills[1]
        end
        
        -- Handle cycling through only available skills
        if PlayerData.activeItem < activeSkills[1] then
            PlayerData.activeItem = activeSkills[#activeSkills]
        end
        if PlayerData.activeItem > activeSkills[#activeSkills] then
            PlayerData.activeItem = activeSkills[1]
        end
    end

    -- This should ALWAYS happen if isEquiping is true
    if menuSprite then
        menuSprite:add()
    end
    
    -- Show active skill icons
    if PlayerData.items.hasLamp == true then
        lampItem:show(320, 64)
    end
    if PlayerData.items.hasBoots == true then
        bootItem:show(288, 128)
    end
    if PlayerData.items.hasPlunger == true then
        plungerItem:show(256, 128) -- Positioned next to boot
    end
  end
end