local YukiCore = _G.YukiCore

-- Packages
local Roact = YukiCore.Require("roact")

-- Assets

-- Component
local TemperatureBarComponent = Roact.Component:extend("TemperatureBarComponent")

function TemperatureBarComponent:init()
    self.ref = Roact.createRef()
end

function TemperatureBarComponent:render()
    return Roact.createElement("Frame")
end
function TemperatureBarComponent:didMount()
    local InventoryController = YukiCore.Server.GetControllerByName("InventoryController")

    -- Set the item's reference.
    InventoryController.SetItemReference(self.props.ItemData, self.ref:getValue())
end

return TemperatureBarComponent