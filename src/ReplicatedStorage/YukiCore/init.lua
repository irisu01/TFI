local YukiCore = {}

-- SERVICES
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
	YukiCore.lua
	by: Yuki
	
	Core framework handling, to handle every data portion and service of a game in a really easy
	to access area, with multiple useful resources to make it easier to work with.
]]

-- LOCAL FUNCTIONS
local function dirtyKeyCheck(dict, key)
	local found = false
	
	for k, _ in pairs(dict) do
		if k == key then
			found = true
			break
		end
	end
	
	return found
end

local function dirtyKeySet(dict, key, value)
	local success = pcall(function()
		dict[key] = value
	end)

	return success
end

-- MODULE FUNCTIONS
function YukiCore.CreateFolder(identifier, folder)
	if folder == nil then
		if RunService:IsServer() then
			folder = game:GetService("ServerStorage")
		else
			folder = ReplicatedStorage
		end
	end

	local values = string.split(identifier, "/")

	for index = 1,#values do
		local folderInstance = folder:FindFirstChild(values[index])

		if folderInstance == nil then
			folderInstance = Instance.new("Folder")
			folderInstance.Name = values[index]
			folderInstance.Parent = folder
		end

		folder = folderInstance
	end

	return folder
end

function YukiCore.GetFolder(identifier, folder)
	if folder == nil then
		if RunService:IsServer() then
			folder = game:GetService("ServerStorage")
		else
			folder = ReplicatedStorage
		end
	end

	local values = string.split(identifier, "/")
	local found = false

	for index = 1, #values do
		local folderInstance = folder:FindFirstChild(values[index])

		if folderInstance == nil then
			folder = nil
			found = false
			break
		end

		folder = folderInstance
		found = true
	end

	if folder == nil then
		return nil
	end

	return folder
end

function YukiCore.Require(module)
	return YukiCore.Import(module, ReplicatedStorage.Packages)
end

function YukiCore.Instance(identifier, folder)
	if folder == nil then
		if RunService:IsServer() then
			folder = game:GetService("ServerStorage")
		else
			folder = ReplicatedStorage
		end
	end

	local values = string.split(identifier, "/")
	local found = false
	local module = nil

	for index = 1,#values do
		module = (module or folder):FindFirstChild(values[index])

		if module == nil then 
			if index == 1 and folder.Name ~= "ReplicatedStorage" then
				-- attempt to search in replicatedstorage for server
				module = ReplicatedStorage:FindFirstChild(values[index])

				if module == nil then
					-- attempt to search core children
					module = script:FindFirstChild(values[index])

					if module == nil then
						break
					end
				end
			else
				break
			end
		end

		if index == #values then
			found = true
			break
		end
	end

	if found == false then
		return nil
	end
	
	return module
end

function YukiCore.Import(identifier, folder)
	if folder == nil then
		if RunService:IsServer() then
			folder = game:GetService("ServerStorage")
		else
			folder = ReplicatedStorage
		end
	end

	local values = string.split(identifier, "/")
	local found = false
	local module = nil

	for index = 1,#values do
		module = (module or folder):FindFirstChild(values[index])

		if module == nil then 
			if index == 1 and folder.Name ~= "ReplicatedStorage" then
				-- attempt to search in replicatedstorage for server
				module = ReplicatedStorage:FindFirstChild(values[index])

				if module == nil then
					-- attempt to search core children
					module = script:FindFirstChild(values[index])

					if module == nil then
						break
					end
				end
			else
				break
			end
		end

		if index == #values then
			found = true
			break
		end
	end

	if found == false then
		return nil
	end

	-- special case for preparation modules
	local instance = module
	if module.Parent == script.Prepend then
		module = require(module)
	else 
		-- handle internals
		module = require(module)
	
		if dirtyKeyCheck(module, "Importable") then
			if module.Importable == false then
				return nil
			end
		end
	
		if dirtyKeyCheck(module, "OnImport") then
			if module.OnImport ~= nil then
				module.OnImport()
			end
		end

		-- assign self
		dirtyKeySet(module, "__instance", instance)
	end

	return module
end

--- TYPE FUNCTIONS
function YukiCore.GetType(name)
	return YukiCore.import(name, script.Parent.Types)
end

--- SERVICE FUNCTIONS
function YukiCore.GetService(name)
	local service = nil
	local isRequire = false

	if RunService:IsServer() then
		local ServerScriptService = game:GetService("ServerScriptService")

		local response = nil

		pcall(function()
			response = game:GetService(name)
		end)

		service = response
			or script.Services:FindFirstChild(name)
			or ServerScriptService.Services:FindFirstChild("name")
	else
		local response = nil

		pcall(function()
			response = game:GetService(name)
		end)

		service = response
			or script.Services:FindFirstChild(name)
	end

	if service ~= nil then
		if service.Parent:IsA("DataModel") then
			return service
		else
			require(service)
		end
	end

	return nil
end

-- EXTRANEOUS FUNCTIONS
-- HOOKING FUNCTIONS
function YukiCore.HookEvent(base, event, callback)
	if base == game:GetService("Players") then
		-- Player specific events
		if event == "PlayerAdded" then
			base.PlayerAdded:Connect(callback)
		elseif event == "PlayerRemoving" then
			base.PlayerRemoving:Connect(callback)
		end

		-- Handle players
		for _, player in pairs(base:GetPlayers()) do
			callback(player)
		end
	else
		-- Handle events
		if base:IsA("BindableEvent") then
			base.Event:Connect(callback)
		elseif base:IsA("BindableFunction") then
			base.OnInvoke = callback
		elseif base:IsA("RemoteEvent") then
			base.OnServerEvent:Connect(callback)
		elseif base:IsA("RemoteFunction") then
			base.OnServerInvoke = callback
		elseif base:IsA("Folder") then
			for _, child in pairs(base:GetChildren()) do
				YukiCore.HookEvent(child, event, callback)
			end
		end
	end
end
-- ROACT FUNCTIONS
function YukiCore.GetRoactHandle(handle)
	if _G.YukiCoreGlobals._RoactHandles == nil then
		_G.YukiCoreGlobals._RoactHandles = {};
	end

	return _G.YukiCoreGlobals._RoactHandles[handle]
end

function YukiCore.AddRoactHandle(name, handle)
	_G.YukiCoreGlobals._RoactHandles[name] = handle
end

function YukiCore.AddRoactHandleToPlayer(name, player, handle)
	_G.YukiCoreGlobals._RoactHandles[name .. "__" .. player.UserId] = handle
end

function YukiCore.UpdateRoactHandle(name, element)
	local handle = YukiCore.GetRoactHandle(name)

	if handle ~= nil then
		local Roact = YukiCore.Require("roact")

		_G.YukiCoreGlobals._RoactHandles[name] = Roact.update(handle, element)
	end
end

function YukiCore.RemoveRoactHandle(name)
	local handle = YukiCore.GetRoactHandle(name)

	if handle ~= nil then
		local Roact = YukiCore.Require("roact")

		Roact.unmount(handle)
		_G.YukiCoreGlobals._RoactHandles[name] = nil
	end
end

function YukiCore.RemoveRoactHandleFromPlayer(name, player)
	local handle = YukiCore.GetRoactHandle(name .. "__" .. player.UserId)

	if handle ~= nil then
		local Roact = YukiCore.Require("roact")

		Roact.unmount(handle)
		_G.YukiCoreGlobals._RoactHandles[name .. "__" .. player.UserId] = nil
	end
end

-- MAIN FRAMEWORK LOGIC
-- Handle globals.
YukiCore.Import("Prepend/SetupGlobals", script)(YukiCore, script)

return YukiCore
