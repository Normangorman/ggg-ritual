HealthBar = {}
HealthBar.__index = HealthBar

local numberOfHeartsToRender = 5
local heartPadding = 30
local betweenHeartPadding = 5

function HealthBar.new()
    healthBar = {}
    setmetatable(healthBar, HealthBar)

    healthBar.heart_full = love.graphics.newImage("Assets/_UI/heart_full.png")
    healthBar.heart_half = love.graphics.newImage("Assets/_UI/heart_half.png")
    healthBar.heart_empty = love.graphics.newImage("Assets/_UI/heart_empty.png")
    return healthBar
end

function HealthBar:draw()
    local heartWidth = self.heart_full:getWidth()
    local heartXPosition = 790 - heartPadding - heartWidth
    for i=1,numberOfHeartsToRender do
        local heartToDraw = nil
        if i*2 <= player.health then
            heartToDraw = self.heart_full
        elseif i*2 - 1 <= player.health then
            heartToDraw = self.heart_half
        else
            heartToDraw = self.heart_empty
        end
        love.graphics.draw(heartToDraw, heartXPosition, heartPadding)
        heartXPosition = heartXPosition - heartWidth - betweenHeartPadding
    end
end
