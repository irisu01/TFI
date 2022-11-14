local RarityService = {
	Importable = true;
	DefaultRarity = "Common"
}

-- Global Module
local yukicore = _G.YukiCore

-- Assets
yukicore.Import("Libraries/InstanceBuilder")

-- SERVICE FUNCTIONS
function RarityService:GetRarity(name)
	local rarity = script.Rarities:FindFirstChild(name)
	
	if rarity ~= nil then
		return require(rarity)
	end
	
	return require(script.Rarities:FindFirstChild(RarityService.DefaultRarity))
end

function RarityService:GetRarityGradient(name)
	local rarity
	if name.Color then
		rarity = name
	else
		rarity = RarityService:GetRarity(name)
	end
	
	-- return gradient if its there
	if rarity.ColorGradient ~= nil then
		return rarity.ColorGradient
	end
	
	-- calculate end color
	local h, s, v = rarity.Color:ToHSV()
	
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, rarity.Color),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(h, s, math.min(v * 0.65, 0)))
	})
end

return RarityService
