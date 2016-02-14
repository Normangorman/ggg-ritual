SideBar = {}
SideBar.__index = SideBar

local sun_periods = 9;
local sunPadding = 0
local sunPositionSize = 150
local panelWidth = sunPositionSize
local screenHeight = 63
local tasksPaddingTop = 50
local tasksPaddingLeft = 18
local tasksPaddingRight = 24
local tasksTextWidth = panelWidth - tasksPaddingRight - tasksPaddingLeft
local tasksSpacing = 15

function SideBar.new()
    local sideBar = {}
    setmetatable(sideBar, SideBar)
    Timer.new(1, function() print("Hi") end)
    sideBar.sun_animation = Animation.newFromFile("Animations/_UI/clock_turn.lua")
    sideBar.sunBackgroundPanel = love.graphics.newImage("Assets/_UI/woodpanel150.png")
    sideBar.scroll = love.graphics.newImage("Assets/_UI/scroll.png")

    sideBar.sun_period_time = gamePlay.secondsInDay / sun_periods
    return sideBar
end

function SideBar:draw()
    self.sun_animation.currentFrameIndex = math.floor(gamePlay.secondsElapsedInDay * sun_periods / gamePlay.secondsInDay) + 1
    self.sun_animation:_setCurrentFrameQuad()
    --Have to do these two things to update the animation

    love.graphics.draw(self.sunBackgroundPanel, 0,  0)
    love.graphics.draw(self.scroll, 0, sunPositionSize)

    currentDrawPosition = sunPositionSize + tasksPaddingTop
    local font = love.graphics.newFont(10)
    local prevR, prevG, prevB, prevA = love.graphics.getColor()
    love.graphics.setColor(0, 0, 0) --Black
    for i=1,gamePlay:getNumberOfTasks() do
        love.graphics.printf(gamePlay:getTaskTextAtIndex(i), tasksPaddingLeft,
            currentDrawPosition,
            tasksTextWidth)
        local _, lines = font:getWrap(gamePlay:getTaskTextAtIndex(i), tasksTextWidth)
        currentDrawPosition = currentDrawPosition + tasksSpacing +
            lines * font:getHeight()
    end
    love.graphics.setColor(prevR, prevG, prevB, prevA)
    self.sun_animation:draw(sunPadding, sunPadding)
end
