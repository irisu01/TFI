local YukiCore = _G.YukiCore
    
-- Packages
local Roact = YukiCore.Require("roact")

-- Components
local TemperatureBarComponent = YukiCore.Import("Components/TemperatureGui/TemperatureBarComponent")

-- Component
local TemperatureBarGui = Roact.Component:extend("TemperatureBarGui")

function TemperatureBarGui:render()
    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false;
    }, {
        TemperatureBar = Roact.createElement()
    })
end

return TemperatureBarGui