keyRepeatEvent = {
    timeInit = 0.5,
    timeRepeat = 0.1,
    timer = 0,
    repeating = false
}

function keyRepeatEvent:new(func)
    obj = {
        func = func
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function keyRepeatEvent:run(state, dt, args)
    local returnVal = nil
    io.write(tostring(self.repeating))
    self.timer = math.max(self.timer - dt, 0)
    if state then
        if self.timer == 0 then
            returnVal = self.func(args)
            if self.repeating then
                self.timer = self.timeRepeat
            else
                self.timer = self.timeInit
                self.repeating = true
            end
        end
    else
        self.timer = 0
        self.repeating = false
    end
    
    return returnVal
end

