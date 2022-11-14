local AnimationService = {
	Importable = true;
}

-- Services
local TweenService = game:GetService("TweenService")

-- Constants
local KeyframeType = {
    Tween = 0;
    TweenAnotherObject = 1;
    Delay = 2;
}

--- Service Functions
function AnimationService:RunKeyframesOnObject(object, keyframes)
    for _, v in ipairs(keyframes) do
        if v.Type == KeyframeType.Tween then
            local tween = TweenService:Create(object, v.TweenInfo, v.Properties)

            tween:Play()
            if v.Wait then
                tween.Completed:Wait()
            end
        elseif v.Type == KeyframeType.TweenAnotherObject then
            local tween = TweenService:Create(v.Object, v.TweenInfo, v.Properties)

            tween:Play()
            if v.Wait then
                tween.Completed:Wait()
            end
        elseif v.Type == KeyframeType.Delay then
            task.wait(v.Time)
        end
    end
end

function AnimationService:RunKeyframesOnObjectAtOnce(object, keyframes)
    for _, v in ipairs(keyframes) do
        if v.Type == KeyframeType.Tween then
            local tween = TweenService:Create(object, v.TweenInfo, v.Properties)

            tween:Play()
            if v.Wait then
                tween.Completed:Wait()
            end
        elseif v.Type == KeyframeType.TweenAnotherObject then
            local tween = TweenService:Create(v.Object, v.TweenInfo, v.Properties)

            tween:Play()
            if v.Wait then
                tween.Completed:Wait()
            end
        elseif v.Type == KeyframeType.Delay then
            task.wait(v.Time)
        end
    end
end

function AnimationService:RunKeyframes(object, keyframes)
    for _, v in ipairs(keyframes) do
        if v.Type == KeyframeType.Tween then
            local tween = TweenService:Create(object, v.TweenInfo, v.Properties)

            tween:Play()
            if v.Wait then
                tween.Completed:Wait()
            end
        elseif v.Type == KeyframeType.TweenAnotherObject then
            local tween = TweenService:Create(v.Object, v.TweenInfo, v.Properties)

            tween:Play()
            if v.Wait then
                tween.Completed:Wait()
            end
        elseif v.Type == KeyframeType.Delay then
            task.wait(v.Time)
        end
    end
end
function AnimationService:RunKeyframesAtOnce(keyframes)
    for _, v in ipairs(keyframes) do
        if v.Type == KeyframeType.TweenAnotherObject then
            local tween = TweenService:Create(v.Object, v.TweenInfo, v.Properties)

            tween:Play()
        elseif v.Type == KeyframeType.Delay then
            task.wait(v.Time)
        end
    end
end

function AnimationService:CreateKeyframe(type, info, properties, waitFor)
    local keyframe = {
        Type = type;
        Properties = properties
    }

    if info == nil then
        keyframe.TweenInfo = TweenInfo.new(0.5)
    else
        keyframe.TweenInfo = info
    end

    if waitFor ~= nil then
        keyframe.Wait = waitFor
    else
        keyframe.Wait = true
    end

    print(keyframe)

    return keyframe
end

function AnimationService:CreateSelfKeyframe(info, properties, waitFor)
    return AnimationService:CreateKeyframe(KeyframeType.Tween, info, properties, waitFor)
end

function AnimationService:CreateObjectKeyframe(object, info, properties, waitFor)
    local keyframe = AnimationService:CreateKeyframe(KeyframeType.TweenAnotherObject, info, properties, waitFor)

    keyframe.Object = object

    return keyframe
end

function AnimationService:CreateDelayKeyframe(time)
    local keyframe = AnimationService:CreateKeyframe(KeyframeType.Delay, nil, nil)
    keyframe.Time = time

    return keyframe
end

return AnimationService
