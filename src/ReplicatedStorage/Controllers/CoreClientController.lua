local CoreClientController = {
	Importable = true;
}

-- Global Module
local YukiCore = _G.YukiCore

-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

-- Packages
local Cmdr = YukiCore.Import("CmdrClient")

-- Events
function CoreClientController.OnExecute()
	-- Startup Cmdr.
    Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })
end

return CoreClientController