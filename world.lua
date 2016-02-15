World = {}
World.__index = World

local sti = require "lib.sti"


function World.new()
    local world = {}
    setmetatable(world, World)

    world.objects = {}
    world.map = nil
    world.player_current_zone = "Village" -- Could be "Mine", "Lake", "Forest"
    world.next_object_id = 0
    world.zones = {
        Forest={{15,7}, {122,74}},
        Mine={{131,69}, {236,175}},
        Lake={{176,1}, {259,72}},
        Village={{123,14}, {176,68}}
    }

    world.spawns = {
        {
            Nymph.new,
            {55,44}, {75,51}, {55, 52}
        },
        {
            ForestDemon.new,
            {151,18}
        },
        {
            ForestDemon.new,
            {102,51}
        },
        {
            Villager.new, -- CHANGE ME
            {138,21}, {166,21}, {171,34}, {129,33}, {167,42}, {163, 25}, {147,30}, {159,26}
        },
        { -- Witch
            Nymph.new, -- CHANGE ME
            {167,144}
        },
        { -- Water boss
            Nymph.new, -- CHANGE ME
            {216,51}
        }
    }

    return world
end

function World:add_game_object(g)
    -- Called when a new GameObject is created
    g._id = self.next_object_id
    self.next_object_id = self.next_object_id + 1
    table.insert(self.objects, g)
    if g.load ~= nil then
        g:load()
    end
end

function World:remove_game_object(id)
    print("Removing game object with id: " .. id)
    for i=1, #self.objects do
        obj = self.objects[i]

        if obj._id == id then
            table.remove(self.objects, i)
            break
        end
    end
end

function World:load()
    onMenu = false

    player = Player.new()
    elder = Elder.new()

    --Delete later
    healthBar = HealthBar.new()

    self.map = sti.new("Assets/_Map/MAP.lua")
    self.camera_x = math.floor(player.x - love.graphics.getWidth() / 2)
    self.camera_y = math.floor(player.y - love.graphics.getHeight() / 2)

    table.insert(GUI.objects, sideBar)
    table.insert(GUI.objects, healthBar)

    self:add_game_object(player)
    self:add_game_object(elder)

    for i=1, #self.spawns do
        local spawn_table = self.spawns[i]
        local new_unit_func = spawn_table[1]

        for j=2, #spawn_table do
            local coords = spawn_table[j]
            local x,y = coords[1], coords[2]

            local unit = new_unit_func()
            unit.x = (x-1)*32
            unit.y = (y-1)*32
            self:add_game_object(unit)

            if DEBUG then
                print("Spawned a unit at "..unit.x..","..unit.y)
            end
        end
    end

    elder:speak("Hello there!", 2)
end

function World:draw(dt)
    -- Translate the camera to be centered on the player
    love.graphics.translate(-self.camera_x, -self.camera_y)

    self.map:setDrawRange(self.camera_x, self.camera_y, love.graphics.getWidth(), love.graphics.getHeight())
    self.map:draw()
    local mx, my = love.mouse.getPosition()
    local rx, ry = mx + self.camera_x, my + self.camera_y
    local tx, ty = self.map:convertScreenToTile(rx, ry)
    tx = math.floor(tx) + 1
    ty = math.floor(ty) + 1

    if DEBUG then
        love.graphics.print("Mouse (x,y): ("..mx..","..my..")", self.camera_x + 300, self.camera_y + 40)
        love.graphics.print("Game world (x,y): ("..rx..","..ry..")", self.camera_x + 300, self.camera_y + 50)
        love.graphics.print("Tile (x,y): ("..tx..","..ty..")", self.camera_x + 300, self.camera_y + 60)
        love.graphics.print("Tile Is Collidable? ("..tostring(is_tile_collidable(tx,ty)), self.camera_x + 300, self.camera_y + 70)
        love.graphics.print("Mouse Collides? "..tostring(does_point_collide(rx,ry)), self.camera_x + 300, self.camera_y + 80)
    end

    for i=1, #self.objects do
        local obj = self.objects[i]
        obj:draw()

        if DEBUG and (obj._collidable or obj._enemy) then -- draw it's bounding box for debugging
            local r,g,b,a = love.graphics.getColor()
            love.graphics.setColor(255,255,255,122)
            love.graphics.rectangle("fill", obj.x, obj.y, obj._width, obj._height)
            love.graphics.setColor(r,g,b,a)
        end
    end

    love.graphics.origin()

    for i=1, #GUI.objects do
        GUI.objects[i]:draw()
    end
