require "lib.lm.Animation.Animation"

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
require "villager"
require "timer"
require "common"
require "world"

ENTITY_SPEED_MULTIPLIER = 12 -- multiplied by an entity's speed_stat to get it's real speed in pixels
SCREEN_WIDTH = 790
COLLIDABLE_TILE_ID = 0
if arg[2] == "debug" then
    DEBUG = true
else
    DEBUG = false
end

onMenu = true
player = nil
elder = nil
sideBar = nil
mainMenu = {}
healthBar = {}

world = World.new()

GUI = {}
GUI.objects = {}
soundManager = SoundManager.new()
gamePlay = GamePlay.new()

function love.load()
    if DEBUG then
        world:load()
    else
        onMenu = true
        mainMenu = MainMenu.new()
    end
end

function love.quit()
    return false
end

function love.update(dt)
    Timer.updateAll(dt)
    if onMenu then
        mainMenu:update(dt)
        return
    end

    world:update(dt)
end

function love.draw(dt)
    if onMenu then
        mainMenu:draw(dt)
        return;
    elseif gamePlay.lose then
	Font = love.graphics.newFont(40)
	love.graphics.setColor(255, 0, 0, 122)
	love.graphics.setFont(Font)
	love.graphics.print("Game Over", 250, 200)
	return
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

        if DEBUG and (obj._collidable or obj._enemy) then -- draw it's bounding box for debugging
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
        --print("Top left point collides!")
        return false
    elseif does_point_collide(obj.x + w, obj.y) then
        --print("Top right point collides!")
        return false
    elseif does_point_collide(obj.x, obj.y + h) then
        --print("Bottom left point collides!")
        return false
    elseif does_point_collide(obj.x + w, obj.y + h) then
        --print("Bottom right point collides!")
        return false
    end

    return true
end

function get_unit_tile(unit)
    local tx, ty = world.map:convertScreenToTile(unit.x, unit.y)
    return math.ceil(tx), math.ceil(ty)
end
