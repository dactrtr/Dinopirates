-- Only the debug-menu entry points need a generated FloorXXX class: the live game enters
-- MazeScene directly via the procedural run graph (RunState). Floor407 = debug "GAME",
-- Floor409 = debug "PLAYGROUND" (see TitleScene.lua).
local floorRanges = {
	{ start = 407, stop = 407 },
	{ start = 409, stop = 409 },
}

for _, range in ipairs(floorRanges) do
	for i = range.start, range.stop do
		local className = "Floor" .. i
		_G[className] = {}
		class(className).extends(MazeScene)

		_G[className].init = function(self)
			local level = math.floor(i / 100) -- 101 → 1, 220 → 2
			local room = i % 100              -- 101 → 1, 220 → 20
			self:setFloor(level, room)
			_G[className].super.init(self)
			PlayerData.saveLevel = i
		end

		_G[className].exit = function(self)
			_G[className].super.exit(self)
		end
	end
end

