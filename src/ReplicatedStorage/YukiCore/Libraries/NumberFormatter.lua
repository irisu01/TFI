local NumberFormatter = {}

-- Types
local BigNum = _G.YukiCore.Import("Types/BigNum")

-- Constants
local NumberSuffixes = {
	-- { places, suffix }
	{ 3, "k" },
	{ 6, "m" },
	{ 9, "b" },
	{ 12, "T" },
	{ 15, "Qd" },
	{ 18, "Qn" },
	{ 21, "sx" },
	{ 24, "Sp" },
	{ 27, "O" },
	{ 30, "N" }
}

local HardLimit = BigNum.new("1" .. string.rep("0", NumberSuffixes[#NumberSuffixes][1]))

function NumberFormatter:FormatString(str)
	local formattedNumber = ""
	local suffixIndex = 1
	local remainder = 1
	
	-- don't start below thousand
	if string.len(str) < 4 then
		return str
	end
	
	-- don't go above the last possible accepted suffix
	if string.len(str) > NumberSuffixes[#NumberSuffixes][1] then
		-- convert the string to scientific notation
	end
	
	for index = 1, string.len(str) do
		if NumberSuffixes[suffixIndex][1] == index and string.len(str) > index + 2 then
			suffixIndex = suffixIndex + 1
		end
	end
	
	if string.len(str) % 3 ~= 0 then
		-- calculate remainder
		local places = NumberSuffixes[suffixIndex][1]
		
		remainder = (string.len(str) - places)
	else
		remainder = 3
		suffixIndex = suffixIndex - 1
	end
	
	-- format number
	formattedNumber = string.sub(str, 1, remainder) .. "." .. string.sub(str, remainder + 1, remainder + 2) .. NumberSuffixes[suffixIndex][2]
	
	return formattedNumber
end

return NumberFormatter
