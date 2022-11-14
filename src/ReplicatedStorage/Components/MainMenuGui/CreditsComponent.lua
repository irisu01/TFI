local YukiCore = _G.YukiCore

-- Packages
local Roact = YukiCore.Require("roact")

-- Component
local CreditsComponent = Roact.Component:extend("CreditsComponent")

-- Constants
local credits = {
    Management = {
        {
            Username = "hakuflower";
            Nickname = "Yuki";
            AccreditedWith = "yuki lol";
            Icon = "rbxassetid://10910744975";
        },
    };
}

function CreditsComponent:render()
    local creditsElements = {
        Padding = Roact.createElement("UIPadding", {
            PaddingTop = UDim.new(0.035, 0);
            PaddingBottom = UDim.new(0.035, 0);
            PaddingLeft = UDim.new(0.015, 0);
            PaddingRight = UDim.new(0.015, 0);
        });

        ListLayout = Roact.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder;
            Padding = UDim.new(0, 5);
        });
    }

    for sectionName, sectionCredits in pairs(credits) do
        local sectionList = {
        }

        for _, user in ipairs(sectionCredits) do
            if user.Icon ~= nil then
                sectionList[user.Username] = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(1, 0.2);
                    BackgroundTransparency = 1;
                }, {
                    ListLayout = Roact.createElement("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal;
                        HorizontalAlignment = Enum.HorizontalAlignment.Center;
                        VerticalAlignment = Enum.VerticalAlignment.Center;
                    });

                    Icon = Roact.createElement("ImageLabel", {
                        Size = UDim2.fromOffset(32, 32);
                        BackgroundTransparency = 1;
                        Image = user.Icon;
                    });

                    Label = Roact.createElement("TextLabel", {
                        Size = UDim2.fromScale(0.5, 0.85);
                        BackgroundTransparency = 1;
                        Text = string.format("%s (%s) - %s", user.Nickname, user.Username, user.AccreditedWith);
                        TextColor3 = Color3.new(1, 1, 1);
                        TextScaled = true;
                    });
                })
            else
                sectionList[user.Username] = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(1, 0.25);
                }, {
                    ListLayout = Roact.createElement("UIListLayout", {
                        FillDirection = Enum.FillDirection.Vertical;
                        Padding = UDim.new(0, 5);
                    });

                    Label = Roact.createElement("TextLabel", {
                        Size = UDim2.fromScale(0.5, 0.25);
                        BackgroundTransparency = 1;
                        Text = string.format("%s (%s) - %s", user.Nickname, user.Username, user.AccreditedWith);
                        TextColor3 = Color3.new(1, 1, 1);
                        TextScaled = true;
                    });
                })
            end
        end

        creditsElements[sectionName] = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.25);
            BackgroundTransparency = 1;
        }, {
            ListLayout = Roact.createElement("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder;
                Padding = UDim.new(0.025, 0);
            });

            ListLabel = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.25);
                BackgroundTransparency = 1;

                Text = sectionName;
                TextColor3 = Color3.new(0, 0, 0);
                Font = Enum.Font.SourceSansBold;
                TextScaled = true;
            }, {
                Stroke = Roact.createElement("UIStroke", {
                    Color = Color3.new(1, 1, 1);
                    Thickness = 1;
                })
            });

            List = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 0.75);
                BackgroundTransparency = 1;
            }, sectionList);
        })
    end

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(0.5, 0.5);
        Position = self.props.Position or UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);

        BorderMode = Enum.BorderMode.Outline;
        BorderColor3 = Color3.new(1, 1, 1);
        BackgroundTransparency = 1;
    }, {
        Stroke = Roact.createElement("UIStroke", {
            Color = Color3.new(1, 1, 1);
            Thickness = 1;
        });

        CreditsFrame = Roact.createElement("ScrollingFrame", {
            Size = UDim2.fromScale(0.95, 0.925);
            Position = UDim2.fromScale(0.5, 0.5);
            CanvasPosition = Vector2.new(-5, 0);
            AnchorPoint = Vector2.new(0.5, 0.5);
            
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(1, 1, 1);
            ScrollBarThickness = 0;
        }, creditsElements);
    })
end

return CreditsComponent