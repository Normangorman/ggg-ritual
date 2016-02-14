HealthBar = {}
HealthBar.__index = HealthBar

local numberOfHeartsToRender = 4
local heartPadding = 30
local betweenHeartPadding = 5

function HealthBar.new()
    healthBar = {}
    setmetatable(healthBar, HealthBar)

    healthBar.health = 4
    healthBar.heart_full = love.graphics.newImage("Assets/_UI/heart_empty.png")
    healthBar.heart_empty = love.graphics.newImage("Assets/_UI/heart_full.png")
    return healthBar
end

function HealthBar:draw()
    local heartWidth = self.heart_full:getWidth()
    local heartXPosition = 790 - heartPadding - heartWidth
    for i=1,numberOfHeartsToRender do
        local heartToDraw = nil
        if i < self.health then
            heartToDraw = self.heart_full
        else
            heartToDraw = self.heart_empty
        end
        love.graphics.draw(self.heart_full, heartXPosition, heartPadding)
        heartXPosition = heartXPosition - heartWidth - betweenHeartPadding
    end
end
