local bigint = {
	Importable = true;
}

function bigint.new(num)
	local self = {
		signal = "+";
		digits = {};
	}

	if num ~= nil then
		bigint.set(self, num)
	end

	-- set the metatable
	setmetatable(self, {
		-- utility events
		__tostring = function(self)
			if self.signal == "-" then
				return "-" .. table.concat(self.digits, "")
			end

			return table.concat(self.digits, "")
		end,
	})

	return self
end

function bigint.clone(from)
	local copy = bigint.new()

	for index, digit in ipairs(from.digits) do
		copy.digits[index] = digit
	end

	copy.sign = from.sign

	return copy
end

function bigint.mend(bn)
	-- non-negative zero
	if #bn.digits == 1 and bn.digits[1] == 0  then
		bn.signal = "+"
	else 
		while #bn.digits > 1 and bn.digits[1] == 0 do
			table.remove(bn.digits, 1)
		end
	end

	return bn
end

function bigint.absolute(bn)
	local result = bigint.clone(bn)
	
	result.signal = "+"
	
	return result
end
	
	
function bigint.arithmetic(lhs, rhs, add)
	if add == nil then
		add = true
	end

	local result = bigint.new()
	local max = 0
	local regroup = 0

	if add == true then
		if #lhs.digits >= #rhs.digits  then
			max = #lhs.digits
		else 
			max = #rhs.digits
		end
	else 
		result = bigint.clone(lhs)
		max = #lhs.digits
	end

	for index = 0, max - 1 do
		if add == true then
			local sum = (lhs.digits[#lhs.digits - index] or 0)
				+ (rhs.digits[#rhs.digits - index] or 0)
				+ regroup

			if sum >= 10 then
				regroup = 1
				sum = sum - 10
			else
				regroup = 0
			end
			
			result.digits[max - index] = sum
		else
			local diff = (lhs.digits[#lhs.digits - index] or 0)
			- (rhs.digits[#rhs.digits - index] or 0)
			- regroup

			if diff < 0 then
				regroup = 1
				diff = diff + 10
			else 
				regroup = 0
			end

			result.digits[max - index] = diff
		end
	end
	

	if add == true then
		if regroup == 1 then
			table.insert(result.digits, 1, 1)
		end
	else 
		while (#result.digits > 1) and (result.digits[1] == 0) do
			table.remove(result.digits, 1)
		end
	end
	
	result = bigint.mend(result)

	return result
end

function bigint.add(lhs, rhs)
	local result = bigint.new()
	
	if lhs.signal ~= rhs.signal then
		if bigint.greater(bigint.absolute(lhs), bigint.absolute(rhs)) then
			result = bigint.arithmetic(lhs, rhs, false)
			result.signal = lhs.signal
		else
			result = bigint.arithmetic(rhs, lhs, false)
			result.signal = rhs.signal
		end
	else
		result = bigint.arithmetic(lhs, rhs)

		if lhs.signal == "-" and rhs.signal == "-" then
			result.signal = "-"
		end
	end		

	result = bigint.mend(result)

	return result
end

function bigint.subtract(lhs, rhs)
	local rhsCopy = bigint.clone(rhs)

	if (rhs.signal == "+") then
		rhsCopy.signal = "-"
	else
		rhsCopy.signal = "+"
	end

	return bigint.add(lhs, rhsCopy)
end

function bigint.multiply(lhs, rhs)
	local result = bigint.new()
	local regroup = 0
	local larger, smaller

	if tostring(lhs) == "0" or tostring(rhs) == "0" then
		return result
	end

	if #lhs.digits >= #rhs.digits  then
		larger = lhs
		smaller = rhs
	else 
		larger = rhs
		smaller = lhs
	end

	for index1 = 0, #smaller.digits - 1 do
		local smaller_bn = bigint.new(smaller.digits[#smaller.digits - index1])
		local digit_result = bigint.new()
		regroup = 0

		for index2 = 0, #larger.digits - 1 do
			local product = larger.digits[#larger.digits - index2]
				* smaller_bn.digits[1]
				+ regroup

			if product >= 10 then
				regroup = math.floor(product / 10)
				product = product - (regroup * 10)
			else 
				regroup = 0
			end
			

			digit_result.digits[#larger.digits - index2] = product
		end
		print(regroup)
		print(digit_result)

		if regroup > 0 then
			table.insert(digit_result.digits, 1, regroup)
		end
		
		print(digit_result)

		if index1 > 0 then
			for placeholder_index = 1, index1 do
				table.insert(digit_result.digits, 0)
			end
		end
		
		print(digit_result)
		result = bigint.add(result, digit_result)
	end

	if larger.sign == smaller.sign then
		result.sign = "+"
	else
		result.sign = "-"
	end

	return result
end

function bigint.divide(lhs, rhs)
	
	if bigint.equal(lhs, rhs) then
		return bigint.new(1)
	elseif bigint.equal(rhs, bigint.new(1)) then 
		return bigint.clone(lhs)
	elseif bigint.less(lhs, rhs) then
		print(bigint.less(lhs, rhs))
		return bigint.new(0)
	else
		if bigint.equal(rhs, bigint.new(0)) then
			return nil -- xd
		end
		
		if lhs.signal ~= "+" or rhs.signal ~= "+" then
			return nil
		end

		local result = bigint.new()
		local dividend = bigint.new()
		
		-- every mathematician just simultaneously cried
		local negative_0 = bigint.new(0)
		negative_0.signal = "-"
		
		for index1 = 1, #lhs.digits do
			if #dividend.digits ~= 0 and bigint.equal(dividend, negative_0) then
				dividend = bigint.new()
			end
			
			table.insert(dividend.digits, lhs.digits[index1])

			local factor = bigint.new(0)
			while bigint.greater(dividend, rhs, true) do
				dividend = bigint.subtract(dividend, rhs)
				factor = bigint.add(factor, bigint.new(1))
			end
			
			for index2 = 0, #factor.digits - 1 do
				result.digits[#result.digits + 1 - index2] = factor.digits[index2 + 1]
			end
		end
		
		if lhs.signal == rhs.signal then
			result.signal = "+"
		else
			result.signal = "-"
		end
		
		return result, dividend
	end
end

function bigint.exponent(bn, power)
	if power.signal == "-" then
		return nil
	end
	
	local powerof = bigint.clone(power)
	
	if bigint.equal(powerof, bigint.new(0)) then
		return bigint.new(1)
	elseif bigint.equal(powerof, bigint.new(1)) then
		return bn
	else
		local result = bigint.clone(bn)
		print(powerof)
		
		while bigint.greater(powerof, bigint.new(1)) do
			print(powerof)
			print(bigint.new(1))
			result = bigint.multiply(result, bn)
			powerof = bigint.subtract(powerof, bigint.new(1))
		end
		
		print(result)
		
		return result
	end
end

function bigint.modulus(lhs, rhs)
	local _, remainder = bigint.divide(lhs, rhs)
	
	remainder.sign = lhs.sign
	return remainder
end

function bigint.greater(lhs, rhs, orequal)
	local greater = false
	local equal = false

	if lhs.signal == "-" and lhs.signal == "+" then
		greater = false
	elseif (#lhs.digits > #rhs.digits)
		or (lhs.signal == "+" and rhs.signal == "-")
	then
		greater = false
	elseif #lhs.digits == #rhs.digits then
		for index = 1, #lhs.digits do
			if lhs.digits[index] > rhs.digits[index] then
				greater = true
				break
			elseif rhs.digits[index] > lhs.digits[index] then
				break
			elseif index == #lhs.digits
				and lhs.digits[index] == rhs.digits[index]
			then
				equal = true
			end
		end
	end

	if not equal and lhs.signal == "-" and rhs.signal == "-" then
		greater = not greater
	end

	if orequal == true then
		return ((equal or greater) and true) or false
	else
		return ((greater and not equal) and true) or false
	end
end

function bigint.less(lhs, rhs, orequal)
	local greater = false
	local equal = false

	if lhs.signal == "-" and rhs.signal == "+" then
		greater = false
	elseif (#lhs.digits > #rhs.digits)
		or (lhs.signal == "+" and rhs.signal == "-")
	then
		greater = true
	elseif #lhs.digits == #rhs.digits then
		for index = 1, #lhs.digits do
			if lhs.digits[index] > rhs.digits[index] then
				greater = true
				break
			elseif rhs.digits[index] > lhs.digits[index] then
				break
			elseif index == #lhs.digits
				and lhs.digits[index] == rhs.digits[index]
			then
				equal = true
			end
		end
	end

	if not equal and lhs.signal == "-" and rhs.signal == "-" then
		greater = not greater
	end
	
	if orequal == true then
		return ((equal or not greater) and true) or false
	else
		return ((not greater and not equal) and true) or false
	end
end

function bigint.equal(lhs, rhs)
	local equal = false

	for index = 1, #lhs.digits do
		if lhs.digits[index] ~= rhs.digits[index] then
			equal = false
			break
		end

		equal = true
	end

	return equal
end

function bigint.notequal(lhs, rhs)
	local equal = false

	for index = 1, #lhs.digits do
		if lhs.digits[index] ~= rhs.digits[index] then
			equal = false
			break
		end

		equal = true
	end

	return not equal
end

function bigint.set(bn, num)
	if bn == nil then
		bn = bigint.new()
	end

	bn.digits = {}

	-- handle number into a table
	if num == nil then
		-- empty number
		table.insert(bn.digits, 0);
	elseif type(num) == "string" or type(num) == "number" then
		if type(num) == "number" then
			num = tostring(num)
		end


		if num == "0" then
			table.insert(bn.digits, 0)
			return bn
		end

		if string.sub(num, 1, 1) == "-" then
			bn.signal = "-"
			num = string.sub(num, 2)
		end

		for digit in string.gmatch(num, "[0-9]") do
			table.insert(bn.digits, tonumber(digit))
		end
	end

	return bn
end

return bigint