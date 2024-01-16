
TestEntity = {}
class("TestEntity").extends(NobleSprite)

function TestEntity:init(__x, __y, __anotherFunArgument)
	Player.super.init(self,nil, true)
end

