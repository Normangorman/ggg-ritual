RockBat = {}
setmetatable(RockBat, Enemy)
RockBat.__index = RockBat

function RockBat.new()
    local f = Enemy.new()
    setmetatable(f, RockBat)

    f.x = 0
    f.y = 0
    f.vx = 0
    f.vy = 0
    f.hp_stat = 4
    f.damage_stat = 2
    f.speed_stat = 4
    f.ai_state = "idle"
    f.animations.idle = Animation.newFromFile("Animations/_NPCS/Nymph/nymph_up.lua")
    f.animations.chasing = Animation.newFromFile("Animations/_NPCS/Nymph/nymph_down.lua")
    f.animations.hitting = Animation.newFromFile("Animations/_NPCS/Nymph/nymph_attack.lua")
    f.animations.nearby = Animation.newFromFile("Animations/_NPCS/Nymph/nymph_down.lua")
    f.animations.hurt = Animation.newFromFile("Animations/_NPCS/Nymph/nymph_damage.lua")
    f.animations.dying = Animation.newFromFile("Animations/_NPCS/Nymph/nymph_dying.lua")
    f.current_animation = f.animations.idle

    f.sounds = {}
    f.sounds["walking"] = love.audio.newSource("Assets/_Sounds/enemy/rock_bat/walking.wav")
    f.sounds["hitting"] = love.audio.newSource("Assets/_Sounds/enemy/rock_bat/hitting.wav")
    f.sounds["hurt"] = love.audio.newSource("Assets/_Sounds/enemy/rock_bat/hurt.wav")
    f.sounds["dying"] = love.audio.newSource("Assets/_Sounds/enemy/rock_bat/dying.wav")

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

