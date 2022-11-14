local CharacterController = {
	Importable = true;
}

-- Global Module
local YukiCore = _G.YukiCore

-- Services
local Players = game:GetService("Players")
local PlayerService = YukiCore.Import("Services/PlayerService")

-- Events
function CharacterController.OnExecute()
    CharacterController.Server.RegisterBridge("PlayerRun", CharacterController.OnPlayerRun)

	-- Handle player joins.
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
            PlayerService:AddCharacterValue(player, "BoolValue", "IsRunning", false)
		end)
	end)
end

function CharacterController.OnStep()
    for _, Player in pairs(Players:GetPlayers()) do
        CharacterController.onPlayerUpdate(Player)
    end
end

function CharacterController.onPlayerUpdate(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character.Humanoid
    local isRunning = PlayerService:GetCharacterValue(player, "IsRunning")
    local walkSpeed = PlayerService:GetCharacterValue(player, "WalkSpeed")
    local multiplier = PlayerService:GetCharacterValue(player, "WalkSpeedMultiplier")

    if isRunning == true then
        PlayerService:SetCharacterValue(player, "WalkSpeed", 24)
    else
        PlayerService:SetCharacterValue(player, "WalkSpeed", 16)
    end

    humanoid.WalkSpeed = walkSpeed * multiplier
end

function CharacterController.OnPlayerRun(player)
    local runBridge = CharacterController.Server.GetBridge("PlayerRun")
    local isRunning = PlayerService:GetCharacterValue(player, "IsRunning")

    if isRunning then
        PlayerService:SetCharacterValue(player, "IsRunning", false)
    else
        PlayerService:SetCharacterValue(player, "IsRunning", true)
    end

    runBridge:Fire(player, isRunning)
end

return CharacterController