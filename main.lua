require "lib.lm.Animation.Animation"
local sti = require "lib.sti"

require "gameobject"
require "speech"
require "player"
require "elder"
require "sideBar"
require "enemy"
require "nymph"
require "mainMenu"
require "healthBar"
require "forest_demon"
require "water_demon"
require "rock_bat"
require "ghost"
require "SoundManager"
require "gamePlay"
require "villager"
require "forest_demon"

ENTITY_SPEED_MULTIPLIER = 12 -- multiplied by an entity's speed_stat to get it's real speed in pixels
SCREEN_WIDTH = 790
COLLIDABLE_TILE_ID = 0
DEBUG = true

onMenu = true
player = nil
elder = nil
sideBar = nil
mainMenu = {}
healthBar = {}

world = {}
world.objects = {}
world.map = nil
world.secondsElapsedInDay = 0
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
        {102,51}
    },
    { -- Villagers
        Nymph.new, -- CHANGE ME
        {138,21}, {166,21}, {171,34}, {129,33}, {167,42}
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

GUI = {}
GUI.objects = {}
soundManager = SoundManager.new()
gamePlay = GamePlay.new()

function world:add_game_object(g)
    -- Called when a new GameObject is created
    g._id = self.next_object_id
    self.next_object_id = self.next_object_id + 1
    table.insert(self.objects, g)
end

function world:remove_game_object(id)
    print("Removing game object with id: " .. id)
    for i=1, #world.objects do
        obj = world.objects[i]

        if obj._id == id then
            table.remove(world.objects, i)
            break
        end
    end
end

function world:load()
    onMenu = false

    player = Player.new()
    elder = Elder.new()
    sideBar = SideBar.new()

    --Delete later
    healthBar = HealthBar.new()
    mainMenu = MainMenu.new()

    world.map = sti.new("Assets/_Map/MAP.lua")
    world.camera_x = math.floor(player.x - love.graphics.getWidth() / 2)
    world.camera_y = math.floor(player.y - love.graphics.getHeight() / 2)

    table.insert(GUI.objects, sideBar)
    table.insert(GUI.objects, healthBar)

    world:add_game_object(player)
    world:add_game_object(elder)

    for i=1, #world.spawns do
        local spawn_table = world.spawns[i]
        local new_unit_func = spawn_table[1]

        for j=2, #spawn_table do
            local coords = spawn_table[j]
            local x,y = coords[1], coords[2]

            local unit = new_unit_func()
            unit.x = (x-1)*32
            unit.y = (y-1)*32
            world:add_game_object(unit)

            if DEBUG then
                print("Spawned a unit at "..unit.x..","..unit.y)
            end
        end
    end

    elder:speak("Hello there!", 2)
end

function love.load()
    onMenu = true
    mainMenu = MainMenu.new()
end

function love.quit()
    return false
end

function love.update(dt)
    if onMenu then
        mainMenu:update(dt)
        return
    end

    world.map:update(dt)
    world.secondsElapsedInDay = world.secondsElapsedInDay + dt

    world.camera_x = math.floor(player.x - love.graphics.getWidth() / 2)
    world.camera_y = math.floor(player.y - love.graphics.getHeight() / 2)

    -- Update world.player_current_zone
    for zone_name, points in pairs(world.zones) do
        local top_l = points[1]
        local bottom_r = points[2]

        local tx, ty = get_unit_tile(player)

        --[[
        if DEBUG then
            print("Player current tile: "..tx..","..ty)
            print("Player current zone: "..world.player_current_zone)
        end
        ]]

        if isCoordInRect(tx,ty, top_l[1], top_l[2], bottom_r[1] - top_l[1], bottom_r[2] - top_l[2]) then
            world.player_current_zone = zone_name
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

    if love.keyboard.isDown("d") then
        gamePlay:death()
    end

    if idle == true then
        player:idle()
    end

    for i=1, #world.objects do
        local obj = world.objects[i]

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

        if obj._dead then
            world:remove_game_object(obj._id)
        end
    end
end

function love.draw(dt)
    if onMenu then
        mainMenu:draw(dt)
        return;
    end

    -- Translate the camera to be centered on the player
    love.graphics.translate(-world.camera_x, -world.camera_y)

    world.map:setDrawRange(world.camera_x, world.camera_y, love.graphics.getWidth(), love.graphics.getHeight())
    world.map:draw()
    local mx, my = love.mouse.getPosition()
    local rx, ry = mx + world.camera_x, my + world.camera_y
    local tx, ty = world.map:convertScreenToTile(rx, ry)
    tx = math.floor(tx) + 1
    ty = math.floor(ty) + 1

    if DEBUG then
        love.graphics.print("Mouse (x,y): ("..mx..","..my..")", world.camera_x + 300, world.camera_y + 40)
        love.graphics.print("Game world (x,y): ("..rx..","..ry..")", world.camera_x + 300, world.camera_y + 50)
        love.graphics.print("Tile (x,y): ("..tx..","..ty..")", world.camera_x + 300, world.camera_y + 60)
        love.graphics.print("Tile Is Collidable? ("..tostring(is_tile_collidable(tx,ty)), world.camera_x + 300, world.camera_y + 70)
        love.graphics.print("Mouse Collides? "..tostring(does_point_collide(rx,ry)), world.camera_x + 300, world.camera_y + 80)
    end

    for i=1, #world.objects do
        local obj = world.objects[i]
        obj:draw()

        if DEBUG and obj._collidable then -- draw it's bounding box for debugging
            local r,g,b,a = love.graphics.getColor()
            love.graphics.setColor(255,255,255,122)
            love.graphics.rectangle("fill", obj.x, obj.y, obj._width, obj._height)
            love.graphics.setColor(r,g,b,a)
        end
    end

    for i=1, #GUI.objects do
        GUI.objects[i]:draw()
    end
end

function love.keypressed(key, scancode, isrepeat)
    if not onMenu then
        if key == "space" then
            player:attack()
        end
    end
end

function love.mousepressed(x, y, button, istouch)
    if onMenu then
        mainMenu:mousepressed(x, y, button, istouch)
    end
end

function love.mousereleased(x, y, button, istouch)
    if onMenu then
        mainMenu:mousereleased(x, y, button, istouch)
    end
end

function is_tile_collidable(tx,ty)
    local layer = world.map.layers["collisions"]
    if layer then
        --print("Found collision layer")
        local row = layer.data[ty]
        if row then
            --print("Found row")
            local tile = row[tx]
            if tile then
                --print("Found tile. id="..tile.id)
                if tile.id == COLLIDABLE_TILE_ID then -- collision occured
                    return true
                end
            end
        end
    end

    return false
end

function does_point_collide(x, y)
    local tx, ty = world.map:convertScreenToTile(x, y)
    tx = math.floor(tx) + 1
    ty = math.floor(ty) + 1

    return is_tile_collidable(tx,ty)
end

function has_valid_position(obj)
    local w = obj._width
    local h = obj._height

    local x, y = obj.x, obj.y

    if does_point_collide(obj.x, obj.y) then
        print("Top left point collides!")
        return false
    elseif does_point_collide(obj.x + w, obj.y) then
        print("Top right point collides!")
        return false
    elseif does_point_collide(obj.x, obj.y + h) then
        print("Bottom left point collides!")
        return false
    elseif does_point_collide(obj.x + w, obj.y + h) then
        print("Bottom right point collides!")
        return false
    end

    return true
end

function get_unit_tile(unit)
    local tx, ty = world.map:convertScreenToTile(unit.x, unit.y)
    return math.ceil(tx), math.ceil(ty)
end
