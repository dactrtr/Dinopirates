local achievementData = {
	iconPath = "assets/launcher/icon",
	cardPath = "assets/images/achievements/card",
	achievements = {
		{
			id = "wakeup",
			name = "What a nap captn",
			descriptionLocked = "Just a little nap and I continue working",
			description = "Wakey wakey eggs and Brocolli",
			icon = "assets/images/achievements/achievements-1",
			scoreValue = 2
		},
		{
			id = "comms",
			name = "Moshi moshi",
			description = "Dunno, are this calls helping?",
			isSecret = true,
			icon = "assets/images/achievements/achievements-3"
		},
		{
			id = "sanityloss1",
			name = "afraid of the dark?",
			description = "too much time alone and in the darkness can make you crazy",
			isSecret = true,
			icon = "assets/images/achievements/achievements-4"
		},
		{
			id = "sanityloss2",
			name = "Hello darkness...",
			description = "this is the first step into the abbyss",
			isSecret = true,
			icon = "assets/images/achievements/achievements-5"
		},
		{
			id = "microwaveBurn",
			name = "Was my mom's microwave",
			description = "How are we gonna make tacos now?",
			isSecret = true,
			icon = "assets/images/achievements/achievements-6"
		},
		{
			id = "cartographer",
			name = "I've seen this corridor before",
			descriptionLocked = "Every room on this ship. Every single one.",
			description = "There is nowhere left on board you haven't walked.",
			icon = "assets/images/achievements/achievements-6",
			-- progressMax is stamped at boot by RoomAtlas.stampAchievementTotal(): the
			-- room count lives in levelsLDTK and would go stale as a literal here.
			progressMax = 1,
			progressIsPercentage = true,
			scoreValue = 5
		},

	}
}

return achievementData
