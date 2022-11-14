local Players = game:GetService("Players")
local PlayerService = {
	Importable = true;
	InitializedPlayers = {};
}

-- Global Module
local YukiCore = _G.YukiCore

-- Assets
YukiCore.Import("Libraries/InstanceBuilder")

-- INITIALIZER FUNCTIONS
function PlayerService:InitializePlayer(player)
	-- Create Player Values Folder
	Instance.new("Folder")
	.Name("PlayerValues")
	.Parent(player)
	.Build()
	
	-- Create Players Inventory Folder
	Instance.new("Folder")
	.Name("PlayerInventory")
	.Parent(player)
	.Build()
	
	return PlayerService
end

function PlayerService:InitializeCharacter(character)
	-- Create Character Values Folder
	Instance.new("Folder")
	.Name("CharacterValues")
	.Parent(character)
	.Build()
	
	table.insert(PlayerService.InitializedPlayers, Players:GetPlayerFromCharacter(character).UserId)
	print(PlayerService.InitializedPlayers)
end

-- VALUE FUNCTIONS
function PlayerService:GetValue(location, name, getValue)
	local value = location:FindFirstChild(name)
	
	if value == nil then
		return nil
	end

	if getValue == true then
		return value.Value
	end
	
	return value
end

function PlayerService:SetValue(location, name, newValue)
	local value = PlayerService:GetValue(location, name)

	if value == nil then
		return nil
	end
	
	value.Value = newValue

	return value
end

function PlayerService:AddValue(location, valueType, name, value)
	local instance = Instance.new(valueType)
	
	instance.Name(name)
	.Value(value)
	.Parent(location)
	.Build()
	
	return instance.Build()
end

-- PLAYER VALUE FUNCTIONS
function PlayerService:GetPlayerValue(player, name)
	if player:FindFirstChild("PlayerValues") == nil then 
		PlayerService:InitializePlayer(player)
	end

	return PlayerService:GetValue(player.PlayerValues, name, true)
end

function PlayerService:SetPlayerValue(player, name, value)
	if player:FindFirstChild("PlayerValues") == nil then 
		PlayerService:InitializePlayer(player)
	end
	
	return PlayerService:SetValue(player.PlayerValues, name, value)
end

function PlayerService:AddPlayerValue(player, valueType, name, value)
	if player:FindFirstChild("PlayerValues") == nil then 
		PlayerService:InitializePlayer(player)
	end

	PlayerService:AddValue(player.PlayerValues, valueType, name, value)
end

-- CHARACTER VALUE FUNCTIONS
function PlayerService:GetCharacterValue(player, name)
	while table.find(PlayerService.InitializedPlayers, player.UserId) == nil do
		task.wait(0.1)
	end

	return PlayerService:GetValue(player.Character.CharacterValues, name, true)
end

function PlayerService:SetCharacterValue(player, name, value)
	while table.find(PlayerService.InitializedPlayers, player.UserId) == nil do
		task.wait(0.1)
	end

	return PlayerService:SetValue(player.Character.CharacterValues, name, value)
end

function PlayerService:AddCharacterValue(player, valueType, name, value)
	while table.find(PlayerService.InitializedPlayers, player.UserId) == nil do
		task.wait(0.1)
	end

	return PlayerService:AddValue(player.Character.CharacterValues, valueType, name, value)
end

return PlayerService
