Enemy = {}
setmetatable(Enemy, GameObject)
Enemy.__index = Enemy

function Enemy.new()
    local e = GameObject.new()
    setmetatable(e, Enemy)

    e.x = 0
    e.y = 0
    e.vx = 0
    e.vy = 0
    e.hp_stat = 2
    e.damage_stat = 1
    e.speed_stat = 7
    e.ai_state = "idle"
    e.animation_idle = Animation.newFromFile("Animations/enemy/enemy_idle.lua")
    e.animation_chasing = Animation.newFromFile("Animations/enemy/enemy_chasing.lua")
    e.animation_hitting = Animation.newFromFile("Animations/enemy/enemy_hitting.lua")
    e.animation_nearby = Animation.newFromFile("Animations/enemy/enemy_nearby.lua")
    e.animation_hurt = Animation.newFromFile("Animations/enemy/enemy_hurt.lua")
    e.animation_dying = Animation.newFromFile("Animations/enemy/enemy_dying.lua")
    e.animation = e.animation_idle

    e.sounds = {}
    e.sounds["walking"] = love.audio.newSource("Assets/Sounds/enemy/walking.wav")
    e.sounds["hitting"] = love.audio.newSource("Assets/Sounds/enemy/hitting.wav")
    e.sounds["hurt"] = love.audio.newSource("Assets/Sounds/enemy/hurt.wav")
    e.sounds["dying"] = love.audio.newSource("Assets/Sounds/enemy/dying.wav")

    e.sounds["walking"]:setLooping(true)

    e.frames_waiting = -1  -- used for waiting to perform actions

    return e
end

function Enemy:update(dt)
    self.vx = 0
    self.vy = 0

    self:update_AI()

    if self.animation then
        self.animation:update(dt)
    end

    if self.frames_waiting > 0 then
        self.frames_waiting = self.frames_waiting - 1
    end
end

function Enemy:draw()
    if self.animation then
        self.animation:draw(self.x, self.y)
    else
        print("No sprite found for enemy! Drawing rectangle instead.")
        love.graphics.rectangle("fill", self.x, self.y, 10, 10)
    end
end

function Enemy:update_AI()

    -- Calculate distance to player
    dx = self.x - player.x
    dy = self.y - player.y
    dist_to_player = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))

    if self.ai_state == "idle" then
         -- check if player is within range
	 if dist_to_player <= self:get_pursuit_range() then
		 self:set_ai("chasing")
	 end
    elseif self.ai_state == "chasing" then
	 self:pursue_player()
	 if not self.sounds["walking"]:isPlaying() then
	     self.sounds["walking"]:play()
         end
	 -- check if nearby player, set state to 'nearby' if so
	 if dist_to_player <= self:get_nearby_range() then
		 self.sounds["walking"]:stop()
		 self:set_ai("nearby")
	 -- check if far from player, set state to 'idle' if so		 
	 elseif dist_to_player > self:get_pursuit_range() then
		 self.sounds["walking"]:stop()
		 self:set_ai("idle")
	 end
    elseif self.ai_state == "nearby" then
	 -- wait for certain number of frames, if this is achieved then attack
         if self.frames_waiting == 0 then
		 self:set_ai("hitting")
	 -- if player hits enemy now, will go to 'hurt' (ADD COLLISION DETECTION)
         elseif player.attacking then
		 self.hp_stat = self.hp_stat - 1
	 	 if self.hp_stat <= 0 then
		     self:set_ai("dying")
	         else
		     self:set_ai("hurt")
	         end
	 -- if player moves certain dist away from enemy, then becomes 'chasing'		 
         elseif dist_to_player > self:get_nearby_range() then
		 self:set_ai("chasing")
	 end
    elseif self.ai_state == "hitting" then
	 if not self.sounds["hitting"]:isPlaying() then
		 self.sounds["hitting"]:play()
	 end
	 -- if animation has finished
	 if not self.animation.playing then
		 self:set_ai("nearby")
	 end
         -- if player is colliding with enemy, will set them to hurt state
    elseif self.ai_state == "hurt" then
	 -- wait for hurt animation to finish, then restore ai stat
	 if not self.sounds["hurt"]:isPlaying() then
		 self.sounds["hurt"]:play()
	 end
	 if not self.animation.playing then
		 self:set_ai("idle")
	 end
    elseif self.ai_state == "dying" then
	 -- wait for dying animation to finish, then destroy self
	 if not self.sounds["dying"]:isPlaying() then
		 self.sounds["dying"]:play()
	 end
	 if not self.animation.playing then
		 self.dead = true
	 end
    end
end

function Enemy:set_ai(state)
    self.animation:reset()
    self.animation.playing = true
    prev_state = self.ai_state
    self.ai_state = state
    if state == "idle" then
         self.animation = self.animation_idle
    elseif state == "chasing" then
	 self.animation = self.animation_chasing
    elseif state == "nearby" then
	 self.frames_waiting = 30  -- wait for 30 frames to hit player
	 self.animation = self.animation_nearby
    elseif state == "hitting" then
	 self.animation = self.animation_hitting
    elseif state == "hurt" then
	 self.animation = self.animation_hurt
    elseif state == "dying" then
	 self.animation = self.animation_dying
    else
         self.ai_state = prev_state
	 print("Invalid state: from ", self.ai_state, " to ", state)
    end
end

function Enemy:get_pursuit_range()
    return 400
end

function Enemy:get_nearby_range()
    return 25
end

function Enemy:pursue_player()
    -- Calculate direction to move
    dx = player.x - self.x
    dy = player.y - self.y

    direction = math.atan2(dy, dx)
    speed = self.speed_stat * ENTITY_SPEED_MULTIPLIER

    self.vx = speed * math.cos(direction)
    self.vy = speed * math.sin(direction)
end
