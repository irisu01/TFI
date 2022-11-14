local TransfurService = {
	Name = "TransfurService";
	Importable = true;

    -- Cache
    Transfurs = {};
    Fusions = {};
}

-- Global Module
local YukiCore = _G.YukiCore

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local PlayerService = YukiCore.Import("Services/PlayerService")

-- Assets
YukiCore.Import("Libraries/InstanceBuilder")
local Scheduler = YukiCore.Import("Libraries/Scheduler")

--- Service Functions
-- Transfur Data functions
function TransfurService:GetTransfur(name)
    local possibleNames = {
        string.lower(name),
        string.lower(string.gsub(name, "%s+", "_"))
    }

    local transfur = nil
    
    -- Check cache.
    if TransfurService.Transfurs[string.lower(string.gsub(name, "%s+", "_"))] ~= nil then
        return TransfurService.Transfurs[string.lower(string.gsub(name, "%s+", "_"))]
    end

    for _, v in pairs(ServerStorage.Transfurs:GetChildren()) do
        local transfurModule = require(v)
        
        if table.find(possibleNames, string.lower(string.gsub(transfurModule.Name, "%s+", "_"))) ~= nil
            or table.find(possibleNames, string.lower(string.gsub(v.Name, "%s+", "_"))) ~= nil then
            transfur = require(v)

            -- Add to cache.
            TransfurService.Transfurs[transfur.Name] = transfur
            TransfurService.Transfurs[string.lower(string.gsub(v.Name, "%s+", "_"))] = transfur
            break
        end
    end

    return transfur
end

function TransfurService:GetFusion(name)
    local possibleNames = {
        string.lower(name),
        string.lower(string.gsub(name, "%s+", "_"))
    }

    local fusion = nil
    
    -- Check cache.
    if TransfurService.Fusions[string.lower(string.gsub(name, "%s+", "_"))] ~= nil then
        return TransfurService.Fusions[string.lower(string.gsub(name, "%s+", "_"))]
    end

    for _, v in pairs(ServerStorage.Fusions:GetChildren()) do
        local fusionModule = require(v)
        
        if table.find(possibleNames, string.lower(string.gsub(fusionModule.Name, "%s+", "_"))) ~= nil
            or table.find(possibleNames, string.lower(string.gsub(v.Name, "%s+", "_"))) ~= nil then
                fusion = require(v)

            -- Add to cache.
            TransfurService.Fusions[fusion.Name] = fusion
            TransfurService.Fusions[string.lower(string.gsub(v.Name, "%s+", "_"))] = fusion
            break
        end
    end

    return fusion
end

function TransfurService:GetTransfurFromPlayer(player)
    local name = PlayerService:GetCharacterValue(player, "Transfur")

    if name == nil then
        return nil
    end

    return TransfurService:GetTransfur(name)
end

