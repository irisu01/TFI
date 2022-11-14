local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

return function(derivative)
	-- Set default values.
	derivative = {
		RegisteredControllers = {},
	}

	if RunService:IsClient() then
		-- Handle Client functions.
		function derivative.GetBridge(name)
			local bridge = ReplicatedStorage.YukiCoreRedist.RemoteEvents:FindFirstChild(name)

			if bridge == nil then
				return nil
			end

			-- Return an abstraction around the bridge.
			return {
				Bridge = bridge,

				Fire = function(self, ...)
					bridge:FireServer(...)
				end,

				Hook = function(self, callback)
					bridge.OnClientEvent:Connect(callback)
				end,
			}
		end
	elseif RunService:IsServer() then
		-- Handle Server functions
		function derivative.RegisterFunctionalBridge(name, callback) end

		function derivative.RegisterBridge(name, callback)
			local folder = string.split(name, "/")
			local abstraction

			if #folder == 1 then
				-- Create a bridge in the base folder.
				local bridge = Instance.new("RemoteEvent")
				bridge.Name = folder[1]
				bridge.Parent = ReplicatedStorage.YukiCoreRedist.RemoteEvents

				if callback ~= nil then
					bridge.OnServerEvent:Connect(callback)
				end

				-- Create an abstraction.
				abstraction = {
					Bridge = bridge,

					Fire = function(self, player, ...)
						bridge:FireClient(player, ...)
					end,

					Hook = function(self, callback)
						bridge.OnServerEvent:Connect(callback)
					end,
				}
			else
				local bridgeName = folder[#folder]
				table.remove(folder, #folder)

				local joinedString = folder[1]
				table.remove(folder, 1)
				for _, v in ipairs(folder) do
					joinedString = joinedString .. "/" .. v
				end

				-- Create the folder with the string.
				folder = derivative.YukiCore.CreateFolder(joinedString)

				-- Create the bridge.
				local bridge = Instance.new("RemoteEvent")
				bridge.Name = bridgeName
				bridge.Parent = folder
				bridge.OnServerEvent:Connect(callback)
				folder.Parent = ReplicatedStorage.YukiCoreRedist.RemoteEvents

				-- Create an abstraction.
				return {
					Bridge = bridge,

					Fire = function(self, player, ...)
						bridge:FireClient(player, ...)
					end,
				}
			end

			-- Return the abstraction.
			return abstraction
		end
		
		function derivative.GetBridge(name)
			local bridge = ReplicatedStorage.YukiCoreRedist.RemoteEvents:FindFirstChild(name)

			if bridge == nil then
				return nil
			end

			-- Return an abstraction around the bridge.
			return {
				Bridge = bridge,

				Fire = function(self, player, ...)
					bridge:FireClient(player, ...)
				end,
				
				Hook = function(self, callback)
					bridge.OnServerEvent:Connect(callback)
				end,
			}
		end
	end

	-- Add universal functions
	-- Get physical in-game values.
	function derivative.GetValue(name, asPrimative)
		if asPrimative == nil then
			asPrimative = true
		end

		local location
		if RunService:IsServer() then
			location = ServerStorage.YukiCoreServerRedist.ServerValues
		else
			location = game.Players.LocalPlayer.YukiCoreClientRedist.ClientValues
		end

		local value = location:FindFirstChild(name)

		if value == nil then
			return nil
		end

		if asPrimative == true then
			return value.Value
		end

		return value
	end

	function derivative.SetValue(name, newValue)
		local value = derivative.GetValue(name, false)

		if value == nil then
			return nil
		end

		value.Value = newValue

		return value
	end

	function derivative.AddValue(valueType, name, value)
		local location
		if RunService:IsServer() then
			location = ServerStorage.YukiCoreServerRedist.ServerValues
		else
			location = game.Players.LocalPlayer.YukiCoreClientRedist.ClientValues
		end

		local instance = Instance.new(valueType)

		instance.Name = name
		instance.Value = value
		instance.Parent = location

		return instance
	end

	-- Global value functions
	function derivative.RegisterGlobal(key, value)
		_G.YukiCoreGlobals[key] = value
	end

	function derivative.GetGlobal(key, value)
		return _G.YukiCoreGlobals[key]
	end

	function derivative.GetControllerByIndex(index)
		if RunService:IsServer() == false then
			return
		end

		local controller = derivative.RegisteredControllers[index]

		if controller == nil then
			return
		end

		return controller.Controller
	end

	function derivative.GetControllerByName(name)
		local found = false
		local controller

		for _, v in ipairs(derivative.RegisteredControllers) do
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

	-- Controller functions
	function derivative.RegisterControllers(controllerTable)
		for index = 1, #controllerTable do
			local controller = controllerTable[index]

			-- assign self
			if RunService:IsServer() then
				controller.Server = derivative
			elseif RunService:IsClient() then
				controller.Client = derivative
			end

			-- assign controller
			table.insert(derivative.RegisteredControllers, {
				Name = controller.Name or controller.__instance.Name,
				Controller = controller,
			})

			if controller.AutoRun ~= false then
				-- run on execute
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
			end
		end
	end

	-- Return the table.
	return derivative
end
