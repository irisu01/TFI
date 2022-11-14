local PlayerDataService = {
	Name = "PlayerDataService";
	Importable = true;
}

-- Services
local DataStoreService = game:GetService("DataStoreService")

-- Constants
local PlayerData = DataStoreService:GetDataStore("GamePlayerData")
local DefaultPlayerSave = {
	Level = 0;
	Exp = 0;
	Cash = 0;
	Infects = 0;
	Kills = 0;
	
	Settings = {};
	Flags = {
		FirstJoin = true;
	};
}

-- Local Functions
function playerDataSet(playerData)
	for key, value in pairs(DefaultPlayerSave) do
		if typeof(DefaultPlayerSave[key]) == "table" then
			if playerData[key] == nil then
				playerData[key] = {}
			end
			
			playerDataSet(playerData[key])
		else
			if playerData[key] == nil then
				playerData[key] = value
			end
		end
	end
end

--- Service Functions
-- Player Functions
function PlayerDataService:AssertPlayerData(player)
	local playerId = player.UserId or player
	
	-- get player data or set as default
	local success, data = pcall(function()
		return PlayerData:UpdateAsync(playerId, function(playerData)
			if playerData == nil then
				playerData = DefaultPlayerSave
			end
			
			-- assert player data has the same keys as the default
			playerDataSet(playerData)
			
			return playerData
		end)
	end)
end

function PlayerDataService:GetPlayer(player)
	local playerId = player.UserId or player
	
	-- get player data or set as default
	local success, data = pcall(function()
		return PlayerData:UpdateAsync(playerId, function(playerData)
			if playerData == nil then
				playerData = DefaultPlayerSave
			end
			
			-- assert player data has the same keys as the default
			playerDataSet(playerData)
			
			return playerData
		end)
	end)
	
	if success == true then
		return data
	else
		print(data) -- error
	end
	
	return nil
end

function PlayerDataService:UpdatePlayer(player, data)
	local playerId = player.UserId or player

	-- get player data or set as default
	local success, data = pcall(function()
		return PlayerData:UpdateAsync(playerId, function(playerData)
			if playerData == nil then
				playerData = DefaultPlayerSave
			end
			
			-- assert player data has the same keys as the default
			playerDataSet(playerData)

			return playerData
		end)
	end)

	return success
end

return PlayerDataService
