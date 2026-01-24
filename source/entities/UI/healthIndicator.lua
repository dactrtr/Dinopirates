HealthIndicator = {}
class('HealthIndicator').extends(Graphics.sprite)

function HealthIndicator:init(x, y, player, Zindex)
    self.player = player
    self:setZIndex(Zindex)
    self:setCenter(0.5, 0.5)
    self:moveTo(x, y)
    self:add(x, y)
    self.healthPoints = -1 -- Force initial update
end

function HealthIndicator:update()
    -- Explicitly checking the global PlayerData
    local currentHP = 0
    if PlayerData and PlayerData.healthPoints then
        currentHP = math.max(0, PlayerData.healthPoints)
    end
    
    if currentHP ~= self.healthPoints then
        self.healthPoints = currentHP        
        -- Health indicator is 35x15, same as HUD
        local healthImg = Graphics.image.new(35, 15)
        
        Graphics.pushContext(healthImg)
            Graphics.setColor(Graphics.kColorBlack)
            
            -- User's preferred coordinates (overlapping)
            local xPositions = {4, 5, 10, 11, 16, 17, 22, 23, 28, 29}
            local yPos = 8
            local spotWidth = 2
            local spotHeight = 3
            
            for i = 1, self.healthPoints do
                if xPositions[i] then
                    Graphics.fillRect(xPositions[i], yPos, spotWidth, spotHeight)
                end
            end
        Graphics.popContext()
        self:setImage(healthImg)
    end
end
