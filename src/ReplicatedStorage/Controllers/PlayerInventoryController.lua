local PlayerInventoryController = {
	Importable = true,
}

-- Global Module
local YukiCore = _G.YukiCore

-- Services
local Players = game:GetService("Players")
local InputService = YukiCore.Import("Services/InputService")

-- Assets
YukiCore.Import("Libraries/InstanceBuilder")

--Constants
local keyMap = {
	[48] = Enum.KeyCode.Zero,
	[49] = Enum.KeyCode.One,
	[50] = Enum.KeyCode.Two,
	[51] = Enum.KeyCode.Three,
	[52] = Enum.KeyCode.Four,
	[53] = Enum.KeyCode.Five,
	[54] = Enum.KeyCode.Six,
	[55] = Enum.KeyCode.Seven,
	[56] = Enum.KeyCode.Eight,
	[57] = Enum.KeyCode.Nine,
}

-- Events
function PlayerInventoryController.OnExecute()
	for i = 0, 9, 1 do
		InputService:RegisterKeyboardInput({ keyMap[48 + i] }, function(input)
			if input.KeyCode == Enum.KeyCode.Zero then
				PlayerInventoryController.OnItemKeyDown(10)
			else
				PlayerInventoryController.OnItemKeyDown(i)
			end
		end, false)
	end
end

function PlayerInventoryController.OnItemKeyDown(itemNumber)
	-- Get relevant server bridges.
	local selectItem = PlayerInventoryController.Client.GetBridge("SelectItem")

	-- Fire the index.
	selectItem:Fire(itemNumber)
end

return PlayerInventoryController
