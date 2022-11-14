local LoadingController = {
	Importable = true,
}

-- Global Module
local YukiCore = _G.YukiCore

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ContentProvider = game:GetService("ContentProvider")
local AnimationService = YukiCore.Import("Services/AnimationService")

-- Constants
local Preloadables = {
	function()
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://2136468951"

		return sound
	end,
}

local Player = Players.LocalPlayer

-- Events
function LoadingController.OnExecute()
	-- Bridges.
	local loadingStartBridge = LoadingController.Client.GetBridge("LoadingStart")
	local loadingFinishedBridge = LoadingController.Client.GetBridge("LoadingFinished")

	-- Hook to bridges.
	loadingStartBridge:Hook(LoadingController.OnLoadingStart)
	loadingFinishedBridge:Hook(LoadingController.OnLoadingFinished)
end

function LoadingController.OnLoadingStart()
	-- Send a signal back.
	local loadingStartBridge = LoadingController.Client.GetBridge("LoadingStart")

	loadingStartBridge:Fire({})

	-- Store loading gui.
	local loadingGui = Player.PlayerGui:WaitForChild("LoadingGui")
	local backgroundFrame = loadingGui.BackgroundFrame
	local loadingFrame = backgroundFrame.LoadingFrame
	local loadingBar = loadingFrame.LoadingBar.LoadingBarFill
	local loadingText = loadingFrame.LoadingProgressText
	local loadingAssetsText = loadingFrame.LoadingCountText

	-- Disable All default GUIs.
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

	-- Update loading text.
	loadingText.Text = "Loading assets..."

	-- Preload assets.
	for i = 1, #Preloadables do
		local asset = Preloadables[i]()
		ContentProvider:PreloadAsync({ asset })

		-- Update bar.
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
		local tween = TweenService:Create(loadingBar, tweenInfo, {
			Size = UDim2.fromScale(i / #Preloadables, 1),
		})

		loadingAssetsText.Text = i .. "/" .. #Preloadables

		tween:Play()
	end

	-- Loading is finished.
	-- Fire the finished event
	local loadingFinishedBridge = LoadingController.Client.GetBridge("LoadingFinished")

	loadingFinishedBridge:Fire({})
end

function LoadingController.OnLoadingFinished()
	-- Keep this here.
	local mainMenuController = LoadingController.Client.GetControllerByName("MainMenuController")

	-- Fade out the loading frame.
	local loadingGui = Player.PlayerGui:FindFirstChild("LoadingGui")
	local backgroundFrame = loadingGui.BackgroundFrame
	local loadingFrame = backgroundFrame.LoadingFrame
	local loadingFrameOverlay = backgroundFrame.LoadingFrameOverlay
	local loadingBar = loadingFrame.LoadingBar
	local loadingBarBorder = loadingFrame.LoadingBarBorder


	-- run animations
	AnimationService:RunKeyframesOnObject(loadingFrame, {
		AnimationService:CreateObjectKeyframe(
			loadingBar,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{
				Size = UDim2.fromScale(1, 0);
			},
			false
		),

		AnimationService:CreateObjectKeyframe(
			loadingBarBorder,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{
				Size = UDim2.fromScale(1, 0);
			}, false
		),

		AnimationService:CreateDelayKeyframe(0.25),

		AnimationService:CreateSelfKeyframe(
			TweenInfo.new(1.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{
				Size = UDim2.fromScale(1, 0.5);
			}
		),

		AnimationService:CreateObjectKeyframe(
			loadingFrame.LoadingProgressText,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{
				TextTransparency = 1;
			},
			false
		),

		AnimationService:CreateObjectKeyframe(
			loadingFrame.LoadingCountText,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{
				TextTransparency = 1;
			}
		),

		AnimationService:CreateObjectKeyframe(
			loadingFrameOverlay,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{
				BackgroundTransparency = 0;
			},
			true
		),
	})

	local mainMenuGui = Player.PlayerGui:FindFirstChild("MainMenuGui")
	
	mainMenuController.HandleMainMenuBars(mainMenuGui)

	mainMenuGui.Enabled = true
	loadingGui.Enabled = false

	-- Handle main menu GUI.
	coroutine.wrap(function()
		mainMenuController.HandleMainMenu(mainMenuGui)
	end)()
end

return LoadingController