end

function World:keypressed(key, scancode, isrepeat)
    if key == "space" then
        player:attack()
    end
end

function World:update(dt)
    if gamePlay.lose then
	    return
    end

    self.map:update(dt)

    self.camera_x = math.floor(player.x - love.graphics.getWidth() / 2)
    self.camera_y = math.floor(player.y - love.graphics.getHeight() / 2)

    -- Update self.player_current_zone
    for zone_name, points in pairs(self.zones) do
        local top_l = points[1]
        local bottom_r = points[2]

        local tx, ty = get_unit_tile(player)

        --[[
        if DEBUG then
            print("Player current tile: "..tx..","..ty)
            print("Player current zone: "..self.player_current_zone)
        end
        ]]

        if isCoordInRect(tx,ty, top_l[1], top_l[2], bottom_r[1] - top_l[1], bottom_r[2] - top_l[2]) then
            self.player_current_zone = zone_name
            break
        end
    end

    soundManager:update(dt)
    gamePlay:update(dt)

    local idle = true
    if love.keyboard.isDown("left") then
        player:move("left")
        idle = false
    elseif love.keyboard.isDown("right") then
        player:move("right")
        idle = false
    else
        player.vx = 0
    end

    if love.keyboard.isDown("up") then
        player:move("up")
        idle = false
    elseif love.keyboard.isDown("down") then
        player:move("down")
        idle = false
    else
        player.vy = 0
    end

    if love.keyboard.isDown(" ") then
        player:attack()
    end

    if idle == true then
        player:idle()
    end

    if player.health <= 0 then
	    gamePlay:death()
    end

    for i=1, #self.objects do
        local obj = self.objects[i]

        obj:update(dt)
        if obj._collidable then
            -- Attempt horizontal movement first
            local last_good_x = obj.x
            obj.x = obj.x + obj.vx * dt
            if not has_valid_position(obj) then
                obj.x = last_good_x
                obj.vx = 0
            end

            -- Then vertical movement
            local last_good_y = obj.y
            obj.y = obj.y + obj.vy * dt
            if not has_valid_position(obj) then
                obj.y = last_good_y
                obj.vy = 0
            end
        else
            -- Don't worry about collisions, just move it move it
            obj.x = obj.x + obj.vx * dt
            obj.y = obj.y + obj.vy * dt
        end
    end

    -- Collide player with enemies
    for i=1, #self.objects do
        local obj = self.objects[i]

        if obj._enemy then
            -- Attempt to collide with player
            local px, py, pw, ph = player.x, player.y, player._width, player._height
            local ex, ey, ew, eh = obj.x, obj.y, obj._width, obj._height

            -- Check if any of the points in the enemy's bounding box lie within the players
            local enemy_points = {
                {ex,ey}, {ex+ew, ey},
                {ex, ey+eh}, {ex+ew, ey+eh}
            }

            local collision = false
            for i=1, #enemy_points do
                local point = enemy_points[i]
                local x, y = point[1], point[2]

                if isCoordInRect(x,y, px,py,pw,ph) then
                    collision = true
                    break
                end
            end

            if collision then
                --print("Collision with enemy!")
                if player.attacking and not player.hit_enemy then
                    player.hit_enemy = true
                    obj:take_damage(player.strength)
                end
            end
        end
    end

    -- Remove dead objects
    for i=#self.objects, 1, -1 do
        local obj = self.objects[i]
        if obj._dead then
            self:remove_game_object(obj._id)
        end
    end
end
