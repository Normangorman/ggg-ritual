Ghost = {}
setmetatable(Ghost, Enemy)
Ghost.__index = Ghost

function Ghost.new()
    local g = Enemy.new()
    setmetatable(g, Ghost)

    g.x = 0
    g.y = 0
    g.vx = 0
    g.vy = 0
    g.hp_stat = 3
    g.damage_stat = 2
    g.speed_stat = 8
    g.ai_state = "idle"

    -- FIX THIS TO ACTUAL ANIMATIONS
    g.animations.idle = Animation.newFromFile("Animations/_NPCS/Nymph/nymph_up.lua")
    g.animations.chasing = Animation.newFromFile("Animations/_NPCS/Nymph/nymph_down.lua")
    g.animations.hitting = Animation.newFromFile("Animations/_NPCS/Nymph/nymph_attack.lua")
    g.animations.nearby = Animation.newFromFile("Animations/_NPCS/Nymph/nymph_down.lua")
    g.animations.hurt = Animation.newFromFile("Animations/_NPCS/Nymph/nymph_damage.lua")
    g.animations.dying = Animation.newFromFile("Animations/_NPCS/Nymph/nymph_dying.lua")
    g.current_animation = g.animations.idle

    g.sounds = {}
    g.sounds["walking"] = love.audio.newSource("Assets/_Sounds/enemy/ghost/walking.wav")
    g.sounds["hitting"] = love.audio.newSource("Assets/_Sounds/enemy/ghost/hitting.wav")
    g.sounds["hurt"] = love.audio.newSource("Assets/_Sounds/enemy/ghost/hurt.wav")
    g.sounds["dying"] = love.audio.newSource("Assets/_Sounds/enemy/ghost/dying.wav")

    g.sounds["walking"]:setLooping(true)

    g.frames_waiting = -1  -- used for waiting to perform actions

    return g
end

function Ghost:get_pursuit_range()
    return 400
end

function Ghost:get_nearby_range()
    return 25
end

