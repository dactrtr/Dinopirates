script = {
	{
		-- no door key 1
		dialog = {
			{
				video = 'player',
				text = Graphics.getLocalizedText("door", "en")
			},
			{
				video = 'radio',
				text = Graphics.getLocalizedText("door2", "en")
			},
			{
				video = 'radio',
				text = Graphics.getLocalizedText("door3", "en")
			},
			{
				video = 'player',
				text = Graphics.getLocalizedText("door4", "en")
			},
			{
				video = 'radiopocket',
				text = Graphics.getLocalizedText("door5", "en")
			},
			{
				video = 'player',
				text = Graphics.getLocalizedText("door6", "en")
			},
		}
	},
	{
		-- trigger mess
		dialog = {
			{
				video = 'player',
				text = Graphics.getLocalizedText("mess", "en"),
			},
			{
				video = 'player',
				text = Graphics.getLocalizedText("mess2", "en"),
			},
			
		}
	},
	{
		-- trigger mess
		dialog = {
			{
				video = 'player',
				text = Graphics.getLocalizedText("chairs", "en")
			},
			{
				video = 'player',
				text = Graphics.getLocalizedText("chairs1", "en")
			},
			
		}
	},
	{
		-- trigger pickup radio
		dialog = {
			{
				video = 'radio',
				text = Graphics.getLocalizedText("welcome", "en")
			},
			{
				video = 'radio',
				text = Graphics.getLocalizedText("welcome1", "en"),
				screen = Graphics.image.new('assets/images/ui/dialog/img/spaceship.png'),
			},
			{
				video = 'radio',
				text = Graphics.getLocalizedText("welcome2", "en"),
				screen = Graphics.image.new('assets/images/ui/dialog/img/spaceship.png'),
			},
			{
				video = 'player',
				text = Graphics.getLocalizedText("welcome3", "en")
			},
			{
				video = 'radio',
				text = Graphics.getLocalizedText("welcome4", "en")
			},
		}
	},
	{
		-- Kitchen
		dialog = {
			{
				video = 'player',
				text = Graphics.getLocalizedText("kitchen", "en")
			},
			{
				video = 'player',
				text = Graphics.getLocalizedText("kitchen2", "en"),
				screen = Graphics.image.new('assets/images/ui/dialog/img/cristal.png'),
			},
			{
				video = 'player',
				text = Graphics.getLocalizedText("kitchen3", "en"),
				screen = Graphics.image.new('assets/images/ui/dialog/img/cristal.png'),
			},
			
		}
	},
	
}