local CoreController = {
	Importable = true,
}

-- Global Module
local YukiCore = _G.YukiCore

-- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local PlayerService = YukiCore.Import("Services/PlayerService")

-- Packages
local Roact = YukiCore.Require("roact")
local Cmdr = YukiCore.Require("Cmdr")

-- Assets
YukiCore.Import("Libraries/InstanceBuilder")
local InventoryGui = YukiCore.Import("Guis/InventoryGui")
local LoadingGui = YukiCore.Import("Guis/LoadingGui")
local MainMenuGui = YukiCore.Import("Guis/MainMenuGui")

-- Events
function CoreController.OnExecute()
	-- Register global bridges.
	local loadingBridge = CoreController.Server.RegisterBridge("LoadingStart", CoreController.OnPlayerLoadingStart)
	CoreController.Server.RegisterBridge("LoadingFinished", CoreController.OnPlayerLoadingFinished)
	
	-- Set global constants.
	CoreController.Server.RegisterGlobal("PLAYER_INVENTORY_LIMIT", 10)
	CoreController.Server.RegisterGlobal("PLAYER_WALK_SPEED", 16)
	CoreController.Server.RegisterGlobal("PLAYER_HEALTH", 100)

	-- Setup Cmdr
	Cmdr:RegisterDefaultCommands()
	Cmdr:RegisterCommandsIn(ServerStorage.Commands)

	-- Handle player joins.
	Players.PlayerAdded:Connect(function(player)
		-- Add player values.
		PlayerService:AddPlayerValue(player, "BoolValue", "IsLoaded", false)

		-- Initialize character data.
		player.CharacterAdded:Connect(function(character)
			PlayerService:InitializeCharacter(character)

			-- Add character values
			PlayerService:AddCharacterValue(player, "NumberValue", "WalkSpeedMultiplier", 1.0)
			PlayerService:AddCharacterValue(
				player,
				"IntValue",
				"WalkSpeed",
				CoreController.Server.GetGlobal("PLAYER_WALK_SPEED")
			)
			PlayerService:AddCharacterValue(
				player,
				"IntValue",
				"Health",
				CoreController.Server.GetGlobal("PLAYER_HEALTH")
			)
		end)

		-- Mount created GUIs to the player.
		local inventoryGui = Roact.mount(Roact.createElement(InventoryGui), player.PlayerGui, "InventoryGui")
		local loadingGui = Roact.mount(Roact.createElement(LoadingGui), player.PlayerGui, "LoadingGui")
		local mainMenuGui = Roact.mount(Roact.createElement(MainMenuGui), player.PlayerGui, "MainMenuGui")

		-- Add handles to the game.
		YukiCore.AddRoactHandleToPlayer("InventoryGui", player, inventoryGui)
		YukiCore.AddRoactHandleToPlayer("LoadingGui", player, loadingGui)
		YukiCore.AddRoactHandleToPlayer("MainMenuGui", player, mainMenuGui)
		
		-- Fire loading start event.
		--loadingBridge:Fire(player, {})
	end)
end

function CoreController.OnPlayerLoadingStart(player)
	-- Move the player's character to the special spawn location.
	local spawnBox = workspace:FindFirstChild("Loading Spawn")

	if spawnBox then
		player.Character:SetPrimaryPartCFrame(
			(spawnBox.LoadingSpawnArea.CFrame + Vector3.new(0, 2, 0)) * CFrame.Angles(0, math.rad(180), 0)
		)
	end

	-- Set player's walkspeed multiplier to 0.
	PlayerService:SetCharacterValue(player, "WalkSpeedMultiplier", 0)

	-- Debounce to prevent a kick upon first teleport.
	local dontKick = true

	-- Create a coroutine consistently checking if the player has loaded.
	coroutine.wrap(function()
		local isLoaded = PlayerService:GetPlayerValue(player, "IsLoaded")

		while isLoaded == false do
			-- Run checks and balances.
			if dontKick == true then
				-- Wait a specific interval before trying to kick the player.
				task.wait(1)

				-- Set the debounce to false.
				dontKick = false
			end
			-- Check whether the player is within the loading region.
			-- Create a Region3 with the bounding box of the loading spawn model.
			local loadingRegion = Region3.new(
				workspace:FindFirstChild("Loading Spawn").LoadingSpawnArea.Position,
				workspace:FindFirstChild("Loading Spawn").LoadingSpawnArea.Position + Vector3.new(0, 10, 0)	
			)

			-- Find the player's character within the region.
			local character = workspace:FindPartsInRegion3WithWhiteList(loadingRegion, { player.Character })

			-- Validate the player is in the region.
			if #character == 0 then
				-- Automatically kick the player for trying to bypass the loading screen.
				player:Kick("That's not right. Let's try that again.")

				break
			end
			
			task.wait(0.1)
			isLoaded = PlayerService:GetPlayerValue(player, "IsLoaded")
		end
	end)()
end

function CoreController.OnPlayerLoadingFinished(player)
	local loadingBridge = CoreController.Server.GetBridge("LoadingFinished")

	-- Run validations before showing the main menu.
	-- TODO: Safety checks to prevent exploiters.

	-- Set player's loaded value to true.
	PlayerService:SetPlayerValue(player, "IsLoaded", true)

	-- Fire the finished event back.
	loadingBridge:Fire(player, {})

	-- Remove loading screen GUI.
	task.wait(3)
	--YukiCore.RemoveRoactHandleFromPlayer("LoadingGui", player)
end

return CoreController
