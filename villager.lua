Villager = {}
setmetatable(Villager, GameObject)
Villager.__index = Villager

function Villager.new()
    local n = GameObject.new()
    setmetatable(n, Villager)

    n.x = 0
    n.y = 0
    n.vx = 0
    n.vy = 0
    n.ai_state = "idle"

    n.animations.idle = Animation.newFromFile("Animations/_NPCS/Villager/villager_down.lua")
    n.current_animation = n.animations.idle
    n.current_animation.play()

    return n
end

function Villager:update(dt)
    self.current_animation:update(dt)
end

function Villager:draw()
    self.current_animation:draw(self.x, self.y)
end
