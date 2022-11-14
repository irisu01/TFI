local YukiCore = _G.YukiCore

-- Packages
local Roact = YukiCore.Require("roact")

-- Assets

-- Component
local ItemComponent = Roact.Component:extend("ItemComponent")

function ItemComponent:init()
    self.ownRef = Roact.createRef()
end

function ItemComponent:render()
    -- Choose whether to use an icon, or not.
    if self.props.ItemData.ItemIcon then
        return Roact.createElement("Frame", {
			[Roact.Ref] = self.ownRef;
            
            Name = self.props.ItemData.ItemName;
            ClipsDescendants = true;
            Size = UDim2.new(1, 0, 1, 0);
            AnchorPoint = Vector2.new(0.5, 0);
            
            BackgroundTransparency = 0.25;
        }, {
            Icon = Roact.createElement("ImageLabel", {
                Name = "Icon";
                BackgroundTransparency = 1;
                Size = UDim2.new(0.75, 0, 0.75, 0);
                Position = UDim2.new(0.5, 0, 0.5, 0);
                AnchorPoint = Vector2.new(0.5, 0.5);

                Image = self.props.ItemData.ItemIcon;
            })
        })
    else
        return Roact.createElement("Frame", {
			[Roact.Ref] = self.ownRef;
            
            Name = self.props.ItemData.ItemName;
            ClipsDescendants = true;
            Size = UDim2.new(1, 0, 1, 0);
            AnchorPoint = Vector2.new(0.5, 0);
            
            BackgroundTransparency = 0.55;
        }, {
            SubtleBackground = Roact.createElement("Frame", {
                Name = "SubtleBackground";
                Size = UDim2.new(1, 0, 1, 0);

                BackgroundColor3 = Color3.new(0, 0, 0);
                BackgroundTransparency = 0.65;
            }, {
                BackgroundRounding = Roact.createElement("UICorner", {
                    Name = "BackgroundCorner";
                    CornerRadius = UDim.new(0, 2);
                })
            });

            ItemIndexLabel = Roact.createElement("TextLabel", {
                Name = "ItemIndexLabel";
                Text = self.props.ItemIndex .. ".";
                Position = UDim2.new(0, 0, 0, 0);
                Size = UDim2.new(0.25, 0, 0.25, 0);

                TextSize = 7;
                TextColor3 = self.props.ItemData.ItemLabelColor;
                TextStrokeColor3 = self.props.ItemData.ItemLabelStroke; 
                TextStrokeTransparency = 0.55;
                BackgroundTransparency = 1;
            });

            ItemLabel = Roact.createElement("TextLabel", {
                Name = "ItemLabel";
                Text = self.props.ItemData.ItemName;
                Size = UDim2.new(1, 0, 1, 0);

                TextColor3 = self.props.ItemData.ItemLabelColor;
                TextStrokeColor3 = self.props.ItemData.ItemLabelStroke; 
                TextStrokeTransparency = 0.55;
                BackgroundTransparency = 1;
            });

            ItemBackground = Roact.createElement("UIGradient", {
                Name = "ItemBackgroud";
                Color = self.props.ItemData.ItemBackgroundColor;
            });

            ItemStroke = Roact.createElement("UIStroke", {
                Name = "ItemStroke";

                Thickness = 2;
                Transparency = 0.55;
            }, {
                ItemStrokeColor = Roact.createElement("UIGradient", {
                    Name = "ItemStrokeColor";
                    Color = self.props.ItemData.ItemBackgroundColor;
                })
            });

            ItemRounding = Roact.createElement("UICorner", {
                Name = "ItemCorner";
                CornerRadius = UDim.new(0, 2);
            })

        })
    end
end

function ItemComponent:didMount()
    local InventoryController = YukiCore.Server.GetControllerByName("InventoryController")

    -- Set the item's reference.
    print(InventoryController)
    print(self.ownRef)
    print(self.ownRef:getValue())
    InventoryController.SetItemReference(self.props.ItemData, self.ownRef:getValue())
end

return ItemComponent