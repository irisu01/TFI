local InventoryController = {
	Importable = true,
	PlayerTable = {},
}

-- Global Module
local YukiCore = _G.YukiCore

-- Services
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local PlayerService = YukiCore.Import("Services/PlayerService")
local RarityService = YukiCore.Import("Services/RarityService")
local AnimationService = YukiCore.Import("Services/AnimationService", game.ReplicatedStorage)

-- Packages
local Roact = YukiCore.Require("roact")

-- Assets
YukiCore.Import("Libraries/InstanceBuilder")
local InventoryGui = YukiCore.Import("Guis/InventoryGui")
local Item = YukiCore.Import("Components/InventoryGui/Item")

-- Events
function InventoryController.OnExecute()
	print("Exec")
	-- Create client bridges.
	InventoryController.Server.RegisterBridge("SelectItem", InventoryController.OnItemSelect)

	-- Handle player startup.
	local starterInventory = StarterPlayer:FindFirstChild("StarterInventory")
	Players.PlayerAdded:Connect(function(player)
		-- Assign default values to the player
		PlayerService:AddPlayerValue(player, "ObjectValue", "CurrentHeldItem", nil)
		PlayerService:AddPlayerValue(player, "ObjectValue", "CurrentHeldItemReference", nil)

		-- Handle item adding and removal events
		local playerInventory = player:FindFirstChild("PlayerInventory")

		playerInventory.ChildAdded:Connect(function(item)
			InventoryController.OnItemAdded(player, item)
		end)

		playerInventory.ChildRemoved:Connect(function(item)
			InventoryController.OnItemRemoved(player, item)
		end)

		-- Handle player inventory startup.
		player.CharacterAdded:Connect(function(character)
			-- Reset the values.
			PlayerService:SetPlayerValue(player, "CurrentHeldItem", nil)
			PlayerService:SetPlayerValue(player, "CurrentHeldItemReference", nil)

			local player = Players:GetPlayerFromCharacter(character)
			InventoryController.PlayerTable[player.UserId] = {
				Items = {},
			}

			for _, v in pairs(starterInventory:GetChildren()) do
				local item = v:Clone()

				item.Parent = playerInventory
			end
		end)

		player.CharacterRemoving:Connect(function(character)
			-- Clear all the player's items.
			playerInventory:ClearAllChildren()
		end)
	end)
end

function InventoryController.OnItemSelect(player, itemIndex)
	-- Get player item data.
	local playerItemData = InventoryController.PlayerTable[player.UserId]
	local item = playerItemData.Items[itemIndex]

	-- Check whether the player is holding an item or not.
	if playerItemData.Holding ~= nil then
		-- Delete the item the player is holding.
		playerItemData.HoldingCharacter:Destroy()

		-- Run item animation.
		local elementIcon = playerItemData.Holding.ElementReference
		AnimationService:RunKeyframesAtOnce({
			AnimationService:CreateObjectKeyframe(
				elementIcon,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					BackgroundTransparency = 0.55,
				}
			),

			AnimationService:CreateObjectKeyframe(
				elementIcon.SubtleBackground,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					BackgroundTransparency = 0.65,
				}
			),
			AnimationService:CreateObjectKeyframe(
				elementIcon.ItemStroke,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					Thickness = 2;
					Transparency = 0.55,
				}
			),
		})

		-- Check whether the key is the same as the item.
		if playerItemData.Holding.ItemIndex == itemIndex then
			-- Change the reference to nil.
			playerItemData.Holding = nil
			return
		end

		-- Change the reference to nil.
		playerItemData.Holding = nil
	end

	if item ~= nil then
		-- Clone the item, then parent it to the player's character.
		local itemHoldable = item.Item:Clone()
		itemHoldable.Parent = player.Character

		-- Set the player's current held item.
		playerItemData.Holding = item
		playerItemData.HoldingCharacter = itemHoldable

		-- Run item animation.
		local elementIcon = item.ElementReference
		AnimationService:RunKeyframesAtOnce({
			AnimationService:CreateObjectKeyframe(
				elementIcon,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					BackgroundTransparency = 0,
				}
			),

			AnimationService:CreateObjectKeyframe(
				elementIcon.SubtleBackground,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					BackgroundTransparency = 0.15,
				}
			),

			AnimationService:CreateObjectKeyframe(
				elementIcon.ItemStroke,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					Thickness = 4;
					Transparency = 0.15,
				}
			),
		})
	end
end

function InventoryController.OnItemAdded(player, item)
	-- Get player item data.
	local playerItemData = InventoryController.PlayerTable[player.UserId]

	-- Don't allow more than 10 items.
	if #playerItemData.Items == 10 then
		item:Remove()
		return
	end

	-- Calculate item rarity gradient colors.
	local itemRarityGradient =
		RarityService:GetRarityGradient(item:FindFirstChild("Rarity") and item.Rarity.Value or "Common")

	-- Translate the first color of the gradient to HSV.
	local h, s, v = itemRarityGradient.Keypoints[1].Value:ToHSV()

	-- Calculate the label color, and it's stroke.
	local labelColor = Color3.fromHSV(h, math.max(0, s * 0.25), v)
	local labelStroke = Color3.fromHSV(h, math.max(0, s * 0.25), math.max(0, v * 0.65))

	-- Get the first possible index for the item
	-- Add the item to table.
	table.insert(playerItemData.Items, {
		Item = item,
		ItemIndex = #playerItemData.Items + 1,
		ItemName = item:FindFirstChild("DisplayName") and item.DisplayName.Value or item.Name,
		ItemIcon = (item.TextureId ~= nil and item.TextureId ~= "") and item.TextureId or nil,
		ItemBackgroundColor = itemRarityGradient,
		ItemLabelColor = labelColor,
		ItemLabelStroke = labelStroke,
	})

	-- Rerender items.
	-- Map the items into a fragment table.
	local elementMap = InventoryController.RenderItems(playerItemData)

	YukiCore.UpdateRoactHandle(
		"InventoryGui__" .. player.UserId,
		Roact.createElement(InventoryGui, {
			Items = Roact.createFragment(elementMap),
		})
	)
end

function InventoryController.OnItemRemoved(player, item)
	-- Get player item data.
	local playerItemData = InventoryController.PlayerTable[player.UserId]

	-- Get position in the inventory.
	for _, v in ipairs(playerItemData.Items) do
		if v.Item == item then
			print(playerItemData)
			if playerItemData.Holding.ItemIndex == v.ItemIndex then
				-- Delete the item the player is holding.
				playerItemData.HoldingCharacter:Destroy()

				-- Change the reference to nil.
				playerItemData.Holding = nil
			end

			-- Remove the item from the table.
			table.remove(playerItemData.Items)
		end
	end

	-- Reindex every item.
	for i, v in ipairs(playerItemData.Items) do
		v.ItemIndex = i
	end

	-- Rerender items.
	-- Map the items into a fragment table.
	local elementMap = InventoryController.RenderItems(playerItemData)

	YukiCore.UpdateRoactHandle(
		"InventoryGui__" .. player.UserId,
		Roact.createElement(InventoryGui, {
			Items = Roact.createFragment(elementMap),
		})
	)
end

-- Ease-of-use functions
function InventoryController.RenderItems(itemData)
	local elementMap = {}

	for index, item in ipairs(itemData.Items) do
		item.Element = Roact.createElement(Item, {
			ItemIndex = index,
			ItemData = item,
		})

		table.insert(elementMap, item.Element)
	end

	return elementMap
end

function InventoryController.SetItemReference(item, ref)
	item.ElementReference = ref
end

return InventoryController
