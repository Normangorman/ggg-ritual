Villager = {}
setmetatable(Villager, Enemy)
Villager.__index = Villager

function Villager.new()
    local n = Enemy.new()
    setmetatable(n, Villager)

    n.x = 0
    n.y = 0
    n.vx = 0
    n.vy = 0
    n.hp_stat = 2
    n.damage_stat = 1
    n.speed_stat = 5
    n.ai_state = "idle"

    n.animations.idle = Animation.newFromFile("Animations/_NPCS/Villager/villager_up.lua")
    n.animations.chasing = Animation.newFromFile("Animations/_NPCS/Villager/villager_down.lua")
    n.animations.hitting = Animation.newFromFile("Animations/_NPCS/Villager/villager_attack.lua")
    n.animations.nearby = Animation.newFromFile("Animations/_NPCS/Villager/villager_down.lua")
    n.animations.hurt = Animation.newFromFile("Animations/_NPCS/Villager/villager_damage.lua")
    n.animations.dying = Animation.newFromFile("Animations/_NPCS/Villager/villager_dying.lua")
    n.current_animation = n.animations.idle

    n.sounds = {}
    n.sounds["walking"] = nil
    n.sounds["hitting"] = nil
    n.sounds["hurt"] = nil
    n.sounds["dying"] = nil

    n.sounds["walking"]:setLooping(true)

    n.frames_waiting = -1  -- used for waiting to perform actions

    return n
end

function Villager:get_pursuit_range()
    return 400
end

function Villager:get_nearby_range()
    return 25
end
