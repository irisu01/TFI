local YukiCore = _G.YukiCore

-- Packages
local Roact = YukiCore.Require("roact")

-- Component
local MainMenuGui = Roact.Component:extend("MainMenuGui")

function MainMenuGui:render()
	return Roact.createElement("ScreenGui", {
        --Size = UDim2.fromScale(1, 1);
		Enabled = false,
        DisplayOrder = 1;
        IgnoreGuiInset = true;
	}, {
        TopBar = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.15);
            ZIndex = 2;

            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
        });

        LogoFrame = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.65, 0.45);
            Position = UDim2.fromScale(0.5, 0.3);
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1,
        }, {
            The = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(0.5, 0.075);
                Position = UDim2.fromScale(0.365, 0.4);
                AnchorPoint = Vector2.new(0.5, 0.5);

                Text = "THE",
                TextScaled = true,
                TextColor3 = Color3.new(1, 1, 1);
                Font = Enum.Font.GothamBlack,
                BackgroundTransparency = 1,
            });

            Fursaken = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(0.95, 0.185);
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);

                Text = "FURSAKEN",
                TextScaled = true,
                TextColor3 = Color3.new(1, 1, 1);
                Font = Enum.Font.GothamBlack,

                BackgroundTransparency = 1,
            });

            FursakenPulse = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(0.915, 0.205);
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);

                Text = "FURSAKEN",
                TextScaled = true,
                Font = Enum.Font.GothamBlack,
                
                TextTransparency = 1,
                BackgroundTransparency = 1,
            }, {
                Stroke = Roact.createElement("UIStroke", {
                    Color = Color3.new(1, 1, 1);

                    Transparency = 0;
                    Thickness = 1;
                });
            });

            Incident = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(0.5, 0.075);
                Position = UDim2.fromScale(0.625, 0.6);
                AnchorPoint = Vector2.new(0.5, 0.5);

                Text = "INCIDENT",
                TextScaled = true,
                TextColor3 = Color3.new(1, 1, 1);
                Font = Enum.Font.GothamBlack,

                BackgroundTransparency = 1,
            });
        });

        ButtonFrame = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.65, 0.45);
            Position = UDim2.fromScale(0.5, 0.75);
            AnchorPoint = Vector2.new(0.5, 0.5);

            BackgroundTransparency = 1,
        }, {
            UIListLayout = Roact.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0.05, 0);
            });

            PlayButton = Roact.createElement("TextButton", {
                Size = UDim2.fromScale(0.25, 0.15);
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);

                Text = "PLAY",
                TextScaled = true,
                TextColor3 = Color3.new(1, 1, 1);
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(1, 1, 1);
                Font = Enum.Font.Gotham,
            }, {
                UIPadding = Roact.createElement("UIPadding", {
                    PaddingLeft = UDim.new(0.05, 0);
                    PaddingRight = UDim.new(0.05, 0);
                    PaddingTop = UDim.new(0.1, 0);
                    PaddingBottom = UDim.new(0.1, 0);
                });
            });

            SettingsButton = Roact.createElement("TextButton", {
                Size = UDim2.fromScale(0.25, 0.15);
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);

                Text = "SETTINGS",
                TextScaled = true,
                TextColor3 = Color3.new(1, 1, 1);
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(1, 1, 1);
                Font = Enum.Font.Gotham,
            }, {
                UIPadding = Roact.createElement("UIPadding", {
                    PaddingLeft = UDim.new(0.05, 0);
                    PaddingRight = UDim.new(0.05, 0);
                    PaddingTop = UDim.new(0.1, 0);
                    PaddingBottom = UDim.new(0.1, 0);
                });
            });

            --[[CreditsButton = Roact.createElement("TextButton", {
                Size = UDim2.fromScale(0.25, 0.15);
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);

                Text = "CREDITS",
                TextScaled = true,
                TextColor3 = Color3.new(1, 1, 1);
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(1, 1, 1);
                Font = Enum.Font.Gotham,
            }, {
                UIPadding = Roact.createElement("UIPadding", {
                    PaddingLeft = UDim.new(0.05, 0);
                    PaddingRight = UDim.new(0.05, 0);
                    PaddingTop = UDim.new(0.1, 0);
                    PaddingBottom = UDim.new(0.1, 0);
                });
            });]]--
        });

        BottomBar = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.15);
            Position = UDim2.fromScale(0, 0.85);
            ZIndex = 2;

            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
        });
	})
end

return MainMenuGui
