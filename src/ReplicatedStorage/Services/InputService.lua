local InputService = {
	Importable = true,
	CurrentInput = {},
	Inputs = {},
}

-- Global Module
local YukiCore = _G.YukiCore

-- Services
local UserInputService = game:GetService("UserInputService")

-- Assets
YukiCore.Import("Libraries/InstanceBuilder")

-- Constants
local started = false

-- SERVICE FUNCTIONS
function InputService:RegisterKeyboardInput(keycodes, callback, anyKey)
    if anyKey == nil then
        anyKey = true
    end
	local input = {
		KeyCodes = keycodes;
		Callback = callback;
        IsGlobal = anyKey;
	}

	table.insert(InputService.Inputs, input)

	print(InputService.Inputs)
end

-- SERVICE CODE
if started == false then
	UserInputService.InputBegan:Connect(function(currentInput, gameProcessedEvent)
		if gameProcessedEvent == true then
			return
		end

		if currentInput.UserInputType == Enum.UserInputType.Keyboard then
			-- Insert the input into the table
			table.insert(InputService.CurrentInput, currentInput.KeyCode)

			-- Check whether the input is a valid combo
			for _, input in pairs(InputService.Inputs) do
                local valid = true

                for _, keycode in pairs(input.KeyCodes) do
                    if table.find(InputService.CurrentInput, keycode) == nil then
                        valid = false
                    else
                        if input.IsGlobal == true then
                            valid = true
                        end 
                    end
                end

                if valid == true then
                    input.Callback(currentInput)
                end
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(currentInput, gameProcessedEvent)
		if gameProcessedEvent == true then
			return
		end

		if currentInput.UserInputType == Enum.UserInputType.Keyboard then
			-- Remove the input from the table
			for i, v in pairs(InputService.CurrentInput) do
				if v == currentInput.KeyCode then
					table.remove(InputService.CurrentInput, i)
				end
			end
		end
	end)
	started = true
end
return InputService
