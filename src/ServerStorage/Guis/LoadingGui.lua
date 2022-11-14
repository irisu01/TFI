local YukiCore = _G.YukiCore
    
-- Packages
local Roact = YukiCore.Require("roact")

-- Component
local LoadingGui = Roact.Component:extend("LoadingGui")

function LoadingGui:render()
    return Roact.createElement("ScreenGui", {
        DisplayOrder = 2;
        Enabled = false;
        IgnoreGuiInset = true;
    }, {
        BackgroundFrame = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 1);
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            ZIndex = 20;
        }, {

            LoadingFrame = Roact.createElement("Frame", {
                Size = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);
                Position = UDim2.fromScale(0.5, 0.5);
    
                BackgroundTransparency = 1;
                ZIndex = 20;
            }, {
                LoadingProgressText = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(0.15, 0.25);
                    AnchorPoint = Vector2.new(0.5, 0.5);
                    Position = UDim2.fromScale(0.5, 0.325);
    
                    BackgroundTransparency = 1;
                    Text = "Loading...";
                    TextColor3 = Color3.new(1, 1, 1);
                    ZIndex = 20;
                });
    
                LoadingCountText = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(0.05, 0.15);
                    AnchorPoint = Vector2.new(0.5, 0.5);
                    Position = UDim2.fromScale(0.5, 0.625);
    
    
                    BackgroundTransparency = 1;
                    Text = "0/0";
                    TextColor3 = Color3.new(1, 1, 1);
                    ZIndex = 20;
                });
    
                LoadingBar = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(0.5, 0.1);
                    Position = UDim2.fromScale(0.5, 0.5);
                    AnchorPoint = Vector2.new(0.5, 0.5);
    
                    BorderSizePixel = 0;
                    BackgroundColor3 = Color3.new(1, 1, 1);
                    ZIndex = 22;
                }, {
                    LoadingBarFill = Roact.createElement("Frame", {
                        Size = UDim2.fromScale(0, 1);
                        Position = UDim2.fromScale(0, 0);
    
                        BorderSizePixel = 0;
                        BackgroundColor3 = Color3.new(0, 0, 0);
                        ZIndex = 23;
                    })
                });
    
                LoadingBarBorder = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(0.505, 0.115);
                    Position = UDim2.fromScale(0.5, 0.5);
                    AnchorPoint = Vector2.new(0.5, 0.5);
    
                    BackgroundColor3 = Color3.new(0, 0, 0);
                    BorderColor3 = Color3.new(1, 1, 1);
                    ZIndex = 21;
                });
            });
    
            LoadingFrameOverlay = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);
                Position = UDim2.fromScale(0.5, 0.5);
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
    
                BackgroundTransparency = 1;
                ZIndex = 23;
            });
        });
    })
end

return LoadingGui