-- Transfur functions
function TransfurService:TransfurPlayer(player, transfur)
    -- Do not transfur already transfurred players.
    if PlayerService:GetCharacterValue(player, "IsTransfur") == true then
        return
    end

    -- Assert that the transfur object is actually a transfur.
    if type(transfur) == "string" then
        transfur = TransfurService:GetTransfur(transfur) 
    end

    -- Well, there is no transfur. Whoops!
    if transfur == nil then
        return
    end

    -- Values to hold.
    local character = player.Character
    local humanoid = character.Humanoid
    local animator = humanoid.Animator

    -- Save the character CFrame early.
    local characterCFrame = character:GetPrimaryPartCFrame()

    -- Clone the goo from replicated storage.
    local goo = ReplicatedStorage.Goo:Clone()

    -- Set the color.
    if transfur.GooColor ~= nil then
        goo.Color = transfur.GooColor
    end

    -- Preserve hair extensions
    local function hasExtensions(name)
        return string.find(string.lower(name), "Hair") or string.find(string.lower(name), "cowlick")
    end

    -- Cancel all player animations.
    for _, v in pairs(animator:GetPlayingAnimationTracks()) do
        v:Stop()
    end

    -- Reserve custom animations per transfur.
    if transfur.CustomAnimation == true then
        transfur.RunAnimation(player)

        -- Don't run the base animation.
        return
    end

    -- Handle base changing animation.
    local changingAnimation = Instance.new("Animation")
        .AnimationId("rbxassetid://7991461634")

    -- Create and run animation track.
    local animationTrack = animator:LoadAnimation(changingAnimation.Build())
    animationTrack:Play()

    -- Handle the goos first.
    TransfurService:HandleGoo(character, {
        TransfurService:CreateGooHandle("Right Arm"),
        TransfurService:CreateGooHandle("Left Arm", 1.2),
        TransfurService:CreateGooHandle("Torso", 0.5),
        TransfurService:CreateGooHandle("Head", 1.2),
        TransfurService:CreateGooHandle("Left Leg", 0.3),
        TransfurService:CreateGooHandle("Right Leg"),   
    }, goo)

        -- Recolor hair colors and handle accessories.
        for _, v in pairs(character:GetChildren()) do
            if v:IsA("Accessory") then
                print("Accessory")
                if v.AccessoryType == Enum.AccessoryType.Hair or hasExtensions(v.Name) then
                    
                    -- Handle hair meshes and colors
                    for _, v2 in pairs(v.Handle:GetChildren()) do
                        if v2:IsA("FileMesh") then
                            v2.TextureId = ""

                            if transfur.ChangeHairColor == true then
                                TweenService:Create(v2, TweenInfo.new(0.5),
                                {
                                    VertexColor = Vector3.new(goo.Color.r, goo.Color.g, goo.Color.b)
                                }):Play()
                            end
                        end
                    end

                    
                    TweenService:Create(v.Handle, TweenInfo.new(0.65),
                    {
                        Color = goo.Color
                    }):Play()
                else 
                    -- Disable accessory collision and tween the part to transparency.
                    --v.Handle.CanCollide = false
    
                    local transparencyTween = TweenService:Create(v.Handle,
                        TweenInfo.new(1.06),
                        {
                            Transparency = 1
                        }
                    )
    
                    -- Delete accessory welds.
                    if v.Handle:FindFirstChild("AccessoryWeld") ~= nil then
                        v.Handle.AccessoryWeld:Destroy()
                    end
    
                    -- Run the tween, then schedule its removal.
                    local handledTween = false
    
                    Scheduler:Schedule(function()
                        if handledTween == false then
                            return false
                        end
    
                        v:Destroy()
    
                        -- The tween is handled.
                        return true
                    end)
    
                    -- Wrap the event around a coroutine.
                    coroutine.wrap(function()
                        transparencyTween:Play()
                        transparencyTween.Completed:Wait()
    
                        -- The tween is finished.
                        handledTween = true
                    end)()
                end
            end
        end

    -- Set body colors.
	character["Body Colors"].HeadColor3 = goo.Color
	character["Body Colors"].LeftArmColor3 = goo.Color
	character["Body Colors"].LeftLegColor3 = goo.Color
	character["Body Colors"].RightArmColor3 = goo.Color
	character["Body Colors"].RightLegColor3 = goo.Color
	character["Body Colors"].TorsoColor3 = goo.Color

    -- Assign shirt and pants to none.
    character.Shirt.ShirtTemplate = ""
    character.Pants.PantsTemplate = ""

    if transfur.DestroyFace == true then
        character.Head.face:Destroy()
    end

    -- Destroy goos.
    TransfurService:DestroyAllGoo(character)

    -- Run transfur handlers.
    if transfur.OnTransfurComplete ~= nil then
        transfur.OnTransfurComplete(player)
    end
end

-- your momay gay

