local YukiCore = _G.YukiCore
    
-- Packages
local Roact = YukiCore.Require("roact")

-- Component
local InventoryGui = Roact.Component:extend("InventoryGui")

function InventoryGui:render()
    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false;
    }, {
        InventoryFrame = Roact.createElement("Frame", {
            Name = "InventoryFrame";
            Size = UDim2.new(0.295, 0, 0.095, 0);
            Position = UDim2.new(0.5, 0, 0.925, 0);
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
    
        }, {
            AspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint");
            ListLayout = Roact.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                Padding = UDim.new(0.15, 0);
            });
            
            InventoryItems = self.props.Items or Roact.createFragment({});
        })
    })
end

return InventoryGui