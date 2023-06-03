
class('TestEntity').extends(Graphics.sprite)

function TestEntity:init()
	print("test initialized")	
end

function TestEntity:draw()
	print("drawing running")
	local background = Graphics.image.new(100, 100)
	Graphics.pushContext(background)
		Graphics.fillCircleAtPoint(50, 50, 20)
	Graphics.popContext()
	local BG = Graphics.sprite.new(background)
	BG:setZIndex(0)
	BG:moveTo(200, 140)
	BG:add()
		
end
function TestEntity:update()

end