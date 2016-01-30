require "lib.lovemachine.Animation.Animation"

require "player"
require "elder"

player = nil
elder = nil
world = {}
world.objects = {}

function love.load()
    player = Player.new()
    elder = Elder.new()

    table.insert(world.objects, player)
    table.insert(world.objects, elder)
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
end
