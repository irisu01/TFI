local YukiCore = require(game:GetService("ReplicatedStorage").YukiCore)

-- Client Controllers
local CoreClientController = YukiCore.Import("Controllers/CoreClientController")
local MainMenuController = YukiCore.Import("Controllers/MainMenuController")
local LoadingController = YukiCore.Import("Controllers/LoadingController")
local PlayerController = YukiCore.Import("Controllers/PlayerController")
local PlayerInventoryController = YukiCore.Import("Controllers/PlayerInventoryController")

-- Register Controllers
YukiCore.Client.RegisterControllers({
	CoreClientController,
	MainMenuController,
	LoadingController,
	PlayerController,
	PlayerInventoryController
})