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
    e.hp_stat = 40
    e.damage_stat = 1
    e.speed_stat = 7
    e.ai_state = "idle"
    e._enemy = true
    e._width = 64
    e._height = 64

    -- Should be set by child class
    e.animations = {}
    e.animations["idle"] = nil
    e.animations["chasing"] = nil
    e.animations["hitting"] = nil
    e.animations["nearby"] = nil
    e.animations["hurt"] = nil
    e.animations["dying"] = nil
    e.current_animation = e.animations["idle"]

    e.sounds = {}
    e.sounds["walking"] = nil
    e.sounds["hitting"] = nil
    e.sounds["hurt"] = nil
    e.sounds["dying"] = nil

    e.frames_waiting = -1  -- used for waiting to perform actions


    return e
end

function Enemy:update(dt)
    self.vx = 0
    self.vy = 0

    --self:update_AI()

    if self.current_animation then
        self.current_animation:update(dt)
    end


    if self.frames_waiting > 0 then
        self.frames_waiting = self.frames_waiting - 1
    end

    if self.dying and love.timer.getTime() - self.death_begin_time > 2.0 then
        print("Enemy set to dead")
        self._dead = true
    end

    if self.hp_stat <= 0 and not self.dying then
        print("Enemy begin death sequence")
        self.dying = true
        self.death_begin_time = love.timer.getTime()
        self.current_animation = self.animations.dying
        self.current_animation:play()
    end
end

function Enemy:draw()
    if self.current_animation then
        self.current_animation:draw(self.x, self.y)
    else
        if DEBUG then
            --print("No sprite found for enemy! Drawing rectangle instead.")
        end
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
		 succ_hit = false
		 dx = player.x - self.x
		 dy = player.y - self.y
		 angle = math.atan2(dy, dx)
	 	 if -math.pi/4 <= angle < math.pi/4 then
			 succ_hit = (player.direction == "left")
		 elseif math.pi/4 <= angle < 3*math.pi/4 then
			 succ_hit = (player.direction == "down")
		 elseif (3*math.pi/4 <= angle < math.pi) or (-math.pi <= angle < -3*math.pi/4) then
			 succ_hit = (player.direction == "right")
		 elseif -3*math.pi/4 <= angle < -math.pi/4 then
			 succ_hit = (player.direction == "up")
		 end
		 if succ_hit then
		     self.hp_stat = self.hp_stat - 1
	 	     if self.hp_stat <= 0 then
		         self:set_ai("dying")
	             else
		         self:set_ai("hurt")
		     end
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
	 if not self.current_animation.playing then
		 player.health = player.health - self.damage_stat
	 	 if player.health <= 0 then
		     player.dead = true
		 end
		 self:set_ai("nearby")
	 end
         -- if player is colliding with enemy, will set them to hurt state
    elseif self.ai_state == "hurt" then
	 -- wait for hurt animation to finish, then restore ai stat
	 if not self.sounds["hurt"]:isPlaying() then
		 self.sounds["hurt"]:play()
	 end
	 if not self.current_animation.playing then
		 self:set_ai("idle")
	 end
    elseif self.ai_state == "dying" then
	 -- wait for dying animation to finish, then destroy self
	 if not self.sounds["dying"]:isPlaying() then
		 self.sounds["dying"]:play()
	 end
	 if not self.current_animation.playing then
		 self._dead = true
	 end
    end
end

function Enemy:set_ai(state)
    self.current_animation:reset()
    self.current_animation.playing = true
    prev_state = self.ai_state
    self.ai_state = state
    if state == "idle" then
        self.current_animation = self.animations.idle
    elseif state == "chasing" then
        self.current_animation = self.animations.chasing
    elseif state == "nearby" then
	    self.frames_waiting = 30  -- wait for 30 frames to hit player
	    self.current_animation = self.animations.nearby
    elseif state == "hitting" then
        self.current_animation = self.animations.hitting
    elseif state == "hurt" then
        self.current_animation = self.animations.hurt
    elseif state == "dying" then
        self.current_animation = self.animations.dying
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

function Enemy:take_damage(strength_stat)
    self.hp_stat = self.hp_stat - strength_stat
    print("Enemy took "..strength_stat.." damage. Current HP: "..self.hp_stat)
end
