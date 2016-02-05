Player = {}
setmetatable(Player, GameObject)
Player.__index = Player

function Player.new()
    local p = GameObject.new()
    setmetatable(p, Player)

    p._collidable = true
    p._width = 32
    p._height = 32
    p.x = 150*32
    p.y = 20*32
    p.vx = 0
    p.vy = 0
    p.inventory = nil

    p.health = 10
    p.strength = 10
    p.speed_stat = 20

    p.attack_start_time = 0
    p.attacking = false
    p.attack_duration = 0.6
    p.hit_enemy = false

    p.animations = {}
    p.animations.down = Animation.newFromFile("Animations/_Player/player_down.lua")
    p.animations.up = Animation.newFromFile("Animations/_Player/player_up.lua")
    p.animations.left = Animation.newFromFile("Animations/_Player/player_left.lua")
    p.animations.right = Animation.newFromFile("Animations/_Player/player_right.lua")
    p.animations.attack = Animation.newFromFile("Animations/_Player/player_attack.lua")
    p.animations.dying = Animation.newFromFile("Animations/_Player/player_death.lua")
    p.current_animation = p.animations.down

    p.ai_state = "idle"   --can be idle, walking, hitting, hurt, jumping or dying
    p.direction = "down"  --can be up, down, left or right

    p.dead = false

    p.sounds = {}
    p.sounds["walking"] = nil
    p.sounds["hitting"] = love.audio.newSource("Assets/_Sounds/scythe/hitenemy1.wav", "static")
    p.sounds["hurt"] = nil
    p.sounds["jumping"] = nil
    p.sounds["dying"] = nil

    p.footstep_sound_index = 1
    p.last_footstep_sound_time = 0
    p.playing_footstep = false
    p.footstep_sounds = {
        love.audio.newSource("Assets/_Sounds/footsteps/generic/1.wav", "static"),
        love.audio.newSource("Assets/_Sounds/footsteps/generic/2.wav", "static"),
        love.audio.newSource("Assets/_Sounds/footsteps/generic/3.wav", "static"),
        love.audio.newSource("Assets/_Sounds/footsteps/generic/4.wav", "static"),
        love.audio.newSource("Assets/_Sounds/footsteps/generic/5.wav", "static"),
        love.audio.newSource("Assets/_Sounds/footsteps/generic/6.wav", "static")
    }

    return p
end

function Player:draw()
    self.current_animation:draw(self.x, self.y)
end

function Player:update(dt)
    self.current_animation:update(dt)

    if self.attacking then
        local time_since_attack = love.timer.getTime() - self.attack_start_time
        if time_since_attack >= self.attack_duration then
            self.attacking = false
            self.hit_enemy = false
        end
    end

    if not self.playing_footstep then
        if self.vx ~= 0 or self.vy ~= 0 then
            self.last_footstep_sound_time = love.timer.getTime()
            love.audio.play(self.footstep_sounds[(self.footstep_sound_index % 6) + 1])
            self.footstep_sound_index = self.footstep_sound_index + 1
        end
    else
        local dt = love.timer.getTime() - self.last_footstep_sound_time
        if dt > 0.25 then
            self.playing_footstep = false
        end
    end
end

function Player:set_ai(state)
    self.current_animation:reset()
    self.current_animation.playing = true
    prev_state = self.ai_state
    self.ai_state = state

    if state == "idle" or state == "walking" or state == "jumping" then
        if self.direction == "up" then
            self.current_animation = self.animations.up
        elseif self.direction == "down" then
            self.current_animation = self.animations.down
        elseif self.direction == "left" then
            self.current_animation = self.animations.left
        elseif self.direction == "right" then
            self.current_animation = self.animations.right
        end

        if state == "idle" then
            self.current_animation.playing = false
        elseif state == "hitting" then
            self.frames_waiting = 30  -- wait for 30 frames to hit player
            self.current_animation = self.animations.attack
        elseif state == "dying" then
            self.current_animation = self.animation_dying
        else
            self.ai_state = prev_state
            print("Invalid state: from ", self.ai_state, " to ", state)
        end
	end
end

function Player:move(direction)
    self.current_animation:play()
    c = ENTITY_SPEED_MULTIPLIER

    if direction == "left" then
        self.vx = -self.speed_stat * c

        if not self.attacking then
            self.current_animation = self.animations.left
        end
    elseif direction == "right" then
        self.vx = self.speed_stat * c

        if not self.attacking then
            self.current_animation = self.animations.right
        end
    elseif direction == "down" then
        self.vy = self.speed_stat * c

        if not self.attacking then
            self.current_animation = self.animations.down
        end
    elseif direction == "up" then
        self.vy = -self.speed_stat * c

        if not self.attacking then
            self.current_animation = self.animations.up
        end
    end
end

function Player:idle()
    self.vx = 0
    self.vy = 0

    if not self.attacking then
        self.current_animation:pause()
    end
end

function Player:attack()
    if self.attacking then
        return
    else
        if DEBUG then
            print("Player attacking!")
        end
        self.attack_start_time = love.timer.getTime()
        self.attacking = true
        self.current_animation = self.animations.attack
        self.current_animation:play()
        love.audio.play(self.sounds.hitting)
    end
end
