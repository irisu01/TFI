local InstanceBuilder = {
	Importable = true;
}

local enabled = true

function InstanceBuilder.OnImport()
	if enabled == false then
		return
	end
	
	getfenv(3).Instance = {
		new = InstanceBuilder.new;
		New = InstanceBuilder.new;
	}
end

function InstanceBuilder.new(s)

	local inst = Instance.new(s)

	local self

	self = setmetatable({}, {
		__index = function(t, k)
			return function(v)
				local success = pcall(function()
					_ = inst[k]
				end)
				if (success) then
					inst[k] = v
				end
				return self
			end
		end,
	})
	
	function self.Subinstance(callback)
		local subinst = callback()
		
		if subinst.Build ~= nil then
			subinst = subinst.Build()
		end
		
		subinst.Parent = inst
		
		return self
	end

	function self.Build()
		return inst
	end

	return self
end

return InstanceBuilder