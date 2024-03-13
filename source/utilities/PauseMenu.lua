local menuImg = Graphics.image.new('assets/images/ui/menu/menu.png')

function playdate.gameWillPause()
	if PlayerData.isGaming == true then
		local alpha = 0.5
		local roomSize = 7
		local row = 0
		local col = 0
		local posX = 0
		local posY = 0
		
		for i = 1, table.getsize(levels) do 
			if levels[i].floor.visited == false then
				if levels[i].floor.level == 1 then
					posX = 40
					posY = 26
				elseif levels[i].floor.level == 2 then
					posX = 40
					posY = 62
				end
					col = (i - 1) % 5
					row = math.floor((i - 1) / 5)
					
					Graphics.pushContext(menuImg)
					Graphics.setColor(Graphics.kColorBlack)
					Graphics.setDitherPattern(alpha, Graphics.image.kDitherTypeBayer8x8)
					Graphics.fillRect(posX + (col * 6), posY + (row * 6), roomSize, roomSize)
					
					Graphics.popContext() 
			end
		 end
		
		playdate.setMenuImage(menuImg)
	end
end
