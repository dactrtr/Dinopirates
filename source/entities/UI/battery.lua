Battery = {}
class('Battery').extends(Graphics.sprite)

import 'entities/UI/batteryCanister'

function Battery:init(x, y, player, Zindex)
    self.player = player
    batteryCanister = BatteryCanister(x,y,Zindex)
    self:setZIndex(Zindex-1)
    self:moveTo(x,y)
    self:add(0,0)
end

function Battery:update()
    if PlayerData.hasLamp == true then
        self.battery = PlayerData.battery
        local batteryPercent = (self.battery * (batteryCanister.width - 8)) / 100
        
        local batteryFill = Graphics.image.new(batteryCanister.width - 8, 6)
        
        Graphics.pushContext(batteryFill)
            Graphics.setColor(Graphics.kColorBlack)
            Graphics.fillRect(0, 0, batteryPercent,6)
        Graphics.popContext()
        self:setImage(batteryFill)
        batteryCanister:add()
    else
        batteryCanister:remove()
    end
end



