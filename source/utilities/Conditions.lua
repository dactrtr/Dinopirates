-- Conditions: shared boolean evaluator for spawn/render gating.
--
-- A condition is a string like "run>=4", "items.hasLamp", "!isTiny", or literal "true".
-- - Numeric comparison: "<path> <op> <number>" with op in > < >= <= == !=
-- - Boolean path: "<path>" (true when it equals true), optional "!" to negate
-- - Aliases: "run" -> PlayerData.runCount, "crew" -> PlayerData.CrewMemberData.amountTaken
--
-- This is used by the spawn gate (Items/Triggers' `spawnConditions`). It is intentionally
-- separate from the dialog-selection conditionalScripts in npc.lua/trigger.lua: this
-- decides whether an entity is created at all; those decide which script runs on interaction.
Conditions = {}

-- Resolve a dot path ("items.hasLamp") inside PlayerData; nil if any step is missing.
local function resolvePath(path)
	local current = PlayerData
	for part in path:gmatch("[^%.]+") do
		if current == nil then return nil end
		current = current[part]
	end
	return current
end

-- Evaluate a single condition expression to true/false.
function Conditions.eval(expr)
	if type(expr) ~= "string" then return false end
	if expr == "true" then return true end

	-- Numeric comparison: "path op number"
	local path, op, valStr = expr:match("^([%w%.]+)%s*([<>!=]=?)%s*([%d%-%.]+)$")
	if path and op and valStr then
		local currentVal
		if path == "run" then
			currentVal = PlayerData.runCount or 0
		elseif path == "crew" then
			currentVal = (PlayerData.CrewMemberData and PlayerData.CrewMemberData.amountTaken) or 0
		else
			currentVal = tonumber(resolvePath(path)) or 0
		end
		local val = tonumber(valStr)
		if     op == ">"  then return currentVal >  val
		elseif op == "<"  then return currentVal <  val
		elseif op == ">=" then return currentVal >= val
		elseif op == "<=" then return currentVal <= val
		elseif op == "==" then return currentVal == val
		elseif op == "!=" then return currentVal ~= val
		end
		return false
	end

	-- Boolean path, optional "!" negation.
	local invert    = expr:sub(1, 1) == "!"
	local cleanPath = invert and expr:sub(2) or expr
	local result    = (resolvePath(cleanPath) == true)
	if invert then result = not result end
	return result
end

-- Strip surrounding whitespace and any stray wrapping characters ({ } " ') a user may
-- have typed into the LDtk array field (e.g. "{run==4}" instead of run==4). Valid
-- conditions never start/end with these, so this only forgives authoring mistakes.
local function trim(s)
	s = s:gsub("^[%s{}\"']+", "")
	s = s:gsub("[%s{}\"']+$", "")
	return s
end

-- An entry may be an OR-group: sub-conditions separated by '|', passing if ANY sub passes
-- (an entry with no '|' is just one condition). Example: "run==4|run==8".
local function entryMet(entry)
	if type(entry) ~= "string" then return false end
	for sub in entry:gmatch("[^|]+") do
		if Conditions.eval(trim(sub)) then return true end
	end
	return false
end

-- True when every entry in the list passes (AND across entries, OR within each entry).
-- nil/empty list = true (no gate). So {"run==4|run==8", "items.hasLamp"} means
-- (run 4 OR run 8) AND has lamp.
function Conditions.met(list)
	if not list then return true end
	for _, entry in ipairs(list) do
		if not entryMet(entry) then return false end
	end
	return true
end

return Conditions
