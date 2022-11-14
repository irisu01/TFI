local ServerFunctions = {
	RegisteredControllers = {};
}

-- SERVICES
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- GLOBALS FUNCTIONS
function ServerFunctions.RegisterGlobal(key, value)
	_G.YukiCoreGlobals[key] = value
end

function ServerFunctions.GetGlobal(key, value)
	return _G.YukiCoreGlobals[key]
end

function ServerFunctions.GetServerValue(name, getValue)
	local value = ServerStorage.YukiCoreServerRedist.ServerValues:FindFirstChild(name)
	
	if value == nil then
		return nil
	end

	if getValue == true then
		return value.Value
	end
	
	return value
end

function ServerFunctions.SetServerValue(location, name, newValue)
	local value = ServerFunctions.GetServerValue(name)

	if value == nil then
		return nil
	end
	
	value.Value = newValue

	return value
end

function ServerFunctions.AddServerValue(valueType, name, value)
	local instance = Instance.new(valueType)
	
	instance.Name = name
	instance.Value = value
	instance.Parent = ServerStorage.YukiCoreServerRedist.ServerValues
	
	return instance
end

-- SERVER FUNCTIONS
function ServerFunctions.RegisterFunction(name, callback)
	if RunService:IsServer() == false then
		return nil
	end

	local folder = string.split(name, "/")
	if #folder == 1 then
		name = folder[1]
		-- create bridge
		local bridge = Instance.new("RemoteFunction")
		bridge.Name = name
		bridge.Parent = ReplicatedStorage.YukiCoreRedist.RemoteEvents
		bridge.OnServerInvoke = callback

		return bridge;
	else
		local bridgeName = folder[#folder]
		table.remove(folder, #folder)

		local joinedString = folder[1]
		table.remove(folder, 1)
		for _, v in ipairs(folder) do
			joinedString = joinedString .. "/" .. v
		end

		folder = ServerFunctions.YukiCore.CreateFolderIfNotExists(joinedString)

		local bridge = Instance.new("RemoteFunction")
		bridge.Name = bridgeName
		bridge.Parent = folder
		bridge.OnServerInvoke = callback

		folder.Parent = ReplicatedStorage.YukiCoreRedist.RemoteEvents

		return
	end
end

function ServerFunctions.RegisterBridge(name, callback)
	if RunService:IsServer() == false then
		return nil
	end
	
	local folder = string.split(name, "/")
	if #folder == 1 then
		name = folder[1]
		-- create bridge
		local bridge = Instance.new("RemoteEvent")
		bridge.Name = name
		bridge.Parent = ReplicatedStorage.YukiCoreRedist.RemoteEvents
		bridge.OnServerEvent:Connect(callback)

		return {
			Bridge = bridge;
			Fire = function(player, ...)
				bridge:FireClient(player, ...)
			end;
		}
	else
		local bridgeName = folder[#folder]
		table.remove(folder, #folder)

		local joinedString = folder[1]
		table.remove(folder, 1)
		for _, v in ipairs(folder) do
			joinedString = joinedString .. "/" .. v
		end
		
		folder = ServerFunctions.YukiCore.CreateFolderIfNotExists(joinedString)
		
		local bridge = Instance.new("RemoteEvent")
		bridge.Name = bridgeName
		bridge.Parent = folder
		bridge.OnServerEvent:Connect(callback)
		
		folder.Parent = ReplicatedStorage.YukiCoreRedist.RemoteEvents

		return {
			Bridge = bridge;
			
			Fire = function(self, player, ...)
				bridge:FireClient(player, ...)
			end;
		}
	end
end

function ServerFunctions.RegisterControllers(controllerTable)
	if RunService:IsServer() == false then
		return nil
	end

	for index = 1, #controllerTable do
		local controller = controllerTable[index]

		-- assign self
		controller.Server = ServerFunctions.YukiCore.Server

		-- assign controller
		table.insert(ServerFunctions.RegisteredControllers, {
			Name = controller.Name or controller.__instance.Name;
			Controller = controller;
		})
		
		if controller.AutoRun ~= false then
			-- run on execute
			if controller.OnExecute ~= nil then
				print("Executing " .. (controller.Name or controller.__instance.Name))
				controller.OnExecute()
			end

			if controller.OnStep ~= nil then
				-- add stepped handler
				RunService.Stepped:Connect(controller.OnStep)
			end

			if controller.OnRenderStep ~= nil then
				-- add stepped handler
				RunService.RenderStepped:Connect(controller.OnRenderStep)
			end
		end
	end
end

function ServerFunctions.GetControllerByIndex(index)
	if RunService:IsServer() == false then
		return
	end

	local controller = ServerFunctions.RegisteredControllers[index]

	if controller == nil then
		return
	end

	return controller.Controller
end

function ServerFunctions.GetControllerByName(name)
	if RunService:IsServer() == false then
		return nil
	end

	local found = false
	local controller
	
	for _, v in ipairs(ServerFunctions.RegisteredControllers) do
		if v.Name == name then
			controller = v.Controller
			found = true
			break
		end
	end
	
	if found == false then
		return nil
	end

	return controller
end

function ServerFunctions.ExecuteController(controller)
	if RunService:IsServer() == false or controller.Executed == true then
		return
	end

	if controller.OnExecute ~= nil then
		controller.OnExecute()
	end

	if controller.OnStep ~= nil then
		-- add stepped handler
		RunService.Stepped:Connect(controller.OnStep)
	end

	if controller.OnRenderStep ~= nil then
		-- add stepped handler
		RunService.RenderStepped:Connect(controller.OnRenderStep)
	end

	controller.Executed = true
	return controller
end

return ServerFunctions
