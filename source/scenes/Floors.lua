Floor01= {
}
class("Floor01").extends(MazeScene)

function Floor01:init()
	self:setFloor(1)
	Floor01.super.init(self)
end

Floor02= {
}
class("Floor02").extends(MazeScene)

function Floor02:init()
	self:setFloor(2)
	Floor02.super.init(self)
end
