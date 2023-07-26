
TestEntity = {}
class("TestEntity").extends(NobleSprite)

function TestEntity:init(__x, __y, __anotherFunArgument)
	TestEntity.super.init(self, 'assets/images/ship/ship', true)
	self.animation:addState('idle', 1, 3)
	print(__anotherFunArgument)
	self:setSize(80,40)
	self:add(__x, __y)
end

