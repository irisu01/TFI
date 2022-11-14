local MainMenuController = {
	Importable = true,
}

-- Global Module
local YukiCore = _G.YukiCore

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local AnimationService = YukiCore.Import("Services/AnimationService")

-- Constants
local Player = Players.LocalPlayer

-- Events
function MainMenuController.OnExecute()
    -- Empty
end

function MainMenuController.OnCreditsButtonClicked()
end

-- Functions
function MainMenuController.HandleMainMenuBars(mainMenuGui)
	-- Set top and bottom bar to fit the entire screen.
	local topBar = mainMenuGui.TopBar
	local bottomBar = mainMenuGui.BottomBar

	topBar.Size = UDim2.fromScale(1, 0.5)
	bottomBar.Size = UDim2.fromScale(1, 0.5)
	
	-- Set the bottom bar to be at the center of the screen.
	bottomBar.Position = UDim2.fromScale(0, 0.5)
end

function MainMenuController.HandleMainMenu(mainMenuGui)
	local topBar = mainMenuGui.TopBar
	local bottomBar = mainMenuGui.BottomBar

	-- Arbitrarily wait a bit.
	task.wait(.5)

	-- Tween the border colors of both bars to be white.
	AnimationService:RunKeyframesOnObject(topBar, {
		AnimationService:CreateSelfKeyframe(
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				BorderColor3 = Color3.fromRGB(255, 255, 255);
			},
			false
		),

		AnimationService:CreateObjectKeyframe(
			bottomBar,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				BorderColor3 = Color3.fromRGB(255, 255, 255),
			}
		),

		AnimationService:CreateSelfKeyframe(
			TweenInfo.new(1.15, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),
			{
				Size = UDim2.fromScale(1, 0.15);
			},
			false
		),

		AnimationService:CreateObjectKeyframe(
			bottomBar,
			TweenInfo.new(1.15, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),
			{
				Size = UDim2.fromScale(1, 0.15);
				Position = UDim2.fromScale(0, 0.85);
			}
		)
	})

    -- Create input events.
    local buttonFrame = mainMenuGui.ButtonFrame
    --[[local creditsButton = buttonFrame.CreditsButton

    creditsButton.InputBegan:Connect(function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1
            or inputObject.UserInputType == Enum.UserInputType.Touch then
            MainMenuController.OnCreditsButtonClicked()
        end
    end)]]--

	-- Rotate the logo back and forth.
	coroutine.wrap(function()
		local logo = mainMenuGui.LogoFrame

		while mainMenuGui.Enabled == true do
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine)
			local tween = TweenService:Create(logo, tweenInfo, {
				Rotation = 2.5,
			})

			tween:Play()
			tween.Completed:Wait()

			local tween = TweenService:Create(logo, tweenInfo, {
				Rotation = -2.5,
			})

			tween:Play()
			tween.Completed:Wait()
		end
	end)()

	-- Create a pulse on the word "Fursaken".
	coroutine.wrap(function()
		local logo = mainMenuGui.LogoFrame
		local fursakenPulse = logo.FursakenPulse
		local fursakenText = logo.Fursaken

		while mainMenuGui.Enabled == true do
			-- Size the pulse up slowly.
			local tweenInfo = TweenInfo.new(2.25, Enum.EasingStyle.Sine)
			local textSizeTween = TweenService:Create(fursakenPulse, tweenInfo, {
                Size = UDim2.fromScale(0.915, 0.205);
			})

			local textStrokeTween = TweenService:Create(fursakenPulse.Stroke, tweenInfo, {
				Transparency = 1,
			})

			textSizeTween:Play()
			textStrokeTween:Play()
			textSizeTween.Completed:Wait()
			textStrokeTween.Completed:Wait()

			-- Reset the size and transparency back to default.
			fursakenPulse.Size = fursakenText.Size

			-- Wait an arbitrary amount of time before the next pulse.
			task.wait(2.5)
			fursakenPulse.Stroke.Transparency = 0
		end
	end)()
end

return MainMenuController
