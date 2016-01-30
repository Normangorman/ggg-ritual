require "lib.lm.Animation.Animation"

require "gameobject"
require "player"
require "elder"
require "enemy"
require "nymph"

ENTITY_SPEED_MULTIPLIER = 20 -- multiplied by an entity's speed_stat to get it's real speed in pixels

player = nil
elder = nil
world = {}
world.objects = {}
world.next_object_id = 0

function world:add_game_object(g) 
    -- Called when a new GameObject is created
    g._id = self.next_object_id
    self.next_object_id = self.next_object_id + 1
    table.insert(self.objects, g)
end

function world:remove_game_object(id)
    for i=1, i<= #world.objects do
        obj = world.objects[i]
        if obj._id == id then
            table.remove(world.objects, i)
            break
        end
    end
end

function love.load()
    player = Player.new()
    elder = Elder.new()

    world:add_game_object(player)
    world:add_game_object(elder)

    local nymph = Nymph.new()
    nymph.x = 300
    nymph.y = 300
    world:add_game_object(nymph)
end

function love.update(dt)
    local idle = true
    if love.keyboard.isDown("left") then
        player:move("left")
        idle = false
    elseif love.keyboard.isDown("right") then
        player:move("right")
        idle = false
    end

    if love.keyboard.isDown("up") then
        player:move("up")
        idle = false
    elseif love.keyboard.isDown("down") then
        player:move("down")
        idle = false
    end

    if idle == true then
        player:idle()
    end

    for i=1, #world.objects do
        world.objects[i]:update(dt)
    end
end

function love.draw(dt)
    for i=1, #world.objects do
        world.objects[i]:draw()
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "space" then
        player:attack()
    end
end
