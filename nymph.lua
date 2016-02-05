Nymph = {}
setmetatable(Nymph, Enemy)
Nymph.__index = Nymph

function Nymph.new()
    local n = Enemy.new()
    setmetatable(n, Nymph)

    n.x = 0
    n.y = 0
    n.vx = 0
    n.vy = 0
    n.hp_stat = 40
    n.damage_stat = 1
    n.speed_stat = 5
    n.ai_state = "idle"

    n.animations.idle = Animation.newFromFile("Animations/_NPCS/Nymph/nymph_up.lua")
    n.animations.chasing = Animation.newFromFile("Animations/_NPCS/Nymph/nymph_down.lua")
    n.animations.hitting = Animation.newFromFile("Animations/_NPCS/Nymph/nymph_attack.lua")
    n.animations.nearby = Animation.newFromFile("Animations/_NPCS/Nymph/nymph_down.lua")
    n.animations.hurt = Animation.newFromFile("Animations/_NPCS/Nymph/nymph_damage.lua")
    n.animations.dying = Animation.newFromFile("Animations/_NPCS/Nymph/nymph_dying.lua")
    n.current_animation = n.animations.idle

    n.sounds = {}
    n.sounds["walking"] = love.audio.newSource("Assets/_Sounds/enemy/forest_demon/walking.wav")
    n.sounds["hitting"] = love.audio.newSource("Assets/_Sounds/enemy/forest_demon/hitting.wav")
    n.sounds["hurt"] = love.audio.newSource("Assets/_Sounds/enemy/forest_demon/hurt.wav")
    n.sounds["dying"] = love.audio.newSource("Assets/_Sounds/enemy/forest_demon/dying.wav")

    n.sounds["walking"]:setLooping(true)

    n.frames_waiting = -1  -- used for waiting to perform actions

    return n
end

function Nymph:get_pursuit_range()
    return 400
end

function Nymph:get_nearby_range()
    return 25
end
