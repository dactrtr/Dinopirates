Battery = {}
class('Battery').extends(Graphics.sprite)

import 'entities/player/batteryCanister'

function Battery:init(x,y,player)
    self.player = player
    batteryCanister = BatteryCanister(x,y)
    self:setZIndex(11)
    self:moveTo(x-1,y)
    self:add()
end

function Battery:update()
    self.battery = self.player.battery
    batteryPercent = (self.battery * 24) / 100
    
    local batteryFill = Graphics.image.new(24,6)
    Graphics.pushContext(batteryFill)
        Graphics.setColor(Graphics.kColorWhite)
        Graphics.fillRect(0, 0, batteryPercent,6)
    Graphics.popContext()
    
    self:setImage(batteryFill)
end
function Battery:removeAll()
    batteryCanister:remove()
    self:remove()
end


