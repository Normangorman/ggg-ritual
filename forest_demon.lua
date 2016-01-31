ForestDemon = {}
setmetatable(ForestDemon, Enemy)
ForestDemon.__index = ForestDemon

function ForestDemon.new()
    local f = Enemy.new()
    setmetatable(f, ForestDemon)

    f.x = 0
    f.y = 0
    f.vx = 0
    f.vy = 0
    f.hp_stat = 2
    f.damage_stat = 1
    f.speed_stat = 5
    f.ai_state = "idle"

    f.animations.idle = Animation.newFromFile("Animations/_NPCS/Demon/demon_up.lua")
    f.animations.chasing = Animation.newFromFile("Animations/_NPCS/Demon/demon_down.lua")
    f.animations.hitting = Animation.newFromFile("Animations/_NPCS/Demon/demon_attack.lua")
    f.animations.nearby = Animation.newFromFile("Animations/_NPCS/Demon/demon_down.lua")
    f.animations.hurt = Animation.newFromFile("Animations/_NPCS/Demon/demon_damage.lua")
    f.animations.dying = Animation.newFromFile("Animations/_NPCS/Demon/demon_death.lua")
    f.current_animation = f.animations.idle

    f.sounds = {}
    f.sounds["walking"] = love.audio.newSource("Assets/_Sounds/enemy/forest_demon/walking.wav")
    f.sounds["hitting"] = love.audio.newSource("Assets/_Sounds/enemy/forest_demon/hitting.wav")
    f.sounds["hurt"] = love.audio.newSource("Assets/_Sounds/enemy/forest_demon/hurt.wav")
    f.sounds["dying"] = love.audio.newSource("Assets/_Sounds/enemy/forest_demon/dying.wav")

    f.sounds["walking"]:setLooping(true)

    f.frames_waiting = -1  -- used for waiting to perform actions

    return f
end

function ForestDemon:get_pursuit_range()
    return 400
end

function ForestDemon:get_nearby_range()
    return 25
end

