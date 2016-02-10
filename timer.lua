Timer = {}
Timer.__index = Timer

Timer.timers = {}

function Timer.new(time, func)
    local timer = {}
    setmetatable(timer, Timer)

    timer.timerStart = true
    timer.timeLeft = time
    timer.timerAction = func

    table.insert(Timer.timers, timer)

    return timer
end

function Timer.updateAll(dt)
    for i=1,#Timer.timers do
        Timer.timers[i]:update(dt)
    end
end

function Timer:update(dt)
    if self.timerStart then
        self.timeLeft = self.timeLeft - dt
        if self.timeLeft < 0 then
            self.timerStart = false
            self.timerAction()
        end
    end
end
