local Scheduler = {
    Importable = true;
    Tasks = {};
    TaskNumber = 0;
}

-- Services
local RunService = game:GetService("RunService")

function Scheduler:Schedule(scheduledTask, scheduleTo)
    if scheduleTo == nil then
        scheduleTo = RunService.Stepped
    end
    
    local taskNumber = Scheduler.TaskNumber

    Scheduler.Tasks[taskNumber] = {
        Ran = false;
        Connection = scheduleTo:Connect(function(time, deltaTime)
            if Scheduler.Tasks[taskNumber].Ran == true then
                return
            end

            Scheduler.Tasks[taskNumber].Ran = true

            -- Wait for scheduledTask to run
            local result = scheduledTask()

            -- If the result is false, don't stop running until it's done.
            if result == false then
                Scheduler.Tasks[taskNumber].Ran = false
                return
            end
    
            -- Disconnect once it's done
            Scheduler:Unschedule(taskNumber)
        end);
    }

    Scheduler.TaskNumber = taskNumber + 1

    return
end

function Scheduler:Unschedule(taskNumber)
    Scheduler.Tasks[taskNumber].Connection:Disconnect()
    Scheduler.Tasks[taskNumber] = nil
end

return Scheduler