local AnimationUtils = {
    Importable = true;
}

function AnimationUtils:CreateTweenHandler(tweens)
	if tweens == nil then
		tweens = {}
	end
	
	local tweenHandler = {
		Tweens = {};
		
		Add = function(self, name, tween)
			self.Tweens[name] = tween
			return self;
		end;
		
		Play = function(self, name, await)
			local success, tween = pcall(function()
				if self.Tweens[name] == nil then
					return nil
				else
					return self.Tweens[name]
				end
			end)
			
			if success then
				tween:Play()
				if await == true then
					tween.Completed:Wait()
				end
				
				return tween
			else
				return nil
			end
		end;
		
		PlayAll = function(self, waitAfter)
			if waitAfter == nil then
				waitAfter = {}
			end
			
			for key, tween in pairs(self.Tweens) do
				tween:Play()
				if table.find(waitAfter, key) then
					tween.Completed:Wait()
				end
			end
		end;
		
		WaitFor = function(self, name)
			for key, tween in pairs(tweens) do
				local success, tween = pcall(function()
					if self.Tweens[name] == nil then
						return nil
					else
						return self.Tweens[name]
					end
				end)

				if success then
                    if tween.PlaybackState == Enum.PlaybackState.Playing then
                        tween.Completed:Wait()
                    end

					return tween
				else
					return nil
				end
			end
		end,

		WaitForAll = function(self)
			for _, tween in pairs(self.Tweens) do
				if tween.PlaybackState == Enum.PlaybackState.Playing then
                    tween.Completed:Wait()
                end

                return tween
			end
		end,
	}
	
	return tweenHandler
end

return AnimationUtils;