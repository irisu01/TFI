local TransfurController = {
	Importable = true;
}

-- Global Module
local YukiCore = _G.YukiCore

-- Services
local Players = game:GetService("Players")
local PlayerService = YukiCore.Import("Services/PlayerService")

-- Events
function TransfurController.OnExecute()
	-- Handle player joins.
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
            PlayerService:AddCharacterValue(player, "StringValue", "Transfur", "")
            PlayerService:AddCharacterValue(player, "BoolValue", "IsTransfur", false)
		end)
	end)
end

return TransfurController