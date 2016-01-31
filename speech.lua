Speech = {}
setmetatable(Speech, GameObject)
Speech.__index = Speech

function Speech.new(owner, text, duration)
    local s = GameObject.new()
    setmetatable(s, Speech)

    s.owner = owner
    s.text = text
    s.duration = duration

    s.font = love.graphics.getFont() -- CHANGE THIS IN FUTURE TO CUSTOM FONT
    s.text_width = s.font:getWidth(text)
    s.text_height = s.font:getHeight(text)
    s.vertical_offset = 2

    s.creation_time = love.timer.getTime()

    return s
end

function Speech:update(dt)
    self:follow_owner()

    if love.timer.getTime() - self.creation_time >= self.duration then
        self._dead = true
    end
end

function Speech:draw()
    love.graphics.printf(self.text, self.x, self.y, 1000, "left")
end

function Speech:follow_owner()
    self.x = self.owner.x - self.text_width/2
    self.y = self.owner.y - self.vertical_offset - self.text_height
end
