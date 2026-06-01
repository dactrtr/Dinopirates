local floorRanges = {
	{ start = 166, stop = 180 },
	{ start = 231, stop = 274 },
	{ start = 316, stop = 330 },
	{ start = 401, stop = 415 },
	{ start = 481, stop = 481 }
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

