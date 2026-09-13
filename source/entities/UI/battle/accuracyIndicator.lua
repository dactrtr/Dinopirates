AccuracyIndicator = {}
class('AccuracyIndicator').extends(NobleSprite)

-- Accuracy pop-up shown on every button press during the DanceScene.
--
-- Imagetable: accuracyIndicator-table-400-240 (20 frames, 5 cols x 4 rows, row-major).
--   frames  1-6  : MISS     (faint dots -> "MISS!!")
--   frames  7-12 : GOOD     ("G" -> "GOOD?!")
--   frames 13-18 : PERFECT  (faint "PERFECT" -> "PERFECT!!")
--   frames 19-20 : blank    (resting / hidden)
--
-- Each rating plays its 6-frame band once (loop = false) and then transitions to the
-- blank "hidden" state, so the pop-up flashes briefly and disappears.
function AccuracyIndicator:init()
	AccuracyIndicator.super.init(self, 'assets/images/ui/battle/accuracyIndicator', true)

	local frameDuration = (Config.Dance and Config.Dance.accuracyFrameDuration) or 3

	-- Blank resting state (frame 20 is empty). Added first so it becomes the default
	-- state (nothing is shown until show() is called) and so the rating bands can point
	-- their `next` at the state *table* (Noble.Animation dereferences next.startFrame, so
	-- a string next would crash when a band completes).
	self.animation:addState('hidden', 20, 20)

	-- Rating pops: play once, then fall back to 'hidden'.
	self.animation:addState('miss',    1,  6,  self.animation.hidden, false, nil, frameDuration)
	self.animation:addState('good',    7,  12, self.animation.hidden, false, nil, frameDuration)
	self.animation:addState('perfect', 13, 18, self.animation.hidden, false, nil, frameDuration)

	self.animation:setState('hidden')
	self:setZIndex(10)  -- above the dancers (player=6) and win/lose markers (=9)
	self:setSize(400, 240)
	self:setCenter(0, 0)
	self:add(0, 0)
end

-- Flash a rating pop-up. `rating` is one of "miss" | "good" | "perfect".
function AccuracyIndicator:show(rating)
	if rating == 'miss' or rating == 'good' or rating == 'perfect' then
		-- Bounce through 'hidden' first so the animation restarts even when the same
		-- rating is requested again (setState no-ops on an unchanged current state).
		self.animation:setState('hidden')
		self.animation:setState(rating)
	end
end

function AccuracyIndicator:update()

end
