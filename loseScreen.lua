LoseScreen = {}
LoseScreen.__index = LoseScreen

function LoseScreen.new()
    local loseScreen = {}
    setmetatable(loseScreen, LoseScreen)

    loseScreen.font = love.graphics.newFont(40)

    return loseScreen
end

function LoseScreen:draw(dt)
    love.graphics.setColor(255, 0, 0, 122)
    love.graphics.setFont(self.font)
    love.graphics.print("Game Over", 250, 200)
end
