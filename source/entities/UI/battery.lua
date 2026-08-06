Battery = {}
class('Battery').extends(Graphics.sprite)



function Battery:init(x, y, player, Zindex)
    self.player = player
    
    self:setZIndex(Zindex)
    self:moveTo(x,y)
    self:add(x,y)
end


function Battery:update()
    if PlayerData.items.hasLamp == true then
        self.battery = PlayerData.battery
        
            local fillWidth = 27
            local batteryPercent = (self.battery * fillWidth) / Config.Battery.max
            
            local batteryFill = Graphics.image.new(fillWidth, 2)
            
            Graphics.pushContext(batteryFill)
                Graphics.setColor(Graphics.kColorBlack)
                Graphics.fillRect(0, 0, batteryPercent, 2)
            Graphics.popContext()
            self:setImage(batteryFill)
    end
end



