class('Screen').extends(Graphics.image)

local eyes = Graphics.image.new('assets/images/player/eyes.png')
local mouth = Graphics.image.new('assets/images/player/mouth.png')
local body = Graphics.image.new('assets/images/player/body.png')

local normal = Graphics.image.new("assets/images/player/hud.png")


function PlayerHud:init(status)
  self:add()
end

function PlayerHud:update()
  
end

