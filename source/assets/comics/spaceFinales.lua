-- Boilerplate end-of-run cutscenes for SpaceScene finales. Structure mirrors
-- assets/comics/intro.lua and reuses the intro art so the cutscenes render before
-- final panels are authored. Replace `image`, `title`, and panels per finale later.

local function boilerplate(titleText)
    return {
        {
            scrollType = Panels.ScrollType.AUTO,
            direction = Panels.ScrollDirection.NONE,
            backgroundColor = Graphics.kColorBlack,
            advanceControl = Panels.Input.A,
            frame = { margin = 0 },
            title = titleText,
            panels = {
                {
                    layers = {
                        { image = "comics/intro/001", x = -8, y = -8 },
                    },
                },
                {
                    layers = {
                        { image = "comics/intro/001", x = -8, y = -8 },
                        { image = "comics/intro/002", x = -8, y = -8 },
                    },
                },
            },
        }
    }
end

spaceGood   = boilerplate("Space Finale: Good")
spaceMaamaa = boilerplate("Space Finale: Maamaa")
spaceShura  = boilerplate("Space Finale: Shura")
