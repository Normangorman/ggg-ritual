HUD = {}
HUD.__index = HUD

local sun_time = 10*60
local sun_periods = 9;
local sun_period_time = sun_time / sun_periods
local sunPadding = 5
local sunPositionSize = 150
local panelWidth = sunPositionSize
local screenHeight = 63
local tasksPaddingTop = 50
local tasksPaddingLeft = 18
local tasksPaddingRight = 24
local tasksTextWidth = panelWidth - tasksPaddingRight - tasksPaddingLeft
local tasksSpacing = 15

function HUD.new()
    local hud = {}
    setmetatable(hud, HUD)
    --hud.sun_animation = Animation.newFromFile("Animations/sun.lua")
    hud.sunBackgroundPanel = love.graphics.newImage("Assets/woodpanel150.png")
    hud.scroll = love.graphics.newImage("Assets/scroll.png")
    hud.tasks = {}
    --hud:update_time(0)
    return hud
end

function HUD:draw()
    --hud.sun_animation.currentFrameIndex = self.sun_animations[math.floor(world.secondsElapsedInDay / sun_period_time)]
    love.graphics.draw(self.sunBackgroundPanel, 0, 0)
    love.graphics.draw(self.scroll, 0, sunPositionSize)
    currentDrawPosition = sunPositionSize + tasksPaddingTop
    local font = love.graphics.newFont(10)
    local prevR, prevG, prevB, prevA = love.graphics.getColor()
    love.graphics.setColor(0, 0, 0) --Black
    for i=1,#self.tasks do
        love.graphics.printf(self.tasks[i], tasksPaddingLeft,
            currentDrawPosition,
            tasksTextWidth)
        local _, lines = font:getWrap(self.tasks[i], tasksTextWidth)
        currentDrawPosition = currentDrawPosition + tasksSpacing +
            lines * font:getHeight()
    end
    love.graphics.setColor(prevR, prevG, prevB, prevA)
    --self.sun_animation:draw(sunPadding, sunPadding)
end

function HUD:addNewTask(taskText)
    table.insert(self.tasks, taskText)
end
