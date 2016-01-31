Elder = {}
setmetatable(Elder, GameObject)
Elder.__index = Elder

function Elder.new()
    local e = GameObject.new()
    setmetatable(e, Elder)

    e.x = 150*32
    e.y = 18*32
    e.sprite1 = love.graphics.newImage("Assets/_NPCS/Elder/elder1.png")
    e.sprite2 = love.graphics.newImage("Assets/_NPCS/Elder/elder2.png")
    e.sprite3 = love.graphics.newImage("Assets/_NPCS/Elder/elder3.png")

    e.current_sprite = e.sprite1
    e.speech = nil
    e.evilness = 1

    return e
end

function Elder:update(dt)
    if self.evilness == 1 then
        self.current_sprite = self.sprite1
    elseif self.evilness == 2 then
        self.current_sprite = self.sprite2
    elseif self.evilness == 3 then
        self.current_sprite = self.sprite3
    end

    if self.speech and self.speech._dead then
        self.speech = nil
    end
end

function Elder:draw()
    love.graphics.draw(self.current_sprite, self.x, self.y)
end

function Elder:speak(text, duration)
    self.speech = Speech.new(self, text, duration)
    world:add_game_object(self.speech)
end
