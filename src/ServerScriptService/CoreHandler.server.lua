local YukiCore = require(game:GetService("ReplicatedStorage").YukiCore)

-- Server Controllers
local CoreController = YukiCore.Import("Controllers/CoreController")
local CharacterController = YukiCore.Import("Controllers/CharacterController")
local InventoryController = YukiCore.Import("Controllers/InventoryController")
local TemperatureController = YukiCore.Import("Controllers/TemperatureController")
local TransfurController = YukiCore.Import("Controllers/TransfurController")

-- Register Controllers
YukiCore.Server.RegisterControllers({
	CoreController,
	CharacterController,
	InventoryController,
	TransfurController,
	TemperatureController
})