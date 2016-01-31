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
    p.width = 20
    p.height = 20

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

    p.sounds = {}
    p.sounds["walking"] = nil
    p.sounds["hitting"] = nil
    p.sounds["hurt"] = nil
    p.sounds["jumping"] = nil
    p.sounds["dying"] = nil

    return p
end

function Player:draw()
    self.current_animation:draw(self.x, self.y)
end

function Player:update(dt)
    self.current_animation:update(dt)
    self:update_AI()
end


function Player:update_AI()
    if self.ai_state == "idle" then
    elseif self.ai_state == "walking" then
    elseif self.ai_state == "hitting" then
    elseif self.ai_state == "hurt" then
    elseif self.ai_state == "jumping" then
    elseif self.ai_state == "dying" then
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
        self.current_animation = self.animations.left
    elseif direction == "right" then
        self.vx = self.speed_stat * c
        self.current_animation = self.animations.right
    elseif direction == "down" then
        self.vy = self.speed_stat * c
        self.current_animation = self.animations.down
    elseif direction == "up" then
        self.vy = -self.speed_stat * c
        self.current_animation = self.animations.up
    end
end

function Player:idle()
    self.vx = 0
    self.vy = 0
    self.current_animation:pause()
end

function Player:attack()
    self.attacking = true
end
