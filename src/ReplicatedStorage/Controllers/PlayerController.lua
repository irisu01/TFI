local PlayerController = {
	Importable = true;
}

-- Global Module
local YukiCore = _G.YukiCore

-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local InputService = YukiCore.Import("Services/InputService")
local UserInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

-- PLAYER
local camera = workspace.CurrentCamera

--FOV Settings
local zoomInFOV = 55
local zoomOutFOV = 70

--FOV Function
local function tweenFOV(duration, fov)

    local tween = tweenService:Create(camera, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),{FieldOfView = fov})
    tween:Play()

    coroutine.wrap(function()
        tween.Completed:Wait()
        tween:Destroy()
    end)()

end

-- Events
function PlayerController.OnExecute()
	-- Disable Core GUIs.
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

	-- Handle bridges
	local runBridge = PlayerController.Client.GetBridge("PlayerRun")

	runBridge:Hook(PlayerController.OnPlayerRun)

	InputService:RegisterKeyboardInput({ Enum.KeyCode.LeftControl }, function(input)

		runBridge:Fire({
			Key = input.KeyCode;
		})
	end)
end

function PlayerController.OnPlayerRun(isRunning)
	if isRunning == true then
        tweenFOV(0.35, zoomInFOV)
	else
        tweenFOV(0.35, zoomOutFOV)
	end
end

return PlayerController