-- Transfur Handler functions
function TransfurService:HandleGoo(character, partList, goo)
    local gooList = {}

    for _, v in ipairs(partList) do
        if v.Part == "Head" then
            table.insert(gooList, TransfurService:HandleHeadGoo(character, goo, v.GooDelay))
            continue
        end
        
        local partGoo = goo:Clone()
        local part = character:FindFirstChild(v.Part)
        local gooWeld = Instance.new("Weld")
            .Part0(part)
            .Part1(partGoo)
            .Parent(part)

        -- Assign goo details
        partGoo.Size = part.Size
        partGoo.Mesh.Scale = Vector3.new(part.Size.X + 0.05, 0, 1.05)
        partGoo.Mesh.Offset = Vector3.new(0, 1, 0)
        partGoo.Transparency = 1

        -- Rename part.
        partGoo.Name = part.Name .. " Goo"
        partGoo.Parent = character

        table.insert(gooList, {
            Goo = partGoo;
            GooDelay = v.GooDelay or 0;
            Tween = TweenService:Create(partGoo.Mesh,
                TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {
                    Scale = partGoo.Mesh.Scale + Vector3.new(0, 1.05, 0);
                    Offset = Vector3.new(0, 0, 0);
                }
            );
        })
    end

    -- Handle goo tweens.
    for _, v in ipairs(gooList) do
        if v.GooDelay ~= 0 then
            task.wait(v.GooDelay) 
        end

        -- Run tween.
        v.Goo.Transparency = 0
        v.Tween:Play()
        v.Tween.Completed:Wait()
    end
end

function TransfurService:HandleHeadGoo(character, goo, gooDelay)
    -- Create head goo individually.
    local headGoo = goo:Clone()
    local head = character:FindFirstChild("Head")
    local headWeld = Instance.new("Weld")
        .Part0(head)
        .Part1(headGoo)
        .Parent(head)

    headGoo.Parent = character
    headGoo.Name = "Head Goo"
    headGoo.Size = head.Size
    headGoo.Transparency = 1

    -- create new mesh
    local headMesh = Instance.new("SpecialMesh")
        .Name("HeadMesh")
        .MeshType(Enum.MeshType.Head)
        .Scale(Vector3.new(1.25,0,1.25))
        .Parent(headGoo)
    
    headGoo.Mesh:Destroy()
    
    return {
        Goo = headGoo;
        GooDelay = gooDelay;
        Tween = TweenService:Create(headGoo.HeadMesh,
        TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        {
            Scale = Vector3.new(1.27,1.27,1.27),Offset = Vector3.new(0,0,0)
        });

    }
end

function TransfurService:DestroyAllGoo(character)
    for _, v in pairs(character:GetChildren()) do
        if string.find(v.Name, "Goo") ~= nil then
            v:Destroy()
        end
    end
end 

function TransfurService:CreateGooHandle(part, gooDelay)
    return {
        Part = part;
		GooDelay = gooDelay;
    }
end

-- Support functions.
function TransfurService:RemoveHeadWelds(player)
	for _, child in ipairs(player.Character.Head:GetChildren()) do
		if child.Name == "HeadWeld" then
			child:Destroy()
		end
	end
end


function TransfurService:CreateWeld(from, to, cframe)
    local weld = Instance.new("Weld")
        .Name("TransfurWeld")
        .C0(cframe or CFrame.new(0, 0, 0)) -- CFrame.new(0, -0.6, 0)
        .Part0(from) -- transfurEars.Handle
        .Part1(to) -- player.Character:FindFirstChild("Head")
        .Parent(to) -- player.Character:FindFirstChild("Head")

    return weld.Build()
end

function TransfurService:AmendPartToTransfur(transfur, part, size)
    if type(transfur) == "string" then
        transfur = TransfurService:GetTransfur(transfur) 
    end

    -- Well, there is no transfur. Whoops!
    if transfur == nil then
        return
    end

    if part:FindFirstChild("Handle") then
        part.Handle.Size = size
        part.Handle.Color = transfur.GooColor or Color3.fromRGB(255, 255, 255)
    else 
        part.Size = size
        part.Color = transfur.GooColor or Color3.fromRGB(255, 255, 255)
    end
end

return TransfurService
