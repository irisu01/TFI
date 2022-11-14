-- Global Module
local YukiCore = _G.YukiCore

-- Services
local TweenService = game:GetService("TweenService")
local TransfurService = YukiCore.Import("Services/TransfurService")
local AnimationUtils = YukiCore.Import("Libraries/AnimationUtils")

return {
    -- Transfur information
    Name = "Testy";
    Description = "this is my new wife (is it even female)";
    GooColor = Color3.fromRGB(0, 0, 0);

    -- Bestiary Data
    Icon = "";
    Creator = "";
    EnvironmentType = "Comedy Zone";
    CommunityTransfur = false;
    PrimaryColors = { "White" };
    Habits = { "Merely exists" };
    Visible = false;

    -- Base statistics
    KillWorth = 50;
    Health = 100;

    -- Transfur change data
    CustomAnimation = false;
    ChangeHairColor = true;
    DestroyFace = true;

    -- Transfur functions
    OnTransfurComplete = function(player)
        -- Create a tween handler.
        local tweenHandler = AnimationUtils:CreateTweenHandler()

        -- Add face to player.
        local transfurFace = YukiCore.Instance("TransfurAssets/Testy/Face"):Clone()
        transfurFace.Parent = player.Character:FindFirstChild("Head")

        -- Create tail and ear welds.
        local transfurTail = YukiCore.Instance("TransfurAssets/Testy/Tail"):Clone()
        local transfurEars = YukiCore.Instance("TransfurAssets/Testy/Ears"):Clone()


        -- Amend the parts to transfur specifications.
        TransfurService:AmendPartToTransfur("Testy", transfurTail, Vector3.new(0, 0, 0))
        TransfurService:AmendPartToTransfur("Testy", transfurEars, Vector3.new(0, 0, 0))

        transfurTail.Parent = player.Character
        transfurEars.Parent = player.Character

        -- Create transfur welds.
        TransfurService:CreateWeld(transfurTail.Handle, player.Character:FindFirstChild("Torso"), CFrame.new(0, 1, -1.3))
        TransfurService:CreateWeld(transfurEars.Handle, player.Character:FindFirstChild("Head"), CFrame.new(0, -0.6, 0))
        
        -- TODO: Remedy this automatically.
        TransfurService:RemoveHeadWelds(player)

        -- Create tweens.
        tweenHandler:Add("TailTween",
            TweenService:Create(transfurTail.Handle,
            TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {
                Size = Vector3.new(1.159, 2.374, 3.484)
            }))
            
        tweenHandler:Add("EarTween",
            TweenService:Create(transfurEars.Handle,
            TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {
                Size = Vector3.new(1.526, 0.905, 0.735)
            }))

        tweenHandler:PlayAll()
        tweenHandler:WaitForAll()
    end;

    --[[RunAnimation = function(self, player)
        -- TODO: custom transfur animation
    end;]]

    -- Kill functions
    OnPlayerKill = function(player, killer, assistKillers)

    end;

    -- Temperature functions
    OnHypothermia = function(player)
        
    end;

    OnHypethermia = function(player)
        
    end;
}