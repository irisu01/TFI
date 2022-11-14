local TemperatureController = {
    Importable = true;
}

-- Global Module
local YukiCore = _G.YukiCore

-- Services
local Players = game:GetService("Players")
local PlayerService = YukiCore.Import("Services/PlayerService")

-- Internal constants
-- All temperatures are in Celsius
local NORMAL_AMBIENT_TEMPERATURE = 20
local COOLING_AMBIENT_BOUND = 0
local HEATING_AMBIENT_BOUND = 50

local NORMAL_TEMPERATURE = 37

local DEFAULT_HP = 100
local DEFAULT_SPEED = 16

local REGION3_SIZE = Vector3.new(5, 5, 5)
local PLAYER_CHECK = {}
local PLAYER_DEBOUNCE = {}
local AURORA_TICKS = {}

function TemperatureController.SetAmbientTemperature(temperature)
    TemperatureController.Server.SetValue("AmbientTemperature", temperature)
end

function TemperatureController.OnExecute()
	-- Add global values.
    TemperatureController.Server.AddValue("IntValue", "AmbientTemperature", NORMAL_AMBIENT_TEMPERATURE)

    -- Add player handlers.
    Players.PlayerAdded:Connect(function(Player) TemperatureController.onPlayerAdded(Player) end)
    Players.PlayerRemoving:Connect(function(Player) PLAYER_CHECK[Player.UserId] = false end)

    -- Set ambient temperature.
    TemperatureController.SetAmbientTemperature(NORMAL_AMBIENT_TEMPERATURE)
end

function TemperatureController.OnStep()
    for _, Player in pairs(Players:GetPlayers()) do
        if PLAYER_CHECK[Player.UserId] then
            TemperatureController.onPlayerUpdate(Player)
        end
    end
end

function TemperatureController.onPlayerAdded(player)
    PLAYER_CHECK[player.UserId] = true
    player.CharacterAdded:Connect(function(character)
        PlayerService:AddCharacterValue(player, "IntValue", "Temperature", NORMAL_TEMPERATURE) 
        PlayerService:AddCharacterValue(player, "IntValue", "NaturalTemperature", NORMAL_TEMPERATURE) 
    end)
end


function TemperatureController.onPlayerUpdate(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character.Humanoid
    local playerTemperature = PlayerService:GetCharacterValue(player, "Temperature")
    local playerNaturalTemperature = PlayerService:GetCharacterValue(player, "NaturalTemperature")

    -- Set values
    local HYPOTHERMIA_BOUND =  playerNaturalTemperature - 2
    local HYPERTHERMIA_BOUND = playerNaturalTemperature + 3
    local MAX_TEMPERATURE = playerNaturalTemperature + 5
    local MIN_TEMPERATURE = playerTemperature - 11
    
    local region = Region3.new(
        character.HumanoidRootPart.Position - REGION3_SIZE,
        character.HumanoidRootPart.Position + REGION3_SIZE
    )

    local parts = workspace:FindPartsInRegion3WithIgnoreList(region, { character });
    local temperatureChanged = false
    
    if table.find(PLAYER_DEBOUNCE, player.UserId) ~= nil then
        return
    end

    -- add debounce
    table.insert(PLAYER_DEBOUNCE, player.UserId)

    local function updatePlayerTemperatureFromLocalTemperature(localTemperature)
        temperatureChanged = true
        local tempChange = 0
        
        if localTemperature.Value >= HEATING_AMBIENT_BOUND then
            tempChange = localTemperature.Value - HEATING_AMBIENT_BOUND
        elseif localTemperature.Value <= COOLING_AMBIENT_BOUND then
            tempChange = localTemperature.Value + COOLING_AMBIENT_BOUND
        end

        if playerTemperature > MAX_TEMPERATURE and tempChange >= 1 or
            playerTemperature < MIN_TEMPERATURE and tempChange <= -1
        then
            tempChange = 0

            -- TODO: Fatal effects of reaching these maximums

            if playerTemperature < MIN_TEMPERATURE then
                -- hypothermia

                if AURORA_TICKS[player.UserId] == nil then
                    AURORA_TICKS[player.UserId] = 0
                end

                AURORA_TICKS[player.UserId] = AURORA_TICKS[player.UserId] + 1

                if AURORA_TICKS[player.UserId] == 5 then
                    print("Player " .. player.Name .. " has hypothermia")
                end
            elseif playerTemperature > MAX_TEMPERATURE then
                -- hyperthermia
            end
        else
            -- reest aurora cd
            if AURORA_TICKS[player.UserId] == nil then
                AURORA_TICKS[player.UserId] = 0
            end
        end

        PlayerService:SetCharacterValue(player, "Temperature", playerTemperature + tempChange)
    end

    for _, v in pairs(parts) do
        if temperatureChanged == true then
            break
        end

        local localTemperature = v:FindFirstChild("LocalTemperature")

        if localTemperature ~= nil then
            updatePlayerTemperatureFromLocalTemperature(localTemperature)
        else
            -- Handle natural temperatures
            if playerTemperature > playerNaturalTemperature then
                -- Decrease by 1.
                PlayerService:SetCharacterValue(player, "Temperature", playerTemperature - 1)
            elseif playerTemperature < playerNaturalTemperature then
                -- Increment by 1.
                PlayerService:SetCharacterValue(player, "Temperature", playerTemperature + 1)
            end
        end
    end

    print(playerTemperature)

    local function updatePlayerHealthAndSpeed()
        if playerTemperature <= HYPOTHERMIA_BOUND then
            -- decrease player max hp in proportion to how far away from the boundary they are
            local HYPOTHERMIA_HP_DECREASE = (HYPOTHERMIA_BOUND - playerTemperature) * 2
            humanoid.MaxHealth = DEFAULT_HP - HYPOTHERMIA_HP_DECREASE

            -- lower walk speed with the same proportions
            local HYPOTHERMIA_SPEED_DECREASE = 0.5 * (HYPOTHERMIA_BOUND - playerTemperature)
            PlayerService:SetCharacterValue(player, "WalkSpeedMultiplier", (DEFAULT_SPEED - HYPOTHERMIA_SPEED_DECREASE) / DEFAULT_SPEED)
        elseif playerTemperature >= HYPERTHERMIA_BOUND then
            PlayerService:SetCharacterValue(player, "WalkSpeedMultiplier", 1)
        else
            humanoid.MaxHealth = DEFAULT_HP
        end
    end

    updatePlayerHealthAndSpeed()

    coroutine.wrap(function()
        task.wait(0.5)
        table.remove(PLAYER_DEBOUNCE, table.find(PLAYER_DEBOUNCE, player.UserId))
    end)()
end

return TemperatureController