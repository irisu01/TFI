local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function(YukiCore, YukiCoreScript)
    if _G.YukiCoreGlobals == nil then
        _G.YukiCoreGlobals = {}
    end

	if _G.YukiCoreGlobals._RoactHandles == nil then
		_G.YukiCoreGlobals._RoactHandles = {};
	end

    if _G.YukiCore == nil then
        -- Set Useful Globals
        if RunService:IsClient() then
            _G.Player = Players.LocalPlayer
        end
    
        _G.YukiCore = YukiCore
    end
    
    
    if YukiCore.Server == nil then
        YukiCore.Server = YukiCore.Import("Prepend/SetupFunctions", YukiCoreScript)({ YukiCore = YukiCore; })
        YukiCore.Server.YukiCore = YukiCore
    end
    
    if YukiCore.Client == nil then
        YukiCore.Client = YukiCore.Import("Prepend/SetupFunctions", YukiCoreScript)({ YukiCore = YukiCore; })
        YukiCore.Client.YukiCore = YukiCore
    end
    
    
    if game:GetService("ReplicatedStorage"):FindFirstChild("YukiCoreRedist") == nil then
        -- create redist folders
        local redist = Instance.new("Folder")
        local remoteEvents = Instance.new("Folder")
        local localEvents = Instance.new("Folder")
    
        -- assign properties
        redist.Name = "YukiCoreRedist"
        remoteEvents.Name = "RemoteEvents"
        localEvents.Name = "LocalEvents"
    
        -- set parents
        remoteEvents.Parent = redist
        localEvents.Parent = redist
        redist.Parent = ReplicatedStorage
    end
    
    if RunService:IsServer() then
        if game:GetService("ServerStorage"):FindFirstChild("YukiCoreServerRedist") == nil then
            -- create redist folders
            local redist = Instance.new("Folder")
            local localEvents = Instance.new("Folder")
            local instances = Instance.new("Folder")
    
            -- assign properties
            redist.Name = "YukiCoreServerRedist"
            localEvents.Name = "LocalEvents"
            instances.Name = "ServerValues"
    
            -- set parents
            localEvents.Parent = redist
            instances.Parent = redist
            redist.Parent = game:GetService("ServerStorage")
        end

        
        -- create instance requester if possible
        if _G.ScriptName ~= nil then
            local requestEvent = Instance.new("BindableFunction")
            
            requestEvent.Name = _G.ScriptName		
            requestEvent.OnInvoke = function()
                return YukiCore.Server
            end
            
            requestEvent.Parent = game:GetService("ServerStorage").YukiCoreServerRedist.Instances
        end
    end
    
    if RunService:IsClient() then
        if game:GetService("Players").LocalPlayer:FindFirstChild("YukiCoreClientRedist") == nil then
            -- create redist folders
            local redist = Instance.new("Folder")
            local localEvents = Instance.new("Folder")
            local instances = Instance.new("Folder")
    
            -- assign properties
            redist.Name = "YukiCoreClientRedist"
            localEvents.Name = "LocalEvents"
            instances.Name = "ClientValues"
    
            -- set parents
            localEvents.Parent = redist
            instances.Parent = redist
            redist.Parent = game:GetService("Players").LocalPlayer
        end
    end
    
    -- create instance requester if possible
    if _G.ScriptName ~= nil then
        local requestEvent = Instance.new("BindableFunction")
    
        requestEvent.Name = _G.ScriptName		
        requestEvent.OnInvoke = function()
            return YukiCore.Client
        end
    
        requestEvent.Parent = game:GetService("Players").LocalPlayer.YukiCoreClientRedist.Instances
    end
end